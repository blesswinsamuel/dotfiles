---
name: git-commit
description: Stage all changes and create a conventional commit. Use when the user asks to commit, save, or checkpoint their work.
disable-model-invocation: true
allowed-tools: Bash(git add *) Bash(git commit *) Bash(git status *) Bash(git diff *)
---

## Steps

1. Run `git status` to see what changed.
2. Run `git diff --staged` and `git diff` to understand the changes.
3. Stage all relevant changes with `git add`.
4. Write a conventional commit message:
   - `feat:` new feature
   - `fix:` bug fix
   - `chore:` maintenance, deps, config
   - `refactor:` restructuring without behavior change
   - `docs:` documentation only
   - `test:` test additions or fixes
   - Keep subject line under 72 characters.
   - Add a body if the change needs explanation.
5. Commit with `git commit -m "<message>"`.
6. Show the result with `git log --oneline -1`.
