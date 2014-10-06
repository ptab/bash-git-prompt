#!/bin/bash

# general settings

FETCH_TIMEOUT=5

# define colors

BLACK="\001\e[30m\002"
BLACK_HI="\001\e[90m\002"
RED="\001\e[31m\002"
RED_HI="\001\e[91m\002"
GREEN="\001\e[32m\002"
GREEN_HI="\001\e[92m\002"
YELLOW="\001\e[33m\002"
YELLOW_HI="\001\e[93m\002"
BLUE="\001\e[34m\002"
BLUE_HI="\001\e[94m\002"
CYAN="\001\e[36m\002"
CYAN_HI="\001\e[96m\002"
WHITE="\001\e[37m\002"
WHITE_HI="\001\e[97m\002"
RESET="\001\e[0m\002"

# define prompt variables

PROMPT_START="${BLACK_HI}("       # start of the git info string
PROMPT_END="${BLACK_HI})"         # the end of the git info string
PROMPT_SEPARATOR="${BLACK_HI}|"   # separates each item
PREFIX_BRANCH="${BLUE_HI}"        # the git branch that is active in the current directory
PREFIX_STAGED="${GREEN_HI}+"      # the number of staged files/directories
PREFIX_CONFLICTS="${RED_HI}×"     # the number of files in conflict
PREFIX_CHANGED="${GREEN}Δ"        # the number of changed files
PREFIX_UNTRACKED="${BLUE}?"       # the number of untracked files/dirs
PREFIX_STASHED="${YELLOW}ʂ"       # the number of stashed files/dir


# determine path to gitstatus.sh

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

GIT_STATUS_SCRIPT="$DIR/gitstatus.sh"


#
#   Start execution
#

REPO=`git rev-parse --show-toplevel 2> /dev/null`
if [[ $? -ne 0 ]]; then
  # exit if we're not in a git directory  
  exit 0
fi

# fetch from repo if local is stale for more than $FETCH_TIMEOUT minutes
FETCH_HEAD="$REPO/.git/FETCH_HEAD"
if [[ ! -e "${FETCH_HEAD}"  ||  -e `find "${FETCH_HEAD}" -mmin +${FETCH_TIMEOUT}` ]]; then
  if [[ -n $(git remote show) ]]; then
    ( git fetch --quiet &> /dev/null) &
  fi
fi

# retrieve the branch status

GIT_STATUS=($($GIT_STATUS_SCRIPT 2>/dev/null))
if [[ -z $GIT_STATUS ]]; then
  # exit if we couldn't retrieve the status
  exit 1
fi

GIT_BRANCH=${GIT_STATUS[0]}
GIT_REMOTE=${GIT_STATUS[1]}
if [[ "." == $GIT_REMOTE ]]; then
  unset GIT_REMOTE
fi
GIT_STAGED=${GIT_STATUS[2]}
GIT_CONFLICTS=${GIT_STATUS[3]}
GIT_CHANGED=${GIT_STATUS[4]}
GIT_UNTRACKED=${GIT_STATUS[5]}
GIT_STASHED=${GIT_STATUS[6]}


# build the status prompt

STATUS=" ${PROMPT_START}${PREFIX_BRANCH}${GIT_BRANCH}"

if [[ -n $GIT_REMOTE ]]; then
  STATUS="${STATUS}${PROMPT_SEPARATOR}${PREFIX_REMOTE}${GIT_REMOTE}"
fi
if [[ $GIT_STAGED -ne 0 ]]; then
  STATUS="${STATUS}${PROMPT_SEPARATOR}${PREFIX_STAGED}${GIT_STAGED}"
fi
if [[ ${GIT_CONFLICTS} -ne 0 ]]; then
  STATUS="${STATUS}${PREFIX_CONFLICTS}${GIT_CONFLICTS}"
fi
if [[ $GIT_CHANGED -ne 0 ]]; then
  STATUS="${STATUS}${PROMPT_SEPARATOR}${PREFIX_CHANGED}${GIT_CHANGED}"
fi
if [[ $GIT_UNTRACKED -ne 0 ]]; then
  STATUS="${STATUS}${PROMPT_SEPARATOR}${PREFIX_UNTRACKED}${GIT_UNTRACKED}"
fi
if [[ $GIT_STASHED -ne 0 ]]; then
  STATUS="${STATUS}${PROMPT_SEPARATOR}${PREFIX_STASHED}${GIT_STASHED}"
fi

echo -e "${STATUS}${PROMPT_END}${RESET}"
exit 0 
