---
name: code-review
description: Review code changes for bugs, security issues, and quality. Use when the user asks to review, check, or audit code.
context: fork
agent: Explore
---

Review the current changes (or the files/diff provided) and report:

## What to check

1. **Correctness** — logic errors, off-by-ones, null/undefined cases, unhandled errors.
2. **Security** — input validation, injection risks, hardcoded secrets, overly broad permissions.
3. **Performance** — unnecessary loops, N+1 queries, missing indexes, large allocations.
4. **Maintainability** — naming clarity, function length, duplication, missing tests.
5. **Conventions** — does it match the existing code style and project patterns?

## Output format

For each issue found:
- **File + line** reference
- **Severity**: Critical / Warning / Suggestion
- **What's wrong** and **how to fix it**

End with a brief summary: overall quality, top concerns, and whether it's ready to merge.

If no issues are found, say so explicitly.
