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
    "fish": ".config/fish",
    "tmux.conf": ".tmux.conf",
    ".vimrc": ".vimrc",
    ".gitconfig": ".gitconfig",
}

def get_sublime_files(path):
    return {
        "sublime/Package Control.sublime-settings": path + "/Packages/User/Package Control.sublime-settings",
        "sublime/Preferences.sublime-settings": path + "/Packages/User/Preferences.sublime-settings",
        "sublime/JavaScript (Babel).sublime-settings": path + "/Packages/User/JavaScript (Babel).sublime-settings",
        "sublime/JavaScript.sublime-settings": path + "/Packages/User/JavaScript.sublime-settings",
        "sublime/Default (Linux).sublime-keymap": path + "/Packages/User/Default (Linux).sublime-keymap",
        "sublime/Default (Linux).sublime-mousemap": path + "/Packages/User/Default (Linux).sublime-mousemap",
    }

MAC_FILES = {
    **COMMON_FILES,

    "Brewfile": ".Brewfile",
    ".hushlogin": ".hushlogin",
    "gpg-agent.conf": ".gnupg/gpg-agent.conf",

    **get_sublime_files("Library/Application Support/Sublime Text 3"),
}

LINUX_FILES = {
    **COMMON_FILES,

    **get_sublime_files(".config/sublime-text-3"),
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
