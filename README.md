# Informative git prompt for bash

A ``bash`` script that displays information about the current git location. In particular the branch name, difference with remote branch, number of files staged, changed, etc.

This script is based on the original work of magicmonty (https://github.com/magicmonty/bash-git-prompt).
In this fork I dropped a lot of stuff I didn't actually need, and modified the main behaviour: instead of setting your prompt, it outputs a colored string that you can include wherever you need.

## How it looks

The output of the script (included in a prompt) looks kinda like the following screenshot. In reality it is a bit outdated, but you get the idea :)

![Example prompt](gitprompt.png)

The symbols are as follows:

  - ``↑n`` : ahead of remote by ``n`` commits
  - ``↓n`` : behind remote by ``n`` commits
  - ``↓m↑n`` : branches diverged, remote by ``m`` commits, yours by ``n`` commits
  - ``✚n`` : there are ``n`` staged files
  - ``●n`` : there are ``n`` unstaged files
  - ``…n`` : there are ``n`` untracked files  
  - ``✖n`` : there are ``n`` unmerged files
  - ``⚑n`` : there are ``n`` stash entries

## How do I make it look like that?

Apply the following to ``~/.bashrc``:

```
BLACK="\[\e[30m\]"
BLACK_HI="\[\e[90m\]"
RED="\[\e[31m\]"
RED_HI="\[\e[91m\]"
GREEN="\[\e[32m\]"
GREEN_HI="\[\e[92m\]"
BLUE="\[\e[34m\]"
BLUE_HI="\[\e[94m\]"
WHITE="\[\e[37m\]"
WHITE_HI="\[\e[97m\]"
RESET="\[\e[0m\]"

COLOR=${GREEN_HI}
BRACKETS=${BLACK_HI}

gitprompt="/path/to/your/bash-git-prompt/gitprompt.sh"
if [[ -f $gitprompt ]] ; then
    export PS1="$BRACKETS\t $COLOR\u$BRACKETS:$WHITE_HI\w\$($gitprompt) $COLOR\$ $RESET"
else
    export PS1="$BRACKETS\t $COLOR\u$BRACKETS:$WHITE_HI\w $COLOR\$ $RESET"
fi
```

This is my personal PS1 configuration, you can always configure it however you want it.
