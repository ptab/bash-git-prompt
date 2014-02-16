# Informative git prompt for bash

A ``bash`` script that displays information about the current git location. In particular the branch name, difference with remote branch, number of files staged, changed, etc.

This script is based on the original work of magicmonty (https://github.com/magicmonty/bash-git-prompt).
In this fork I dropped a lot of stuff I didn't actually need, and modified the main behaviour: instead of setting your prompt, it outputs a colored string that you can include wherever you need. 

## How it looks

The output of the script (included in a prompt) looks like the following: 

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
