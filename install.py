#!/usr/bin/env python3
import platform
import sys
import argparse
import shutil
import os
from pathlib import Path

HOME = Path.home()
THIS_DIR = Path(__file__).resolve().parent
BACKUP_DIR = HOME / ".dotfiles_backup"

# git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"

COMMON_FILES = {
    "fish/config.fish": ".config/fish/config.fish",
    "fish/functions": ".config/fish/functions",

    "zsh/zlogin": ".zlogin",
    "zsh/zlogout": ".zlogout",
    "zsh/zpreztorc": ".zpreztorc",
    "zsh/zprofile": ".zprofile",
    "zsh/zshenv": ".zshenv",
    "zsh/zshrc": ".zshrc",

    "tmux.conf": ".tmux.conf",
    ".vimrc": ".vimrc",
}

MAC_FILES = {
    **COMMON_FILES,

    ".hushlogin": ".hushlogin",
}

LINUX_FILES = {
    **COMMON_FILES,

    "i3": ".config/i3",
    "rofi": ".config/rofi",
    "dunst": ".config/dunst",

    ".Xresources": ".Xresources",
    ".Xmodmap": ".Xmodmap",
    ".xinitrc": ".xinitrc",
    ".xsessionrc": ".xsessionrc",
}

def error(e):
    print(f"[$(date +'%Y-%m-%dT%H:%M:%S%z')]: {e}")

def main():
    parser = argparse.ArgumentParser(description='Install dotfiles.')
    parser.add_argument('--dry-run', '-n', action='store_true', help='dry run')
    args = parser.parse_args()

    p = platform.system()
    files = {}
    if p == "Linux":
        print('Running on Linux')
        files = LINUX_FILES
    elif p == "Darwin":
        print('Running on macOS')
        files = MAC_FILES
    elif p == "Windows":
        print("Unsupported on Windows", file=sys.stderr)
        sys.exit(1)
    else:
        print(f"Unsupported OS {p}", file=sys.stderr)
        sys.exit(1)

    dr = args.dry_run
    if dr:
        print("== DRY RUN ==")

    for src, dst in files.items():
        f = src
        src = THIS_DIR / src
        backup_dst = BACKUP_DIR / dst
        dst = HOME / dst
        # print(src, dst)
        print(f"---- {f} -----")
        if dst.is_symlink():
            print(f"{dst} is already a symlink")
        else:
            if dst.exists():
                # Take backup
                print(f"Creating backup directory {backup_dst.parent}")
                if not dr:
                    backup_dst.parent.mkdir(parents=True, exist_ok=True)
                if backup_dst.exists():
                    print(f"Backup {backup_dst} already exists")
                else:
                    print(f"Backing up {dst} to {backup_dst}")
                    if not dr:
                        shutil.move(dst, backup_dst)

            if not dst.parent.exists():
                print(f"Creating directory {dst.parent}")
                if not dr:
                    dst.parent.mkdir(parents=True, exist_ok=True)

            print(f"Creating symlink for {src} in {dst}")
            if not dr:
                os.symlink(src, dst)

            # print(f"{f} done.")


if __name__ == "__main__":
    main()
