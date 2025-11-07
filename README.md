## My dotfiles workflow

I use an Ansible playbook to automate my Mac setup. Mapping back to this repo is done [here](https://github.com/guilsa/mac-dev-playbook/blob/master/default.config.yml#L25). The same mac-dev-playbook clones this repo and sets up the dotfiles symlinks, so read the [README](https://github.com/guilsa/mac-dev-playbook/blob/master/README.md).

Target machines must remember to manually git push/pull to keep this repo and dotfiles across machines up-to-date.

# Required Manual Backup Reminder (Important)

**Important:** This dotfiles repository contains a `.zshrc.local` file which is included in the `.gitignore`. Please remember to back up this file individually to Google Drive or Dropbox to avoid losing any personal configurations.

## VSCode User Settings

Please remember to manually setup symlink:

```bash
ln -s $PWD/vscode/settings.json /Users/$USER/Library/Application\ Support/Code/User/settings.json
```

Potential issues to watch out for include:

1. Machine-specific settings: Some settings in your VS Code config might be machine-specific (paths, credentials, local extensions, or theme preferences you only want on one machine). You'll need to decide how to handle these - either keep them separate or use VS Code's multi-machine settings feature.
2. VS Code updates: Occasionally VS Code updates might modify settings.json, which could create merge conflicts or unexpected behavior if you're not careful.

## What is not included

SSH keys I may want to reuse are kept in Dropbox, not here. For copying them over, see geerlingguy's notes - [full-mac-setup's SSH setup](https://github.com/guilsa/mac-dev-playbook/blob/master/full-mac-setup.md?plain=1#L74-L77).

## Credit

https://github.com/geerlingguy/mac-dev-playbook
