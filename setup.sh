#!/usr/bin/env bash
FILES_DIR="$PWD"
BACKUP_DIR="$HOME/dotfiles_backup"

MAC_FILES=(
  "fish/config.fish" "$HOME/.config/fish/config.fish"
  "fish/functions" "$HOME/.config/fish/functions"
  "tmux.conf" "$HOME/.tmux.conf"
  ".hushlogin" "$HOME/.hushlogin"
)

LINUX_FILES=(
  "fish/config.fish" "$HOME/.config/fish/config.fish"
  "fish/functions" "$HOME/.config/fish/functions"

  "tmux.conf" "$HOME/.tmux.conf"

  "i3/config" "$HOME/.config/i3/config"
  "i3/i3blocks.conf" "$HOME/.config/i3/i3blocks.conf"
  "rofi/config.rasi" "$HOME/.config/rofi/config.rasi"
  "rofi/theme.rasi" "$HOME/.config/rofi/theme.rasi"
  "dunst/dunstrc" "$HOME/.config/dunst/dunstrc"

  ".Xresources" "$HOME/.Xresources"
)

FILES=()

DRY_RUN='false'

error() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@" >&2
}

main() {
  for i in "$@"; do
    case $i in
      -m|--mac) FILES=("${MAC_FILES[@]}") ;;
      -l|--linux) FILES=("${LINUX_FILES[@]}") ;;
      -n|--dry-run) DRY_RUN='true' ;;
      *) error "Unexpected option ${flag}"; exit 1 ;;
    esac
  done

  if [ "$DRY_RUN" = "true" ]; then
    echo "Dry run"
  fi

  for ((i = 0; i < ${#FILES[@]}; i = $((i + 2)))); do
    file="${FILES[$i]}"
    source="$FILES_DIR/${FILES[$i]}"
    destination=${FILES[$i + 1]}
    backup="$BACKUP_DIR/$file"
    echo "---- $file -----"
    if [ -L $destination ]; then
      echo "$destination is already a symlink"
    else
      echo "Creating directory $(dirname $backup)"
      if [ "$DRY_RUN" = "false" ]; then
        mkdir -p $(dirname $backup)
      fi
      if [ -e "$destination" ]; then
        if [ -e "$backup" ]; then
            echo "Backing file $backup already exists"
        else
            echo "Backing up file $destination to $backup"
          if [ "$DRY_RUN" = "false" ]; then
            mv "$destination" "$backup"
          fi
        fi
      fi
      echo "Creating directory $(dirname $destination)"
      if [ "$DRY_RUN" = "false" ]; then
        mkdir -p $(dirname $destination)
      fi
      echo "Creating symlink for file $source in $destination"
      if [ "$DRY_RUN" = "false" ]; then
        ln -s "$source" "$destination"
      fi
      echo "$file done."
    fi
    echo
  done
}

main "$@"
