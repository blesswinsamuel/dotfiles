# Coding Agent Rules

## Git
- After file changes, run `git status` and create a clean commit unless told not to.
- Commit only when a coherent task is completed — don't commit partial or broken work.
- Use conventional commits: `feat:`, `fix:`, `chore:`, `refactor:`, `docs:`, `test:`.
- Ask before destructive git actions (force push, reset --hard, branch deletion).

## Code Quality
- Fix root causes, not symptoms. Don't paper over bugs with workarounds.
- Follow existing project conventions — match the style, patterns, and structure already in the codebase.
- When multiple solutions exist, choose the one with the lowest long-term maintenance cost.
- Don't add features, refactor code, or make improvements beyond what was asked.
- Don't add unnecessary comments, docstrings, or type annotations to code you didn't change.

## Testing & Validation
- Run tests, lint, and typecheck when available before committing.
- Don't modify CI checks or test configurations just to make failures pass.

## Safety
- Ask before destructive actions: deleting files, dropping tables, `rm -rf`, amending published commits.
- For large changes, explain the plan first.
- Don't bypass safety checks (e.g. `--no-verify`).

## Grilling / Stress-Testing
- When requested to grill the user, stress-test thinking, or when trigger phrases like "grill me" or `/grill-me` are used:
  - Interview the user relentlessly about every aspect of the plan, decision, or idea until reaching a shared understanding.
  - Walk down each branch of the decision tree, resolving dependencies between decisions one-by-one.
  - For each question, provide your recommended answer.
  - Ask questions one at a time, waiting for feedback on each before continuing.
  - If a fact can be found by exploring the environment (filesystem, tools, etc.), look it up rather than asking. Put decisions to the user and wait for their answer.
  - Do not act on the plan/idea until the user confirms a shared understanding has been reached.

