#!/usr/bin/env python3
"""
HyprScreenshot Palette v2 — Kooha Workflow
GTK4 + libadwaita, positionnée bas-centre via gtk4-layer-shell
"""
import gi, json, os, subprocess
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
ICON_MIC      = "\uec1c"
ICON_SPK      = "\uf028"

CSS_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "style.css")

def _get_default_audio_devices():
    mic = None
    spk = None
    try:
        mic = subprocess.check_output(["pactl", "get-default-source"], text=True).strip()
        spk = subprocess.check_output(["pactl", "get-default-sink"], text=True).strip() + ".monitor"
    except Exception:
        pass
    return mic, spk

class ScreenshotPalette(Adw.Application):
    def __init__(self):
        super().__init__(application_id="com.hypr.screenshot-palette")
        self.connect("activate", self._on_activate)
        self.mode        = "region"
        self.action      = "screenshot"
        self.fmt         = "mp4"
        self.delay       = 0
        self.fps         = 60
        self.use_mic     = False
        self.use_spk     = False
        self.def_mic, self.def_spk = _get_default_audio_devices()
        
        self._countdown_val = 0

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
        self.mode_row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        self.mode_row.add_css_class("mode-row")
        root.append(self.mode_row)

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
            self.mode_row.append(btn)
            self._mode_btns[key] = btn
            prev = btn

        # ── 2. Options d'enregistrement (Kooha Workflow) ────────
        self._rec_options_row = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)
        self._rec_options_row.add_css_class("rec-options-section")
        self._rec_options_row.set_visible(self.action == "record")
        root.append(self._rec_options_row)

        # 2a. Audio Toggles
        audio_row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        audio_row.set_halign(Gtk.Align.CENTER)
        self._rec_options_row.append(audio_row)

        self.btn_mic = Gtk.ToggleButton(label=f"{ICON_MIC} Mic")
        self.btn_mic.add_css_class("fmt-btn")
        self.btn_mic.connect("toggled", self._on_mic_toggle)
        audio_row.append(self.btn_mic)

        self.btn_spk = Gtk.ToggleButton(label=f"{ICON_SPK} Speaker")
        self.btn_spk.add_css_class("fmt-btn")
        self.btn_spk.connect("toggled", self._on_spk_toggle)
        audio_row.append(self.btn_spk)

        # 2b. Format & FPS
        fmt_fps_row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        fmt_fps_row.set_halign(Gtk.Align.CENTER)
        self._rec_options_row.append(fmt_fps_row)
        
        fmt_group = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=2)
        fmt_group.add_css_class("fmt-group")
        prev_f = None
        for fmt in ["mp4", "mkv", "webm", "gif"]:
            b = Gtk.ToggleButton(group=prev_f, label=fmt.upper())
            b.add_css_class("fmt-btn")
            if fmt == self.fmt: b.set_active(True)
            b.connect("toggled", self._on_fmt, fmt)
            fmt_group.append(b)
            prev_f = b
        fmt_fps_row.append(fmt_group)

        fps_group = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=2)
        fps_group.add_css_class("fmt-group")
        prev_fps = None
        for fps in [30, 60]:
            b = Gtk.ToggleButton(group=prev_fps, label=f"{fps}FPS")
            b.add_css_class("fmt-btn")
            if fps == self.fps: b.set_active(True)
            b.connect("toggled", self._on_fps, fps)
            fps_group.append(b)
            prev_fps = b
        fmt_fps_row.append(fps_group)

        # 2c. Delay
        delay_row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        delay_row.set_halign(Gtk.Align.CENTER)
        self._rec_options_row.append(delay_row)

        delay_group = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=2)
        delay_group.add_css_class("fmt-group")
        prev_d = None
        for delay, lbl in [(0, "0s"), (3, "3s"), (5, "5s"), (10, "10s")]:
            b = Gtk.ToggleButton(group=prev_d, label=lbl)
            b.add_css_class("fmt-btn")
            if delay == self.delay: b.set_active(True)
            b.connect("toggled", self._on_delay, delay)
            delay_group.append(b)
            prev_d = b
        delay_row.append(delay_group)

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
            self.win.set_default_size(-1, -1)

    def _on_fmt(self, btn, fmt):
        if btn.get_active(): self.fmt = fmt

    def _on_fps(self, btn, fps):
        if btn.get_active(): self.fps = fps

    def _on_delay(self, btn, delay):
        if btn.get_active(): self.delay = delay

    def _on_mic_toggle(self, btn):
        self.use_mic = btn.get_active()

    def _on_spk_toggle(self, btn):
        self.use_spk = btn.get_active()

    def _on_trigger(self, _btn):
        if self.delay > 0 and self.action == "record":
            self._start_countdown(self.delay)
        else:
            self._emit_and_quit()

    def _start_countdown(self, seconds):
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
            "mode":         self.mode,
            "action":       self.action,
            "format":       self.fmt,
            "fps":          self.fps,
            "audio_mic":    self.def_mic if self.use_mic else None,
            "audio_spk":    self.def_spk if self.use_spk else None,
            "delay":        self.delay,
        }
        print(json.dumps(result), flush=True)
        self.quit()

if __name__ == "__main__":
    ScreenshotPalette().run(None)
