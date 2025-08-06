## My dotfiles workflow

I use an Ansible playbook to automate my Mac setup. Mapping back to this repo is done [here](https://github.com/guilsa/mac-dev-playbook/blob/master/default.config.yml#L25). The same mac-dev-playbook clones this repo and sets up the dotfiles symlinks, so read the [README](https://github.com/guilsa/mac-dev-playbook/blob/master/README.md).

Target machines must remember to manually git push/pull to keep this repo and dotfiles across machines up-to-date.

## What is not included

SSH keys I may want to reuse are kept in Dropbox, not here. For copying them over, see geerlingguy's notes - [full-mac-setup's SSH setup](https://github.com/guilsa/mac-dev-playbook/blob/master/full-mac-setup.md?plain=1#L74-L77).

## Credit

https://github.com/geerlingguy/mac-dev-playbook