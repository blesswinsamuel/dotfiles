#!/usr/bin/env bash
FILES_DIR="$PWD"
BACKUP_DIR="$HOME/dotfiles_backup"

FILES=("fish/config.fish" "fish/functions" "tmux.conf" ".hushlogin")
DESTINATIONS=("$HOME/.config/fish/config.fish" "$HOME/.config/fish/functions" "$HOME/.tmux.conf" "$HOME/.hushlogin")

dry_run='false'

error() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@" >&2
}

main() {
	while getopts 'n' flag; do
		case "${flag}" in
			n) dry_run='true' ;;
			*) error "Unexpected option ${flag}"; exit 1 ;;
		esac
	done

	if [ "$dry_run" = "true" ]; then
		echo "Dry run"
	fi

	for ((i = 0; i < ${#FILES[@]}; ++i)); do
		file="${FILES[$i]}"
		source="$FILES_DIR/${FILES[$i]}"
		destination=${DESTINATIONS[$i]}
		backup="$BACKUP_DIR/$file"
		echo "---- $file -----"
		if [ -L $destination ]; then
			echo "$destination is already a symlink"
		else
			echo "Creating directory $(dirname $backup)"
			if [ "$dry_run" = "false" ]; then
				mkdir -p $(dirname $backup)
			fi
			if [ -e "$destination" ]; then
				if [ -e "$backup" ]; then
				    echo "Backing file $backup already exists"
				else
				    echo "Backing up file $destination to $backup"
					if [ "$dry_run" = "false" ]; then
						mv "$destination" "$backup"
					fi
				fi
			fi
		    echo "Creating symlink for file $source in $destination"
			if [ "$dry_run" = "false" ]; then
				ln -s "$source" "$destination"
			fi
			echo "$file done."
		fi
		echo
	done
}

main "$@"
