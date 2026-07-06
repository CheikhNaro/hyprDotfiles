<div align="center">

# 🌿 hyprDotfiles

**Here are my custom Hyprland config files on Fedora**

</div>

---

## 📸 Preview

> *(Add screenshots here)*

---

## 🧩 Dependancies

| Role | Tool |
|---|---|
| **Wayland compositor** | [Hyprland](https://wiki.hypr.land/Getting-Started/Installation/#:~:text=lionheartp/Hyprland%20Copr%20repository.) |
| **Config language** | Lua (via hyprtoolkit) |
| **Terminal** | [Kitty](https://sw.kovidgoyal.net/kitty/) |
| **Launcher** | [Rofi](https://github.com/lbonn/rofi) (Wayland fork) |
| **Lock screen** | [Hyprlock](https://github.com/hyprwm/hyprlock) |
| **Idle daemon** | [Hypridle](https://github.com/hyprwm/hyprpolkitagent) |
| **Wallpaper** | [AWWW](https://codeberg.org/LGFae/awww) |
| **Dynamic theming** | [Matugen](https://github.com/InioX/matugen) |
| **Screenshot** | Custom GTK4 palette + [Grim](https://sr.ht/~emersion/grim/) + [Slurp](https://github.com/emersion/slurp) |
| **Annotation** | [Satty](https://github.com/gabm/Satty) |
| **Screen recording** | [wf-recorder](https://github.com/ammen99/wf-recorder) |
| **Clipboard** | [Clipse](https://github.com/savedra1/clipse) |
| **Clipboard GUI** | [Clipse-gui](https://github.com/d7omdev/clipse-gui) |
| **OSD (volume/brightness)** | [SwayOSD](https://github.com/ErikReider/SwayOSD) |
| **Auth agent** | [Hyprpolkitagent](https://github.com/hyprwm/hyprpolkitagent) |
| **Logout** | [Wlogout](https://github.com/ArtsyMacaw/wlogout) |
| **Shell prompt** | [Starship](https://starship.rs/) |
| **Shell history** | [Atuin](https://atuin.sh/) |
| **System monitor** | [Btop](https://github.com/aristocratos/btop) |
| **Audio visualizer** | [Cava](https://github.com/karlstav/cava) |
| **Emoji picker** | [HyprEmoji](https://github.com/Musagy/hypremoji) |
| **Fonts** | [JetBrainsMono Nerd Font](https://www.nerdfonts.com/font-downloads#:~:text=Download-,JetBrainsMono,-%E2%80%A2%20Version%3A%202.304) |

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
cargo install matugen
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

Download **JetBrainsMono Nerd Font** from the [Here](https://github.com/ryanoasis/nerd-fonts/releases)

Download **FiraCode Nerd Font** from the [Here](https://www.nerdfonts.com/font-downloads#:~:text=Preview-,FiraCode,-%E2%80%A2%20Version%3A%206.2)

Download **FiraMono Nerd Font** from the [Here](https://www.nerdfonts.com/font-downloads#:~:text=Preview-,FiraMono,-%E2%80%A2%20Original%20Font%20Name)

```bash
# After downloading the fonts, unzip and place them in ~/.local/share/fonts/:
mkdir -p ~/.local/share/fonts
#then
fc-cache -fv
```

### 5. Clipse (clipboard manager)

Clipse is not in the Fedora repositories. Download the binary from the [GitHub releases](https://github.com/savedra1/clipse/releases) and place it in `/usr/local/bin/` :

```bash
sudo dnf copr enable azandure/clipse
sudo dnf install clipse
```

Download and install Clipse GUI:

```bash
git clone https://github.com/d7omdev/clipse-gui
cd clipse-gui
just install
```

### 6. Config deployment

Clone this repository and copy the `.config` folder to your home directory:

```bash
git clone https://github.com/CheikhNaro/hyprDotfiles.git
cp -r hyprDotfiles/.config/. ~/.config/
```

> **⚠️ Important:** The `.config/hypr/modules/monitors.lua` file is **specific to your hardware**.
> Edit it to match your monitors before starting Hyprland.
> Also edit the `.config/hypr/modules/binds.lua` file to your need.

### 7. SDDM Themes

The repository includes custom SDDM themes (`pixie` and `thyx`). Copy them to the system directory:

```bash
sudo cp -r hyprDotfiles/sddm/themes/* /usr/share/sddm/themes/
```

### 8. User systemd services

Enable the services to start at login:

```bash
systemctl --user daemon-reload
systemctl --user enable --now clipse.service
systemctl --user enable --now dwindle-clockwise.service
```

### 9. Theming : First launch of Matugen

This setup uses **Matugen** to automatically generate a cohesive color palette from the wallpaper. The templates are located in `.config/matugen/templates/` and apply the generated colors to your apps.

```bash
#Example:
matugen image ~/Pictures/your-wallpaper.jpg
```

### 10. Flatpak Theming

Allow Flatpak applications to read your GTK themes and icons:

```bash
flatpak --user override --filesystem=xdg-config/gtk-3.0:rw
flatpak --user override --filesystem=xdg-config/gtk-4.0:rw
flatpak --user override --filesystem=~/.local/share/icons/:ro
flatpak --user override --filesystem=~/.icons/:ro
flatpak --user override --filesystem=/usr/share/icons/:ro
```

> **⚠️ Important:** You must install Flatpak applications using the `--user` flag (e.g., `flatpak --user install flathub org.gnome.Calculator`), and **not** `flatpak install ...` at the system level. If you install them system-wide, the apps will never adapt to your dynamically generated color themes.

---

## ⌨️ Keybinds

Here is a list of the main keyboard shortcuts used in this configuration.

### Apps & Launchers
| Shortcut | Action |
|---|---|
| **Super + K** | Terminal (Kitty) |
| **Super + Return** | Terminal (wezterm) |
| **Super + E** | File Manager (Nautilus) |
| **Super + Shift + E** | Terminal File Manager (Yazi) |
| **Super + 2** | Zen Browser |
| **Alt + Space** | App Launcher (Rofi) |
| **Super + W** | Wallpaper Selector |
| **Super + V** | Clipboard History (Clipse GUI) |
| **Super + .** | Emoji Picker (HyprEmoji) |
| **Print** | Screenshot / Recording |

### Window Management
| Shortcut | Action |
|---|---|
| **Ctrl + Q** | Close active window |
| **Alt + Tab** / **Super + Tab** | Window switcher (Snappy Switcher) |
| **Super + F** | Toggle Floating / Center window |
| **Super + Up/Down** | Maximize / Restore window |
| **Alt + Arrows** | Move focus |
| **Super + Alt + Arrows**| Swap window position |
| **Super + Shift + Arrows**| Snap window to screen half |
| **Super + Mouse Drag** | Move/Resize floating window |
| **Ctrl + Shift + R** | Enter Resize Mode (Use arrows, ESC to exit) |

### Workspaces & System
| Shortcut | Action |
|---|---|
| **Super + 1..0** <br> **Super + PgUp/PgDn** | Switch to workspace |
| **Super + Shift + 1..0** <br> **Super + Shift + PgUp/PgDn** | Move window to workspace |
| **Super + H** | Toggle Special/Scratchpad Workspace |
| **Super + Shift + H** | Move window to Special Workspace |
| **Super + P** | Toggle Extended/Mirrored Monitor |
| **Super + L** | Power Menu (Wlogout) |
| **Super + Shift + C** | Reload Hyprland Configuration |

---

## Help Wanted: Hyprpolkitagent Theming

I haven't been able to figure out how to properly theme the `hyprpolkitagent` authentication window yet. 

If anyone knows how to apply custom GTK/Matugen styling to it, I would greatly appreciate your help! Please feel free to open a **Pull Request** or an issue to show me how it's done.
