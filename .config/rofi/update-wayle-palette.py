#!/usr/bin/env python3
"""
update-wayle-palette.py
Reçoit le JSON matugen sur stdin et met à jour :
  - le thème d'icônes GNOME (Adwaita-<couleur>)
  - le CSS de wlogout (fond d'écran + couleur d'accentuation)
  - les paramètres Vencord (ClientTheme)
  - le thème snappy-switcher (matugen.ini)
"""
import sys
import json
import math
import re
import os
import subprocess

# ── Lecture de l'entrée JSON ────────────────────────────────────────────────
data = json.load(sys.stdin)
colors = data['colors']

# ── Helpers ──────────────────────────────────────────────────────────────────
def hex_to_rgb(h: str) -> tuple[int, int, int]:
    h = h.lstrip('#')
    if len(h) >= 6:
        return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16))
    return (0, 0, 0)

def color_get(key: str, fallback: str) -> str:
    return colors.get(key, {}).get('default', {}).get('color', fallback)

# ── Couleur primaire ─────────────────────────────────────────────────────────
primary_hex = color_get('primary', '#5585c8')
target_rgb  = hex_to_rgb(primary_hex)

# ── Correspondance thème d'icônes ────────────────────────────────────────────
ICON_THEMES = {
    'blue':   (53,  132, 228),
    'brown':  (152, 106, 68),
    'green':  (38,  162, 105),
    'orange': (255, 120, 0),
    'pink':   (213, 97,  153),
    'purple': (145, 65,  172),
    'red':    (224, 27,  36),
    'slate':  (94,  92,  100),
    'teal':   (85,  174, 184),
    'yellow': (246, 211, 45),
}

closest = min(ICON_THEMES, key=lambda name: math.dist(target_rgb, ICON_THEMES[name]))
subprocess.run(
    ['gsettings', 'set', 'org.gnome.desktop.interface', 'icon-theme', f'Adwaita-{closest}'],
    check=False
)

# ── wlogout CSS ──────────────────────────────────────────────────────────────
if len(sys.argv) > 1:
    wp_path     = sys.argv[1]
    wlogout_css = os.path.expanduser('~/.config/wlogout/style.css')
    if os.path.exists(wlogout_css):
        with open(wlogout_css, 'r') as f:
            css = f.read()

        css = re.sub(
            r"background-image:\s*url\('file://.*?'\);",
            f"background-image: url('file://{wp_path}');",
            css
        )
        css = re.sub(
            r"(button:active,\s*button:hover\s*\{[^}]*background-color:\s*)rgba\([^)]+\);",
            fr"\g<1>rgba({target_rgb[0]}, {target_rgb[1]}, {target_rgb[2]}, 0.7);",
            css
        )
        with open(wlogout_css, 'w') as f:
            f.write(css)

# ── Vencord ClientTheme ──────────────────────────────────────────────────────
vencord_settings = os.path.expanduser('~/.config/Vencord/settings/settings.json')
if os.path.exists(vencord_settings):
    try:
        with open(vencord_settings, 'r') as f:
            vencord_data = json.load(f)

        r, g, b = (int(c * 0.20) for c in target_rgb)
        vencord_color = f"{r:02x}{g:02x}{b:02x}"

        vencord_data.setdefault('plugins', {}).setdefault('ClientTheme', {})['color'] = vencord_color

        with open(vencord_settings, 'w') as f:
            json.dump(vencord_data, f, indent=4)
    except Exception:
        pass

# ── Snappy-switcher theme ────────────────────────────────────────────────────
snappy_theme  = os.path.expanduser('~/.config/snappy-switcher/themes/matugen.ini')
snappy_config = os.path.expanduser('~/.config/snappy-switcher/config.ini')

if os.path.isdir(os.path.dirname(snappy_theme)):
    try:
        bg           = color_get('background',            '#1e1e2e')
        surface      = color_get('surface',               '#181825')
        surface_high = color_get('surface_container_high','#313244')
        primary      = color_get('primary',               '#cba6f7')
        on_surface   = color_get('on_surface',            '#cdd6f4')
        on_surf_var  = color_get('on_surface_variant',    '#bac2de')
        secondary    = color_get('secondary',             '#f5e0dc')
        on_secondary = color_get('on_secondary',          '#11111b')
        on_primary   = color_get('on_primary',            '#11111b')

        theme_content = (
            f"[colors]\n"
            f"background = {bg}cc\n"
            f"card_bg = {surface}ff\n"
            f"card_selected = {surface_high}ff\n"
            f"border_color = {primary}ff\n"
            f"text_color = {on_surface}ff\n"
            f"subtext_color = {on_surf_var}ff\n"
            f"bundle_bg = {surface}cc\n"
            f"badge_bg = {secondary}ff\n"
            f"badge_text_color = {on_secondary}ff\n"
            f"badge_bg_selected = {primary}ff\n"
            f"badge_text_color_selected = {on_primary}ff\n"
        )
        with open(snappy_theme, 'w') as f:
            f.write(theme_content)

        if os.path.exists(snappy_config):
            with open(snappy_config, 'r') as f:
                conf = f.read()
            conf = re.sub(r'(?m)^name\s*=.*$', 'name = matugen.ini', conf)
            with open(snappy_config, 'w') as f:
                f.write(conf)

        subprocess.run(['killall', '-USR1', 'snappy-switcher'], stderr=subprocess.DEVNULL)
    except Exception:
        pass
