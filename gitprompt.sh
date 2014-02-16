#!/bin/bash

# define colors

BLACK="\e[30m"
BLACK_HI="\e[90m"
RED="\e[31m"
RED_HI="\e[91m"
GREEN="\e[32m"
GREEN_HI="\e[92m"
YELLOW="\e[33m"
YELLOW_HI="\e[93m"
BLUE="\e[34m"
BLUE_HI="\e[94m"
CYAN="\e[36m"
CYAN_HI="\e[96m"
WHITE="\e[37m"
WHITE_HI="\e[97m"
RESET="\e[0m"

# define prompt variables

PROMPT_START="${BLACK_HI}("       # start of the git info string
PROMPT_END="${BLACK_HI})"         # the end of the git info string
PROMPT_SEPARATOR="${BLACK_HI}|"   # separates each item
PREFIX_BRANCH="${BLUE_HI}"        # the git branch that is active in the current directory
PREFIX_STAGED="${GREEN_HI}✚"      # the number of staged files/directories
PREFIX_CONFLICTS="${RED_HI}✖"     # the number of files in conflict
PREFIX_CHANGED="${GREEN}●"        # the number of changed files
PREFIX_UNTRACKED="${BLUE}…"       # the number of untracked files/dirs
PREFIX_STASHED="${YELLOW}⚑"         # the number of stashed files/dir


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

repo=`git rev-parse --show-toplevel 2> /dev/null`
if [[ $? -ne 0 ]]; then
  # exit if we're not in a git directory  
  exit 0
fi

GIT_STATUS=($($GIT_STATUS_SCRIPT 2>/dev/null))
if [[ -z $GIT_STATUS ]]; then
  # exit if we couldn't retrieve the status
  exit 1
fi

# get the branch status

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

# and then print it out
echo -e "${STATUS}${PROMPT_END}${RESET}"
exit 0 
