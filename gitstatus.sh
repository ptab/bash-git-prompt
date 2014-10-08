#!/bin/bash
# -*- coding: UTF-8 -*-
# gitstatus.sh -- produce the current git repo status on STDOUT
# Functionally equivalent to 'gitstatus.py', but written in bash (not python).
#
# Alan K. Stebbens <aks@stebbens.org> [http://github.com/aks]

#shopt -s extglob

# helper functions
count_lines() { echo "$1" | egrep -c "^$2" ; }
all_lines() { echo "$1" | grep -v "^$" | wc -l ; }

# change those symbols to whatever you prefer
symbols_ahead='\001\x1B[92m\002↑'
symbols_behind='\001\x1B[31m\002↓'
symbols_prehash=':'

symb_ref=`git symbolic-ref HEAD 2>&1`
# if "fatal: Not a git repo .., then exit
if [[ $symb_ref == fatal:\ Not\ a\ git\ repository* ]]; then
  exit 0
fi

# is HEAD on a branch or detached?
if [[ $symb_ref == fatal:\ *\ not\ a\ symbolic\ ref ]]; then
  # is HEAD a checkout of a tag or a commit?
  tag=`git describe --exact-match`
  if [[ -n "$tag" ]]; then
    head="$tag"
  else
    head="${symbols_prehash}`git rev-parse --short HEAD`"
  fi
else
  head=`git rev-parse --abbrev-ref HEAD`

  remote_name=`git config branch.$head.remote`  
  if [[ -n $remote_name ]]; then
    merge_name=`git config branch.$head.merge`
    remote_ref="refs/remotes/$remote_name/$head"
  
    # get the revision list, and count the leading "<" and ">"
    revgit=`git rev-list --left-right ${remote_ref}...HEAD`
    num_revs=`all_lines "$revgit"`
    num_ahead=`count_lines "$revgit" "^>"`
    num_behind=$(( num_revs - num_ahead ))
    if (( num_behind > 0 )) ; then
      remote="${remote}${symbols_behind}${num_behind}"
    fi
    if (( num_ahead > 0 )) ; then
      remote="${remote}${symbols_ahead}${num_ahead}"
    fi
  fi
fi

if [[ -z "$remote" ]] ; then
  remote='.'
fi

gitstatus=`git diff --name-status 2>&1`
# if the diff is fatal, exit now
if [[ $gitstatus == fatal* ]]; then
  exit 0
fi 

staged_files=`git diff --staged --name-status`
num_changed=$(( `all_lines "$gitstatus"` - `count_lines "$gitstatus" U` ))
num_conflicts=`count_lines "$staged_files" U`
num_staged=$(( `all_lines "$staged_files"` - num_conflicts ))
num_untracked=`git status -s -uall | grep -c "^??"`
if [[ -n "$GIT_PROMPT_IGNORE_STASH" ]]; then
  num_stashed=0
else	
  num_stashed=`git stash list | wc -l`
fi


for w in "$head" "$remote" $num_staged $num_conflicts $num_changed $num_untracked $num_stashed ; do
  echo "$w"
done

exit
