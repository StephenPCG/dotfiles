#!/bin/bash

## TO See how colors look, try this script
#for i in 0 1; do
#    for j in 3 4; do
#        for k in {0..7}; do
#            echo -ne "\e[$i;$j${k}m[$i;$j${k}m[0m\e[0m "
#        done
#        echo
#    done
#done

RETVAL=$1

prompt_command() {
    local RETVAL=$1
    local RED=$'\E[0;31m'
    local BG_RED=$'\E[0;41m'
    local CYAN=$'\E[0;36m'
    local BG_CYAN=$'\E[0;46m'
    local CLR_COLOR=$'\E[0m'

    ## parse term title
    case "$TERM" in
        screen)
            [[ -n "$_TERM_TITLE" ]] \
                && __TERM_TITLE=$'\033k'"$TERM_TITLE"$'\033\\ ' \
                || __TERM_TITLE=$'\033k'"${HOSTNAME}"$'\033\\ '
            ;;
        xterm*)
            [[ -n "$_TERM_TITLE" ]] \
                && __TERM_TITLE=$'\E]0;'"$TERM_TITLE: ${PWD/$HOME/~}"$'\007' \
                || __TERM_TITLE=$'\E]0;'"${USER}@${HOSTNAME}: ${PWD/$HOME/~}"$'\007'
            ;;
        *)
            __TERM_TITLE=""
    esac

    # parse git branch
    IS_GIT_BRANCH=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/-(git:\1${GIT_IS_DIRTY})/")
    [[ -n "$VIRTUAL_ENV" ]] && IS_VENV="-(pyenv:${VIRTUAL_ENV##*/})"
    [[ -n "$GOENV" ]] && IS_GOENV="-(goenv:${GOENV})"
    [[ -n "$NODE_VIRTUAL_ENV" ]] && IS_NODEENV="-(node:${NODE_VIRTUAL_ENV##*/})"

    ## parse command line color
    if [[ -z "$_IS_REMOTE" ]]; then
        [[ "$RETVAL" -eq 0 ]] && PS1_COLOR="${CYAN}" || PS1_COLOR="${BG_CYAN}"
    else
        [[ "$RETVAL" -eq 0 ]] && PS1_COLOR="${RED}" || PS1_COLOR="${BG_RED}"
    fi

    ## parse return value
    [[ "$RETVAL" -ne 0 ]] \
        && IS_RETURN_VAL="-(\\\$?:$RETVAL)" \
        || IS_RETURN_VAL=""

    ## parse shell level
    # NOTE ps1.sh is evaluated in a subshell, thus SHLVL is 1 greater than actual
    local _SHLVL=$((SHLVL-1))
    [[ "$_SHLVL" -gt 1 ]] \
        && IS_SHLVL="-(SHLVL:$_SHLVL)" \
        || IS_SHLVL=""

    _PS="${__TERM_TITLE}\n"
    _PS+="\[${PS1_COLOR}\]"
    _PS+="(\u)-(\h)-(\w)"
    _PS+="${IS_GIT_BRANCH}"
    _PS+="${IS_VENV}"
    _PS+="${IS_NODEENV}"
    _PS+="${IS_GOENV}"
    _PS+="${IS_SHLVL}"
    _PS+="${IS_RETURN_VAL}"
    _PS+="\[${CLR_COLOR}\]"
    _PS+="\n"
    _PS+="\[${PS1_COLOR}\]"
    _PS+="(! \!)->"
    _PS+="\[${CLR_COLOR}\]"
    _PS+=" "

    echo "$_PS"
    #echo "${__TERM_TITLE}\n\
#\[${PS1_COLOR}\](\u)-(\h)${_IS_SCREEN}-(\w)${IS_GIT_BRANCH}${IS_SHLVL}${IS_RETURN_VAL}\[${CLR_COLOR}\]\n\
#\[${PS1_COLOR}\](! \!)->\[${CLR_COLOR}\] "
}

prompt_command $RETVAL
