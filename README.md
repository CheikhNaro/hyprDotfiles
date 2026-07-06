<div align="center">

# 🌿 hyprDotfiles

**Custom Hyprland configuration for Fedora 44**

*A modern Wayland desktop, driven by Lua, with dynamic theming via Matugen*

</div>

---

## 📸 Preview

> *(Add screenshots here)*

---

## 🧩 Stack used

| Role | Tool |
|---|---|
| **Wayland compositor** | [Hyprland](https://hyprland.org/) |
| **Config language** | Lua (via hyprtoolkit) |
| **Terminal** | [Kitty](https://sw.kovidgoyal.net/kitty/) |
| **Launcher** | [Rofi](https://github.com/lbonn/rofi) (Wayland fork) |
| **Lock screen** | [Hyprlock](https://github.com/hyprwm/hyprlock) |
| **Idle daemon** | [Hypridle](https://github.com/hyprwm/hypridle) |
| **Wallpaper** | [Hyprpaper](https://github.com/hyprwm/hyprpaper) |
| **Dynamic theming** | [Matugen](https://github.com/InioX/matugen) |
| **Screenshot** | Custom GTK4 palette + [Grim](https://sr.ht/~emersion/grim/) + [Slurp](https://github.com/emersion/slurp) |
| **Annotation** | [Satty](https://github.com/gabm/Satty) |
| **Screen recording** | [wf-recorder](https://github.com/ammen99/wf-recorder) |
| **Clipboard** | [Clipse](https://github.com/savedra1/clipse) |
| **Sleep inhibitor** | [Wayle](https://github.com/nwg-piotr/wayle) |
| **OSD (volume/brightness)** | [SwayOSD](https://github.com/ErikReider/SwayOSD) |
| **Session manager** | [UWSM](https://github.com/Vladimir-csp/uwsm) |
| **Auth agent** | [Hyprpolkitagent](https://github.com/hyprwm/hyprpolkitagent) |
| **Logout** | [Wlogout](https://github.com/ArtsyMacaw/wlogout) |
| **File manager** | [Yazi](https://github.com/sxyazi/yazi) |
| **Shell prompt** | [Starship](https://starship.rs/) |
| **Shell history** | [Atuin](https://atuin.sh/) |
| **System monitor** | [Btop](https://github.com/aristocratos/btop) |
| **Audio visualizer** | [Cava](https://github.com/karlstav/cava) |
| **Emoji picker** | [HyprEmoji](https://github.com/hyprwm/contrib) |
| **Fonts** | JetBrainsMono Nerd Font |

---

## ⚙️ Installation

### 1. System packages (Fedora 44 / DNF)

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

### 2. Cargo tools (compiled from source)

```bash
# Screenshot annotation
cargo install satty

# Palette generator from wallpaper
cargo install wallust
```

> **Note:** `cargo install` places binaries in `~/.cargo/bin/`.
> Make sure this path is in your `$PATH`.

### 3. Wayle (Sleep inhibitor bar item)

Requires Fedora 42 or later. Fedora 41 reached EOL on 2025-11-19.

**Install dependencies**
Install Rust via rustup, then the system libraries:

```bash
sudo dnf install git cmake pkgconf-pkg-config gtk4-devel gtk4-layer-shell-devel \
  gtksourceview5-devel pulseaudio-libs-devel fftw-devel pipewire-devel \
  systemd-devel clang gcc
```

Fedora Workstation already ships the runtime daemons for battery, bluetooth, network, power, and audio. Minimal and Server installs need:

```bash
sudo dnf install pipewire-pulseaudio wireplumber NetworkManager bluez upower \
  power-profiles-daemon
sudo systemctl enable --now bluetooth NetworkManager upower power-profiles-daemon
```

**Build**

```bash
git clone https://github.com/wayle-rs/wayle
cd wayle
cargo install --path wayle
cargo install --path crates/wayle-settings
```

**Icon assets**
Wayle ships icons as source files that get copied into your user data directory on first setup. Run this from the cloned repo, before deleting it:

```bash
wayle icons setup
```

**Run**
Start the panel in the background:

```bash
wayle panel start
```

Other lifecycle commands: `wayle panel status`, `wayle panel restart`, `wayle panel stop`.

For debugging, run the shell in the foreground so logs print to the terminal:

```bash
wayle shell
```

**Settings GUI**

```bash
wayle panel settings
```

This launches `wayle-settings`, which edits the same config the shell reads. Changes apply live. Anything the GUI doesn't cover can still be edited by hand in `config.toml`.

### 4. Fonts

Download **JetBrainsMono Nerd Font** from the [Nerd Fonts releases](https://github.com/ryanoasis/nerd-fonts/releases) :

```bash
mkdir -p ~/.local/share/fonts
# Download JetBrainsMono.tar.xz from GitHub Releases then :
tar -xf JetBrainsMono.tar.xz -C ~/.local/share/fonts/
fc-cache -fv
```

### 5. Clipse (clipboard manager)

Clipse is not in the Fedora repositories. Download the binary from the [GitHub releases](https://github.com/savedra1/clipse/releases) and place it in `/usr/local/bin/` :

```bash
sudo install -m 755 clipse /usr/local/bin/clipse
```

### 6. Config deployment

Clone this repository and copy the `.config` folder to your home directory:

```bash
git clone https://github.com/CheikhNaro/hyprDotfiles.git
cp -r hyprDotfiles/.config/. ~/.config/
```

> **⚠️ Important:** The `.config/hypr/modules/monitors.lua` file is **specific to your hardware**.
> Edit it to match your monitors before starting Hyprland.

### 7. User systemd services

Enable the services to start at login:

```bash
systemctl --user daemon-reload
systemctl --user enable --now clipse.service
systemctl --user enable --now dwindle-clockwise.service
```

### 8. First launch of Matugen

Matugen generates your theme colors from your wallpaper.
Place your wallpaper in `~/Pictures/` then run:

```bash
matugen image ~/Pictures/your-wallpaper.jpg
```

---

## 📁 Repository structure

```
hyprDotfiles/
└── .config/
    ├── hypr/                   # Hyprland config (Lua)
    │   ├── modules/            # animations, binds, env, window_rules...
    │   ├── scripts/            # Custom bash scripts
    │   ├── screenshot-palette/ # GTK4 capture tool (Python)
    │   └── hyprland.lua        # Entry point
    ├── rofi/                   # Launcher and menus
    ├── kitty/                  # Terminal
    ├── matugen/                # Dynamic theming templates
    ├── wlogout/                # Logout screen
    ├── wayle/                  # Sleep inhibitor
    ├── fastfetch/              # System info
    ├── btop/                   # Process monitor
    ├── cava/                   # Audio visualizer
    ├── yazi/                   # File manager
    ├── swayosd/                # OSD overlay
    ├── systemd/                # User services
    └── starship.toml           # Shell prompt
```

---

## 🎨 Theming

This setup uses **Matugen** to automatically generate a cohesive color palette from the wallpaper. The templates are located in `.config/matugen/templates/` and apply the generated colors to:

- Rofi
- Hyprlock
- GTK 3 & 4
- Kitty
- HyprEmoji

---

## 📋 Notes

- The Hyprland config is written in **Lua** via `hyprtoolkit`, not in standard `.conf`.
- The `monitors.lua` file is intentionally excluded from the repo (hardware-specific).
- `rofi/colors.rasi` is excluded because it is generated by Matugen.