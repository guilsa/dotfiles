#
# .zshrc
#
# -----------------------------------------------------------------------------
# BEGIN
# -----------------------------------------------------------------------------
# @author Guilherme Sa
# @author Jeff Geerling
#

# -----------------------------------------------------------------------------
# BEGIN
# Author: Guilherme Sa
# Purpose: Oh My Zsh + personal env tweaks
# Created: 2025-10-17
# -----------------------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git nvm brew history kubectl history-substring-search web-search)
[[ -d "$HOME/.zsh/completions" ]] && fpath=("$HOME/.zsh/completions" $fpath)
source $ZSH/oh-my-zsh.sh


# -----------------------------------------------------------------------------
# BEGIN
# LESS/MAN HIGHLIGHTING IMPROVEMENTS

# Let less display ANSI colors
export LESS='-R'
export MANPAGER='less -R'

# man page styling
export LESS_TERMCAP_md=$'\e[1;36m'   # bold → bright cyan
export LESS_TERMCAP_me=$'\e[0m'      # end bold

export LESS_TERMCAP_us=$'\e[1;32m'   # underline → bright green
export LESS_TERMCAP_ue=$'\e[0m'      # end underline

export LESS_TERMCAP_so=$'\e[1;33;44m' # standout/search → yellow on blue
export LESS_TERMCAP_se=$'\e[0m'       # end standout
# END
# -----------------------------------------------------------------------------

export EDITOR=vim
export VISUAL="$EDITOR"
setopt HIST_IGNORE_SPACE # Commands prefixed with a space aren't saved to history
# -----------------------------------------------------------------------------
# END
# -----------------------------------------------------------------------------

# ORIGINAL (Jeff Geerling) color prefs — preserved but DISABLED by Guilherme Sa
# Kept here for reference; these settings conflict with my preferred oh-my-zsh colors.
# To restore the original author's behavior, uncomment the lines below.
# unset LSCOLORS
# export CLICOLOR=1
# export CLICOLOR_FORCE=1

# Don't require escaping globbing characters in zsh.
unsetopt nomatch

# ORIGINAL (Jeff Geerling) timelapse between commands — preserved but DISABLED by Guilherme Sa
# Kept here for reference; this setting conflicts with my preferred oh-my-zsh usability.
# To restore the original author's behavior, uncomment the lines below.
# export PS1=$'\n'"%F{green} %*%F %3~ %F{white}"$'\n'"$ "

# Add standard executable directories when present.
typeset -U path
for path_entry in "$HOME/go/bin" "$HOME/.local/bin" /usr/local/bin /opt/homebrew/bin; do
    [[ -d "$path_entry" ]] && path=("$path_entry" $path)
done
unset path_entry

# Bash-style time output.
export TIMEFMT=$'\nreal\t%*E\nuser\t%*U\nsys\t%*S'

# Include alias file (if present) containing aliases for ssh, etc.
if [ -f ~/.aliases ]
then
  source ~/.aliases
fi

# Preview a directory alias, then optionally publish it.
addcd() {
  emulate -L zsh

  if (( $# < 1 || $# > 2 )) || [[ ! "$1" =~ '^[a-zA-Z][a-zA-Z0-9_-]*$' ]]; then
    print -u2 'Usage: addcd <alias-name> [directory]'
    return 2
  fi

  local alias_name="$1" directory="${2:-$PWD}" home_dir="${HOME:A}"
  local alias_file="$HOME/.aliases" resolved_file repo relative command line answer

  if [[ ! -d "$directory" ]]; then
    print -u2 -- "Directory does not exist: $directory"
    return 1
  fi
  directory="${directory:A}"
  if [[ "$directory" != "$home_dir" && "$directory" != "$home_dir"/* ]]; then
    print -u2 'Only directories under $HOME can be published as portable aliases.'
    return 1
  fi

  resolved_file="${alias_file:A}"
  repo="$(git -C "${resolved_file:h}" rev-parse --show-toplevel 2>/dev/null)"
  if [[ -z "$repo" || "$resolved_file" != "$repo/zsh/.aliases" ]]; then
    print -u2 'Expected ~/.aliases to link to this dotfiles repository.'
    return 1
  fi
  if whence -w -- "$alias_name" >/dev/null 2>&1 ||
     grep -Eq "^alias ${alias_name}=" "$resolved_file"; then
    print -u2 -- "Name is already in use: $alias_name"
    return 1
  fi

  if [[ "$directory" == "$home_dir" ]]; then
    command='cd -- "$HOME"'
  else
    relative="${directory#"$home_dir"/}"
    command="cd -- \$HOME/${(q)relative}"
  fi
  line="alias ${alias_name}=${(qq)command}"

  print -r -- "$line"
  print -r -- 'This will be committed and pushed to the public dotfiles repository.'
  printf 'Add, commit, and push? [y/N] '
  read -r answer || return 1
  if [[ "$answer" != [Yy] ]]; then
    print 'No changes made.'
    return 0
  fi

  if ! git -C "$repo" diff --quiet -- zsh/.aliases ||
     ! git -C "$repo" diff --cached --quiet -- zsh/.aliases; then
    print -u2 'The alias file has uncommitted changes; review those first.'
    return 1
  fi
  git -C "$repo" pull --ff-only || return 1
  if grep -Eq "^alias ${alias_name}=" "$resolved_file"; then
    print -u2 -- "Alias was added elsewhere: $alias_name"
    return 1
  fi

  print -r -- "$line" >> "$resolved_file" || return 1
  git -C "$repo" add -- zsh/.aliases || return 1
  git -C "$repo" commit -m "Add ${alias_name} directory alias" -- zsh/.aliases || return 1
  git -C "$repo" push || return 1
  alias "$alias_name=$command"
  print -r -- "Ready: $alias_name"
}

# Case-insensitive completion.
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'

# Git upstream branch syncer.
# Usage: gsync master (checks out master, pull upstream, push origin).
function gsync() {
 if [[ ! "$1" ]] ; then
     echo "You must supply a branch."
     return 0
 fi

 BRANCHES=$(git branch --list $1)
 if [ ! "$BRANCHES" ] ; then
    echo "Branch $1 does not exist."
    return 0
 fi

 git checkout "$1" && \
 git pull upstream "$1" && \
 git push origin "$1"
}

# Amend the last commit, but only when a single file is modified.
function gamd() {
  local modified
  modified=$(git status --porcelain | grep -c '^[^?]')
  if [[ $modified -eq 1 ]]; then
    git add . && git commit --amend
  else
    print -P "%F{red}Aborting (cannot continue because I see multiple files unstaged).%f"
  fi
}

# Tell homebrew to not autoupdate every single time I run it (just once a week).
export HOMEBREW_AUTO_UPDATE_SECS=604800

# Super useful Docker container oneshots.
# Usage: dockrun, or dockrun [centos7|fedora27|debian9|debian8|ubuntu1404|etc.]
# Run on arm64 if getting errors: `export DOCKER_DEFAULT_PLATFORM=linux/amd64`
dockrun() {
 docker run -it geerlingguy/docker-"${1:-ubuntu1604}"-ansible /bin/bash
}

# Enter a running Docker container.
function denter() {
 if [[ ! "$1" ]] ; then
     echo "You must supply a container ID or name."
     return 0
 fi

 docker exec -it $1 bash
 return 0
}

# Delete a given line number in the known_hosts file.
knownrm() {
 re='^[0-9]+$'
 if ! [[ $1 =~ $re ]] ; then
   echo "error: line number missing" >&2;
 else
   sed -i '' "$1d" ~/.ssh/known_hosts
 fi
}

# Allow Composer to use almost as much RAM as Chrome.
export COMPOSER_MEMORY_LIMIT=-1

# Ask for confirmation when 'prod' is in a command string.
#prod_command_trap () {
#  if [[ $BASH_COMMAND == *prod* ]]
#  then
#    read -p "Are you sure you want to run this command on prod [Y/n]? " -n 1 -r
#    if [[ $REPLY =~ ^[Yy]$ ]]
#    then
#      echo -e "\nRunning command \"$BASH_COMMAND\" \n"
#    else
#      echo -e "\nCommand was not run.\n"
#      return 1
#    fi
#  fi
#}
#shopt -s extdebug
#trap prod_command_trap DEBUG

# Universal configurations (version controlled)
# -----------------------------------------------------------------------------
# END
# -----------------------------------------------------------------------------

# Source machine-specific config if it exists
if [[ -f ~/.zshrc.local ]]; then
    source ~/.zshrc.local
fi
