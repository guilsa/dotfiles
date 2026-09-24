## My dotfiles workflow

I use an Ansible playbook to automate my Mac setup. Mapping back to this repo is done [here](https://github.com/guilsa/mac-dev-playbook/blob/master/default.config.yml#L25). The same mac-dev-playbook clones this repo and sets up the dotfiles symlinks, so read the [README](https://github.com/guilsa/mac-dev-playbook/blob/master/README.md).

Target machines must remember to manually git push/pull to keep this repo and dotfiles across machines up-to-date.

## Zsh aliases

Install the shared aliases with:

```bash
stow -t ~ zsh
```

The machine's `~/.zshrc` must load them:

```zsh
[[ -r ~/.aliases ]] && source ~/.aliases
```

## Shell configuration

Keep shared, non-sensitive shell config in this repository. Keep machine-specific or installer-managed config in the untracked `~/.zshrc.local`. Near the end of `~/.zshrc`, load the local file after shared config:

```zsh
[[ -r ~/.zshrc.local ]] && source ~/.zshrc.local
```

Given installers can be unpredictable, review changes they make to either file. Move portable, non-sensitive settings into a tracked file in this repository, such as `.zshrc` or `zsh/.aliases`. Re-check that the local-file source line remains near the end after installer updates.

With Oh My Zsh's `brew` plugin enabled, Homebrew provides formula completions in its `share/zsh/site-functions` directory and Oh My Zsh adds that directory to `fpath`. `~/.zsh/completions` is for manually installed completions, such as Deno's `_deno.zsh`; the shared `.zshrc` includes it only when the directory exists.

The shared `.zshrc` also retains these optional utility functions: `gsync`, `gamd`, `dockrun`, `denter`, and `knownrm`.

## Public repository

Never commit credentials, API keys, private hosts, or other secrets. Keep machine-specific settings in ignored local files.

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
