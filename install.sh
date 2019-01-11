#!/usr/bin/env bash
FILES_DIR="$PWD"
BACKUP_DIR="$HOME/dotfiles_backup"

MAC_FILES=(
  "fish/config.fish" "$HOME/.config/fish/config.fish"
  "fish/functions" "$HOME/.config/fish/functions"
  "tmux.conf" "$HOME/.tmux.conf"
  ".vimrc" "$HOME/.vimrc"
  ".hushlogin" "$HOME/.hushlogin"
)

LINUX_FILES=(
  "fish/config.fish" "$HOME/.config/fish/config.fish"
  "fish/functions" "$HOME/.config/fish/functions"
  "i3" "$HOME/.config/i3"
  "rofi" "$HOME/.config/rofi"
  "dunst" "$HOME/.config/dunst"

  "tmux.conf" "$HOME/.tmux.conf"
  ".vimrc" "$HOME/.vimrc"
  ".Xresources" "$HOME/.Xresources"
  ".Xmodmap" "$HOME/.Xmodmap"
  ".xinitrc" "$HOME/.xinitrc"
  ".xsessionrc" "$HOME/.xsessionrc"
)

FILES=()

DRY_RUN=false

error() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@" >&2
}

if_actual_run() {
  if [ "$DRY_RUN" == "false" ]; then
    "$@"
  fi
}

main() {
  case "$(uname -s)" in
    Darwin)
      echo 'Running on macOS'
      FILES=("${MAC_FILES[@]}")
      ;;
    Linux)
      echo 'Running on Linux'
      FILES=("${LINUX_FILES[@]}")
      ;;
  esac

  for i in "$@"; do
    case $i in
      -n|--dry-run) DRY_RUN='true' ;;
      *) error "Unexpected option ${flag}"; exit 1 ;;
    esac
  done

  if [ "$DRY_RUN" == "true" ]; then
    echo "Dry run"
  fi

  for ((i = 0; i < ${#FILES[@]}; i = $((i + 2)))); do
    file="${FILES[$i]}"
    SRC="$FILES_DIR/${FILES[$i]}"
    DEST=${FILES[$i + 1]}
    BACKUP_DEST="$BACKUP_DIR/$file"
    FILE_OR_DIR=""
    if [[ -d $SRC ]]; then
      FILE_OR_DIR="directory"
    elif [[ -f $SRC ]]; then
      FILE_OR_DIR="file"
    fi

    echo "---- $FILE_OR_DIR: $file -----"
    if [ -L $DEST ]; then
      echo "$DEST is already a symlink"
    else
      echo "Creating directory $(dirname $BACKUP_DEST)"
      if_actual_run mkdir -p $(dirname $BACKUP_DEST)
      if [ -e "$DEST" ]; then
        if [ -e "$BACKUP_DEST" ]; then
          echo "Backup $FILE_OR_DIR $BACKUP_DEST already exists"
          # echo "Removing $FILE_OR_DIR $DEST"
          # if_actual_run rm -rf "$DEST"
        else
          echo "Backing up $FILE_OR_DIR $DEST to $BACKUP_DEST"
          if_actual_run mv "$DEST" "$BACKUP_DEST"
        fi
      fi
      echo "Creating directory $(dirname $DEST)"
      if_actual_run mkdir -p $(dirname $DEST)
      echo "Creating symlink for $FILE_OR_DIR $SRC in $DEST"
      if_actual_run ln -s "$SRC" "$DEST"
      echo "$file done."
    fi
    echo
  done
}

main "$@"
