# Repository Settings

This file (`settings.yml`) configures GitHub repository settings to enforce **squash and merge** as the only allowed merge method for pull requests.

## Configuration

The key settings that enforce squash and merge:

- `allow_squash_merge: true` - Enables squash merging
- `allow_merge_commit: false` - Disables regular merge commits
- `allow_rebase_merge: false` - Disables rebase merging

## Applying Settings

### Option 1: Using Probot Settings App

1. Install the [Probot Settings app](https://github.com/apps/settings) on your repository
2. The app will automatically apply the settings from this file

### Option 2: Using GitHub CLI

You can apply these settings manually using GitHub CLI:

```bash
gh repo edit --allow-squash-merge --delete-branch-on-merge \
  --enable-auto-merge --disable-merge-commit --disable-rebase-merge
```

### Option 3: Manual Configuration

1. Go to repository Settings
2. Navigate to "General" → "Pull Requests"
3. Under "Allow merge commits", uncheck "Allow merge commits"
4. Under "Allow squash merging", check "Allow squash merging"
5. Under "Allow rebase merging", uncheck "Allow rebase merging"
6. Optionally check "Automatically delete head branches"

## Additional Settings

This configuration also:
- Enables auto-merge for pull requests
- Automatically deletes branches after merge
- Maintains other repository settings like issues, projects, and wiki
