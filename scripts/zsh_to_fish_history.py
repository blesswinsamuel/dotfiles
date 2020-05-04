import os
import re
import mmap


with open(os.path.expanduser('~/.local/share/fish/fish_history'), 'a') as o:
    with open(os.path.expanduser('~/.zsh_history'), encoding='utf-8', errors='ignore') as f:
        ms = re.findall('^:\s+(\d+):\d;(.*?)(?=:\s+\d+:\d;)', f.read(), flags=re.MULTILINE | re.DOTALL)
        for m in ms:
            time, command = m
            command = command.strip()
            command = command.replace("\\\n", "\\n")
            print('raw:', time, command)
            # o.write('- cmd: %s\n  when: %s\n' % (command, time))


# cp ~/.local/share/fish/fish_history .
# cp fish_history ~/.local/share/fish/fish_history && python3 zsh_to_fish_history.py
