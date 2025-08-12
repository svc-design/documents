# Contributing

This repository follows a Release Flow strategy enhanced with cherry-pick to keep `main` and `release` branches in sync.

## Branches
- `main`: active development for upcoming milestones.
- `release/mvp`: stable branch for the current milestone.
- `feature/*`: feature or bugfix work; branch from `main` for new work or from `release/mvp` for urgent fixes.
- `hotfix/*`: emergency fixes branching from `release/mvp`.

## Workflow
1. Start work on a `feature/*` or `hotfix/*` branch.
2. Submit a PR back into the source branch (`main` or `release/mvp`).
3. For releases, cut `release/<version>` from `main` and tag it.
4. **Hotfixes**:
   - Branch from `release/mvp` and fix the issue.
   - Merge the branch into `release/mvp` and tag (e.g. `mvp-1.0.1`).
   - Forward-port the fix to `main`:
     ```bash
     git checkout main
     git cherry-pick -x <commit>
     ```
5. **Backports**: when a commit from `main` must appear in `release/mvp`, cherry-pick it:
   ```bash
   git checkout release/mvp
   git cherry-pick -x <commit>
   ```
6. Use informative PR titles, e.g. `[backport 1.0] Fix login`, `[hotfix] patch issue`.

## Conflict resolution
When cherry-pick reports conflicts:
```bash
git cherry-pick --continue  # after resolving conflicts
git cherry-pick --abort     # cancel
```

## Tags
Tag each release on `release/mvp` (e.g. `mvp-1.0.x` or `v1.0.x`).

## Testing
Run project tests before opening a PR:
```bash
npm test   # or other project-specific test command
```
