# Config Kitty

## Structure

```
~/.config/kitty/
├── kitty.conf          ← config principale
├── globals.conf        ← thème courant (lu au démarrage)
├── theme.conf          ← include du fichier thème (généré automatiquement)
├── themes/             ← thèmes .conf (gérés par kitten themes)
└── scripts/
    ├── apply_theme.sh  ← applique un thème manuellement
    └── theme_switcher.sh ← lance kitten themes + resync globals.conf
```

## Installation

```bash
# 1. Copier les fichiers
cp -r kitty/ ~/.config/kitty/

# 2. Rendre les scripts exécutables
chmod +x ~/.config/kitty/scripts/*.sh

# 3. Télécharger les thèmes via kitten
kitten themes
# → choisir un thème, il sera sauvegardé dans ~/.config/kitty/themes/

# 4. Adapter le thème par défaut dans globals.conf
#    current_theme Catppuccin-Mocha  ← changer selon ce que tu as
```

## Raccourcis

| Raccourci         | Action                        |
|-------------------|-------------------------------|
| `Ctrl+Shift+T`    | Sélecteur de thèmes           |
| `Alt+I`           | Augmenter la police           |
| `Alt+O`           | Diminuer la police            |
| `Ctrl+0`          | Réinitialiser la police       |
| `Ctrl+C`          | Copier                        |
| `Ctrl+V`          | Coller                        |
| `Ctrl+Shift+C`    | Envoyer signal Ctrl+C         |
| `Ctrl+T`          | Nouvel onglet (répertoire courant) |
| `Ctrl+PageUp/Down`| Onglet précédent/suivant      |
| `Ctrl+Shift+Q`    | Fermer onglet                 |
| `Ctrl+Shift+Enter`| Split vertical                |
| `Ctrl+Shift+]/[`  | Fenêtre suivante/précédente   |
| `Super+K`         | Nouvelle fenêtre OS           |
| `Ctrl+F`          | Recherche dans le scrollback  |

## Changer de thème manuellement

```bash
# Via le raccourci Ctrl+Shift+T (depuis Kitty)

# Ou depuis le shell
~/.config/kitty/scripts/apply_theme.sh "Nom-du-theme"
```
