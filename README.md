<div align="center">

# 🌿 hyprDotfiles

**Configuration Hyprland personnalisée pour Fedora 44**

*Un bureau Wayland moderne, piloté par Lua, avec theming dynamique via Matugen*

</div>

---

## 📸 Aperçu

> *(Ajouter des screenshots ici)*

---

## 🧩 Stack utilisée

| Rôle | Outil |
|---|---|
| **Compositeur Wayland** | [Hyprland](https://hyprland.org/) |
| **Config language** | Lua (via hyprtoolkit) |
| **Terminal** | [Kitty](https://sw.kovidgoyal.net/kitty/) |
| **Launcher** | [Rofi](https://github.com/lbonn/rofi) (Wayland fork) |
| **Lock screen** | [Hyprlock](https://github.com/hyprwm/hyprlock) |
| **Idle daemon** | [Hypridle](https://github.com/hyprwm/hypridle) |
| **Wallpaper** | [Hyprpaper](https://github.com/hyprwm/hyprpaper) |
| **Theming dynamique** | [Matugen](https://github.com/InioX/matugen) |
| **Capture d'écran** | Palette GTK4 custom + [Grim](https://sr.ht/~emersion/grim/) + [Slurp](https://github.com/emersion/slurp) |
| **Annotation** | [Satty](https://github.com/gabm/Satty) |
| **Screen recording** | [wf-recorder](https://github.com/ammen99/wf-recorder) |
| **Presse-papiers** | [Clipse](https://github.com/savedra1/clipse) |
| **Sleep inhibitor** | [Wayle](https://github.com/nwg-piotr/wayle) |
| **OSD (volume/luminosité)** | [SwayOSD](https://github.com/ErikReider/SwayOSD) |
| **Session manager** | [UWSM](https://github.com/Vladimir-csp/uwsm) |
| **Auth agent** | [Hyprpolkitagent](https://github.com/hyprwm/hyprpolkitagent) |
| **Logout** | [Wlogout](https://github.com/ArtsyMacaw/wlogout) |
| **File manager** | [Yazi](https://github.com/sxyazi/yazi) |
| **Shell prompt** | [Starship](https://starship.rs/) |
| **Shell history** | [Atuin](https://atuin.sh/) |
| **System monitor** | [Btop](https://github.com/aristocratos/btop) |
| **Audio visualizer** | [Cava](https://github.com/karlstav/cava) |
| **Emoji picker** | [HyprEmoji](https://github.com/hyprwm/contrib) |
| **Polices** | JetBrainsMono Nerd Font |

---

## ⚙️ Installation

### 1. Paquets système (Fedora 44 / DNF)

```bash
sudo dnf install -y \
  hyprland hypridle hyprlock hyprpaper hyprpicker hyprpolkitagent \
  hyprland-uwsm hyprtoolkit xdg-desktop-portal-hyprland \
  grim slurp wf-recorder wtype wlogout swayosd \
  kitty rofi \
  python3-gobject libadwaita gtk4-layer-shell gtk4-layer-shell-devel \
  matugen sddm sddm-wayland-generic \
  jq btop fastfetch cava yazi atuin \
  cargo rust
```

### 2. Outils Cargo (compilés depuis les sources)

```bash
# Annotation de captures d'écran
cargo install satty

# Sleep inhibitor bar item
cargo install wayle wayle-settings

# Générateur de palettes depuis wallpaper
cargo install wallust
```

> **Note :** `cargo install` place les binaires dans `~/.cargo/bin/`.
> Assurez-vous que ce chemin est dans votre `$PATH`.

### 3. Polices

Télécharger **JetBrainsMono Nerd Font** depuis les [Nerd Fonts releases](https://github.com/ryanoasis/nerd-fonts/releases) :

```bash
mkdir -p ~/.local/share/fonts
# Télécharger JetBrainsMono.tar.xz depuis GitHub Releases puis :
tar -xf JetBrainsMono.tar.xz -C ~/.local/share/fonts/
fc-cache -fv
```

### 4. Clipse (gestionnaire de presse-papiers)

Clipse n'est pas dans les dépôts Fedora. Téléchargez le binaire depuis les [releases GitHub](https://github.com/savedra1/clipse/releases) et placez-le dans `/usr/local/bin/` :

```bash
sudo install -m 755 clipse /usr/local/bin/clipse
```

### 5. Déploiement des configs

Clonez ce dépôt et copiez le dossier `.config` dans votre home :

```bash
git clone https://github.com/CheikhNaro/hyprDotfiles.git
cp -r hyprDotfiles/.config/. ~/.config/
```

> **⚠️ Important :** Le fichier `.config/hypr/modules/monitors.lua` est **spécifique à votre hardware**.
> Modifiez-le pour correspondre à vos moniteurs avant de lancer Hyprland.

### 6. Services systemd utilisateur

Activez les services au démarrage de session :

```bash
systemctl --user daemon-reload
systemctl --user enable --now clipse.service
systemctl --user enable --now dwindle-clockwise.service
```

### 7. Premier lancement de Matugen

Matugen génère les couleurs de votre thème depuis votre fond d'écran.
Placez votre wallpaper dans `~/Pictures/` puis lancez :

```bash
matugen image ~/Pictures/votre-wallpaper.jpg
```

---

## 📁 Structure du repo

```
hyprDotfiles/
└── .config/
    ├── hypr/                   # Config Hyprland (Lua)
    │   ├── modules/            # animations, binds, env, window_rules...
    │   ├── scripts/            # Scripts bash personnalisés
    │   ├── screenshot-palette/ # Outil de capture GTK4 (Python)
    │   └── hyprland.lua        # Point d'entrée
    ├── rofi/                   # Launcher et menus
    ├── kitty/                  # Terminal
    ├── matugen/                # Templates de theming dynamique
    ├── wlogout/                # Écran de déconnexion
    ├── wayle/                  # Sleep inhibitor
    ├── fastfetch/              # System info
    ├── btop/                   # Process monitor
    ├── cava/                   # Audio visualizer
    ├── yazi/                   # File manager
    ├── swayosd/                # OSD overlay
    ├── systemd/                # Services utilisateur
    └── starship.toml           # Shell prompt
```

---

## 🎨 Theming

Ce setup utilise **Matugen** pour générer automatiquement une palette de couleurs cohérente depuis le fond d'écran. Les templates se trouvent dans `.config/matugen/templates/` et appliquent les couleurs générées à :

- Rofi
- Hyprlock
- GTK 3 & 4
- Kitty
- HyprEmoji

---

## 📋 Notes

- La config Hyprland est écrite en **Lua** via `hyprtoolkit`, pas en `.conf` standard.
- Le fichier `monitors.lua` est intentionnellement exclu du repo (hardware-specific).
- `rofi/colors.rasi` est exclu car généré par Matugen.