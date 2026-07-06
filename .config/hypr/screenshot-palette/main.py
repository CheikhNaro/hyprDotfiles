#!/usr/bin/env python3
"""
HyprScreenshot Palette — Style GNOME Screenshot Tool
GTK4 + libadwaita, positionnée bas-centre via gtk4-layer-shell
Sortie stdout : "mode:action"  (ex: region:screenshot, screen:record…)
"""
import gi
gi.require_version('Gtk', '4.0')
gi.require_version('Adw', '1')
gi.require_version('Gtk4LayerShell', '1.0')
from gi.repository import Gtk, Adw, Gdk, Gtk4LayerShell as LayerShell
import os, sys

# ── Icônes Nerd Font (JetBrainsMono Nerd Font) ────────────────────────────
# Décodage des surrogate pairs fournis par l'utilisateur :
ICON_REGION   = "\U000f0a6c"   # \uDB82\uDE6C  nf-md-selection_drag
ICON_SCREEN   = "\U000f0e51"   # \uDB83\uDE51  nf-md-screenshot
ICON_WINDOW   = "\U000f10ac"   # \uDB84\uDCAC  nf-md-window-open
ICON_PHOTO    = "\ueb4c"       # \uEB4C        nf-cod-device_camera
ICON_RECORD   = "\U000f044b"   # \uDB81\uDC4B  nf-md-record-circle
ICON_TRIGGER  = "\U000f044a"   # \uDB81\uDC4A  nf-md-record-circle-outline

CSS_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "style.css")


class ScreenshotPalette(Adw.Application):
    def __init__(self):
        super().__init__(application_id="com.hypr.screenshot-palette")
        self.connect("activate", self._on_activate)
        self.mode   = "region"       # region | screen | window
        self.action = "screenshot"   # screenshot | record

    # ── Initialisation ────────────────────────────────────────────────────
    def _on_activate(self, app):
        self.win = Gtk.ApplicationWindow(application=app)
        self.win.set_decorated(False)
        self.win.set_resizable(False)
        self.win.add_css_class("palette-window")

        # Layer-shell : overlay, ancré en bas, centré horizontalement
        LayerShell.init_for_window(self.win)
        LayerShell.set_namespace(self.win, "screenshot-palette")
        LayerShell.set_layer(self.win, LayerShell.Layer.OVERLAY)
        LayerShell.set_anchor(self.win, LayerShell.Edge.BOTTOM, True)
        LayerShell.set_margin(self.win, LayerShell.Edge.BOTTOM, 28)
        LayerShell.set_keyboard_mode(
            self.win, LayerShell.KeyboardMode.EXCLUSIVE)

        # Charger le CSS
        if os.path.exists(CSS_PATH):
            prov = Gtk.CssProvider()
            prov.load_from_path(CSS_PATH)
            Gtk.StyleContext.add_provider_for_display(
                Gdk.Display.get_default(), prov,
                Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)

        # Touche Échap → fermer sans action
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

    # ── Construction de l'interface ───────────────────────────────────────
    def _build_ui(self):
        root = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        root.add_css_class("root-box")
        self.win.set_child(root)

        # ── Rangée haute : sélecteur de mode ──────────────────────────────
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

        # ── Rangée basse : type + déclencheur ─────────────────────────────
        action_row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=0)
        action_row.add_css_class("action-row")
        root.append(action_row)

        # Groupe de deux boutons type (photo / record)
        type_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=4)
        type_box.add_css_class("type-group")
        action_row.append(type_box)

        types = [
            ("screenshot", ICON_PHOTO),
            ("record",     ICON_RECORD),
        ]
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

        # Spacer flexible
        spacer = Gtk.Box()
        spacer.set_hexpand(True)
        action_row.append(spacer)

        # Grand bouton déclencheur
        trigger = Gtk.Button()
        trigger.set_valign(Gtk.Align.CENTER)
        trigger.add_css_class("trigger-btn")
        trigger.connect("clicked", self._on_trigger)
        lbl_t = Gtk.Label(label=ICON_TRIGGER)
        lbl_t.add_css_class("trigger-icon")
        trigger.set_child(lbl_t)
        action_row.append(trigger)

    # ── Callbacks ─────────────────────────────────────────────────────────
    def _on_mode(self, btn, key):
        if btn.get_active():
            self.mode = key

    def _on_action(self, btn, key):
        if btn.get_active():
            self.action = key

    def _on_trigger(self, _btn):
        print(f"{self.mode}:{self.action}", flush=True)
        self.quit()


if __name__ == "__main__":
    ScreenshotPalette().run(None)
