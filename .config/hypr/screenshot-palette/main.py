#!/usr/bin/env python3
"""
HyprScreenshot Palette v2 — Style GNOME Screenshot Tool
GTK4 + libadwaita, positionnée bas-centre via gtk4-layer-shell

Sortie stdout (JSON) : {"mode":"region","action":"screenshot","format":"mp4",
                        "audio_sink":true,"audio_mic":false,
                        "mic_device":"...","sink_device":"...","delay":0}
"""
import gi, subprocess, json, os, threading
gi.require_version('Gtk', '4.0')
gi.require_version('Adw', '1')
gi.require_version('Gtk4LayerShell', '1.0')
from gi.repository import Gtk, Adw, Gdk, GLib, Gtk4LayerShell as LayerShell

# ── Icônes Nerd Font ──────────────────────────────────────────────────────────
ICON_REGION   = "\U000f0a6c"
ICON_SCREEN   = "\U000f0e51"
ICON_WINDOW   = "\U000f10ac"
ICON_PHOTO    = "\ueb4c"
ICON_RECORD   = "\U000f044b"
ICON_TRIGGER  = "\U000f044a"
ICON_MIC_ON   = "\U000f0764"   # nf-md-microphone
ICON_MIC_OFF  = "\U000f0766"   # nf-md-microphone-off
ICON_SPK_ON   = "\U000f057e"   # nf-md-volume-high
ICON_SPK_OFF  = "\U000f0581"   # nf-md-volume-off
ICON_TIMER    = "\U000f0954"   # nf-md-timer-outline
ICON_CHEVRON  = "\U000f0140"   # nf-md-chevron-down

CSS_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "style.css")


def _get_pw_sources():
    """Retourne la liste des sources et sinks PipeWire via pw-cli."""
    sources, sinks = [], []
    try:
        out = subprocess.check_output(
            ["pw-cli", "ls", "Node"], text=True, stderr=subprocess.DEVNULL)
        current = {}
        for line in out.splitlines():
            line = line.strip()
            if line.startswith("id "):
                if current.get("media.class") in ("Audio/Source", "Audio/Sink"):
                    entry = {
                        "name": current.get("node.name", ""),
                        "desc": current.get("node.description", current.get("node.name", "?")),
                    }
                    if current["media.class"] == "Audio/Source":
                        sources.append(entry)
                    else:
                        sinks.append(entry)
                current = {}
            elif " = " in line:
                k, _, v = line.partition(" = ")
                k = k.strip().strip('"')
                v = v.strip().strip('"')
                current[k] = v
        # flush dernière entrée
        if current.get("media.class") in ("Audio/Source", "Audio/Sink"):
            entry = {
                "name": current.get("node.name", ""),
                "desc": current.get("node.description", current.get("node.name", "?")),
            }
            if current["media.class"] == "Audio/Source":
                sources.append(entry)
            else:
                sinks.append(entry)
    except Exception:
        pass
    return sources, sinks


class ScreenshotPalette(Adw.Application):
    def __init__(self):
        super().__init__(application_id="com.hypr.screenshot-palette")
        self.connect("activate", self._on_activate)
        self.mode       = "region"
        self.action     = "screenshot"
        self.fmt        = "mp4"
        self.audio_mic  = False
        self.audio_sink = False
        self.mic_device  = ""
        self.sink_device = ""
        self.delay      = 0
        self._countdown_label = None
        self._countdown_val   = 0

        # Récupérer les devices audio en arrière-plan
        self._sources, self._sinks = [], []
        threading.Thread(target=self._load_audio_devices, daemon=True).start()

    def _load_audio_devices(self):
        srcs, snks = _get_pw_sources()
        GLib.idle_add(self._apply_audio_devices, srcs, snks)

    def _apply_audio_devices(self, srcs, snks):
        self._sources = srcs
        self._sinks   = snks
        # Défaut = premier device trouvé
        if srcs and not self.mic_device:
            self.mic_device = srcs[0]["name"]
        if snks and not self.sink_device:
            self.sink_device = snks[0]["name"]
        self._update_audio_menus()

    def _update_audio_menus(self):
        """Recharge les menus dropdowns audio une fois les devices connus."""
        if not hasattr(self, "_mic_dropdown") or not hasattr(self, "_sink_dropdown"):
            return
        # Microphone
        mic_model = Gtk.StringList.new([d["desc"] for d in self._sources] or ["Aucun"])
        self._mic_dropdown.set_model(mic_model)
        # Sortie système (monitor)
        sink_names = [f"{d['desc']} (monitor)" for d in self._sinks] or ["Aucun"]
        sink_model = Gtk.StringList.new(sink_names)
        self._sink_dropdown.set_model(sink_model)

    # ── Initialisation ─────────────────────────────────────────────────────
    def _on_activate(self, app):
        self.win = Gtk.ApplicationWindow(application=app)
        self.win.set_decorated(False)
        self.win.set_resizable(False)
        self.win.add_css_class("palette-window")

        LayerShell.init_for_window(self.win)
        LayerShell.set_namespace(self.win, "screenshot-palette")
        LayerShell.set_layer(self.win, LayerShell.Layer.OVERLAY)
        LayerShell.set_anchor(self.win, LayerShell.Edge.BOTTOM, True)
        LayerShell.set_margin(self.win, LayerShell.Edge.BOTTOM, 28)
        LayerShell.set_keyboard_mode(self.win, LayerShell.KeyboardMode.EXCLUSIVE)

        if os.path.exists(CSS_PATH):
            prov = Gtk.CssProvider()
            prov.load_from_path(CSS_PATH)
            Gtk.StyleContext.add_provider_for_display(
                Gdk.Display.get_default(), prov,
                Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)

        key_ctrl = Gtk.EventControllerKey()
        key_ctrl.connect("key-pressed", self._on_key)
        self.win.add_controller(key_ctrl)

        self._build_ui()
        self.win.present()

    def _on_key(self, ctrl, keyval, keycode, state):
        if keyval == Gdk.KEY_Escape:
            self.quit()
            return True
        return False

    # ── Construction de l'interface ────────────────────────────────────────
    def _build_ui(self):
        root = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        root.add_css_class("root-box")
        self.win.set_child(root)

        # ── 1. Rangée modes (Area / Screen / Window) ───────────────────────
        mode_row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        mode_row.add_css_class("mode-row")
        root.append(mode_row)

        modes = [
            ("region", ICON_REGION, "Area"),
            ("screen", ICON_SCREEN, "Screen"),
            ("window", ICON_WINDOW, "Window"),
        ]
        self._mode_btns = {}
        prev = None
        for key, icon, label in modes:
            btn = Gtk.ToggleButton(group=prev)
            btn.add_css_class("mode-btn")
            if key == self.mode:
                btn.set_active(True)
            vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=2)
            vbox.set_halign(Gtk.Align.CENTER)
            lbl_icon = Gtk.Label(label=icon)
            lbl_icon.set_halign(Gtk.Align.CENTER)
            lbl_icon.add_css_class("mode-icon")
            if key == "screen":
                lbl_icon.add_css_class("screen-icon")
            lbl_text = Gtk.Label(label=label)
            lbl_text.set_halign(Gtk.Align.CENTER)
            lbl_text.add_css_class("mode-label")
            vbox.append(lbl_icon)
            vbox.append(lbl_text)
            btn.set_child(vbox)
            btn.connect("toggled", self._on_mode, key)
            mode_row.append(btn)
            self._mode_btns[key] = btn
            prev = btn

        # ── 2. Rangée options enregistrement (cachée si screenshot) ────────
        self._rec_options_row = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        self._rec_options_row.add_css_class("rec-options-section")
        self._rec_options_row.set_visible(self.action == "record")
        root.append(self._rec_options_row)

        # 2a. Format + Timer
        fmt_timer_row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        fmt_timer_row.add_css_class("fmt-timer-row")
        self._rec_options_row.append(fmt_timer_row)

        # Sélecteur de format
        fmt_label = Gtk.Label(label="Format")
        fmt_label.add_css_class("options-label")
        fmt_timer_row.append(fmt_label)

        fmt_group = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=2)
        fmt_group.add_css_class("fmt-group")
        self._fmt_btns = {}
        prev_f = None
        for fmt in ["mp4", "mkv", "gif"]:
            b = Gtk.ToggleButton(group=prev_f, label=fmt.upper())
            b.add_css_class("fmt-btn")
            if fmt == self.fmt:
                b.set_active(True)
            b.connect("toggled", self._on_fmt, fmt)
            fmt_group.append(b)
            self._fmt_btns[fmt] = b
            prev_f = b
        fmt_timer_row.append(fmt_group)

        # Spacer
        sp1 = Gtk.Box()
        sp1.set_hexpand(True)
        fmt_timer_row.append(sp1)

        # Timer
        timer_label = Gtk.Label(label="Delay")
        timer_label.add_css_class("options-label")
        fmt_timer_row.append(timer_label)

        timer_group = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=2)
        timer_group.add_css_class("fmt-group")
        self._timer_btns = {}
        prev_d = None
        for delay, lbl in [(0, "0s"), (3, "3s"), (5, "5s")]:
            b = Gtk.ToggleButton(group=prev_d, label=lbl)
            b.add_css_class("fmt-btn")
            if delay == self.delay:
                b.set_active(True)
            b.connect("toggled", self._on_delay, delay)
            timer_group.append(b)
            self._timer_btns[delay] = b
            prev_d = b
        fmt_timer_row.append(timer_group)

        # 2b. Audio row
        audio_row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        audio_row.add_css_class("audio-row")
        self._rec_options_row.append(audio_row)

        # -- Micro toggle + dropdown
        mic_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=4)
        mic_box.add_css_class("audio-device-box")

        self._mic_toggle = Gtk.ToggleButton()
        self._mic_toggle.add_css_class("audio-toggle-btn")
        lbl_mic = Gtk.Label(label=ICON_MIC_ON)
        lbl_mic.add_css_class("audio-icon")
        self._mic_lbl = lbl_mic
        self._mic_toggle.set_child(lbl_mic)
        self._mic_toggle.set_active(self.audio_mic)
        self._mic_toggle.connect("toggled", self._on_mic_toggle)
        mic_box.append(self._mic_toggle)

        self._mic_dropdown = Gtk.DropDown()
        self._mic_dropdown.add_css_class("audio-dropdown")
        self._mic_dropdown.set_sensitive(self.audio_mic)
        self._mic_dropdown.connect("notify::selected", self._on_mic_selected)
        mic_box.append(self._mic_dropdown)
        audio_row.append(mic_box)

        # Séparateur vertical
        sep = Gtk.Separator(orientation=Gtk.Orientation.VERTICAL)
        sep.add_css_class("audio-sep")
        audio_row.append(sep)

        # -- Sortie audio toggle + dropdown
        sink_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=4)
        sink_box.add_css_class("audio-device-box")

        self._sink_toggle = Gtk.ToggleButton()
        self._sink_toggle.add_css_class("audio-toggle-btn")
        lbl_sink = Gtk.Label(label=ICON_SPK_ON)
        lbl_sink.add_css_class("audio-icon")
        self._sink_lbl = lbl_sink
        self._sink_toggle.set_child(lbl_sink)
        self._sink_toggle.set_active(self.audio_sink)
        self._sink_toggle.connect("toggled", self._on_sink_toggle)
        sink_box.append(self._sink_toggle)

        self._sink_dropdown = Gtk.DropDown()
        self._sink_dropdown.add_css_class("audio-dropdown")
        self._sink_dropdown.set_sensitive(self.audio_sink)
        self._sink_dropdown.connect("notify::selected", self._on_sink_selected)
        sink_box.append(self._sink_dropdown)
        audio_row.append(sink_box)

        # Remplir les dropdowns si devices déjà chargés
        self._update_audio_menus()

        # ── 3. Rangée basse : type + déclencheur ──────────────────────────
        action_row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=0)
        action_row.add_css_class("action-row")
        root.append(action_row)

        type_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=4)
        type_box.add_css_class("type-group")
        action_row.append(type_box)

        types = [("screenshot", ICON_PHOTO), ("record", ICON_RECORD)]
        self._type_btns = {}
        prev_t = None
        for key, icon in types:
            btn = Gtk.ToggleButton(group=prev_t)
            btn.add_css_class("type-btn")
            if key == self.action:
                btn.set_active(True)
            lbl = Gtk.Label(label=icon)
            lbl.add_css_class("type-icon")
            if key == "record":
                lbl.add_css_class("record-icon")
            elif key == "screenshot":
                lbl.add_css_class("photo-icon")
            btn.set_child(lbl)
            btn.connect("toggled", self._on_action, key)
            type_box.append(btn)
            self._type_btns[key] = btn
            prev_t = btn

        spacer = Gtk.Box()
        spacer.set_hexpand(True)
        action_row.append(spacer)

        # Grand bouton déclencheur
        self._trigger = Gtk.Button()
        self._trigger.set_valign(Gtk.Align.CENTER)
        self._trigger.add_css_class("trigger-btn")
        self._trigger.connect("clicked", self._on_trigger)
        self._trigger_lbl = Gtk.Label(label=ICON_TRIGGER)
        self._trigger_lbl.add_css_class("trigger-icon")
        self._trigger.set_child(self._trigger_lbl)
        action_row.append(self._trigger)

    # ── Callbacks ─────────────────────────────────────────────────────────
    def _on_mode(self, btn, key):
        if btn.get_active():
            self.mode = key

    def _on_action(self, btn, key):
        if btn.get_active():
            self.action = key
            self._rec_options_row.set_visible(key == "record")
            # Resize la fenêtre
            self.win.set_default_size(-1, -1)

    def _on_fmt(self, btn, fmt):
        if btn.get_active():
            self.fmt = fmt

    def _on_delay(self, btn, delay):
        if btn.get_active():
            self.delay = delay

    def _on_mic_toggle(self, btn):
        self.audio_mic = btn.get_active()
        self._mic_dropdown.set_sensitive(self.audio_mic)
        self._mic_lbl.set_label(ICON_MIC_ON if self.audio_mic else ICON_MIC_OFF)
        if self.audio_mic:
            btn.add_css_class("audio-toggle-active")
        else:
            btn.remove_css_class("audio-toggle-active")

    def _on_sink_toggle(self, btn):
        self.audio_sink = btn.get_active()
        self._sink_dropdown.set_sensitive(self.audio_sink)
        self._sink_lbl.set_label(ICON_SPK_ON if self.audio_sink else ICON_SPK_OFF)
        if self.audio_sink:
            btn.add_css_class("audio-toggle-active")
        else:
            btn.remove_css_class("audio-toggle-active")

    def _on_mic_selected(self, dd, _):
        idx = dd.get_selected()
        if 0 <= idx < len(self._sources):
            self.mic_device = self._sources[idx]["name"]

    def _on_sink_selected(self, dd, _):
        idx = dd.get_selected()
        if 0 <= idx < len(self._sinks):
            # Le monitor d'un sink = son.nom + ".monitor"
            self.sink_device = self._sinks[idx]["name"] + ".monitor"

    def _on_trigger(self, _btn):
        if self.delay > 0 and self.action == "record":
            self._start_countdown(self.delay)
        else:
            self._emit_and_quit()

    def _start_countdown(self, seconds):
        """Affiche un compte à rebours sur le bouton déclencheur."""
        self._countdown_val = seconds
        self._trigger.set_sensitive(False)
        self._trigger_lbl.add_css_class("countdown-label")
        self._update_countdown()

    def _update_countdown(self):
        if self._countdown_val <= 0:
            self._emit_and_quit()
            return
        self._trigger_lbl.set_label(str(self._countdown_val))
        self._countdown_val -= 1
        GLib.timeout_add(1000, self._update_countdown)

    def _emit_and_quit(self):
        result = {
            "mode":        self.mode,
            "action":      self.action,
            "format":      self.fmt,
            "audio_mic":   self.audio_mic,
            "audio_sink":  self.audio_sink,
            "mic_device":  self.mic_device,
            "sink_device": self.sink_device,
            "delay":       self.delay,
        }
        print(json.dumps(result), flush=True)
        self.quit()


if __name__ == "__main__":
    ScreenshotPalette().run(None)
