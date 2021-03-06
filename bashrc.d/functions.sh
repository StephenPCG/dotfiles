detect_os() {
    case $(uname) in
        Linux)
            echo "Linux"
            ;;
        Darwin)
            echo "Darwin"
            ;;
        *)
            echo "Other"
            ;;
    esac
}

get_cache_dir() {
    local os=$(detect_os)
    case $os in
        Darwin)
            echo $HOME/Library/Caches
            ;;
        Linux)
            echo $HOME/.cache
            ;;
        *)
            echo $HOME/.cache
            ;;
    esac
}

source_if_exist() {
    if [ -r "$1" ]; then
        . $1
    fi
}

_add_to_path() {
    newpath=$(echo $1 | sed 's:/*$::')
    direction=${2:-append}
    case ":$PATH:" in
        *":$newpath:"*) :;;
        *)
            if [[ "$direction" == "append" ]]; then
                PATH="$PATH:$newpath"
            else
                PATH="$newpath:$PATH"
            fi
            ;;
    esac
    export PATH
}

append_to_path() {
    _add_to_path "$1" append
}

append_to_path_if_exist() {
    test -e "$1" && _add_to_path "$1" append
}

prepend_to_path() {
    _add_to_path "$1" prepand
}

prepend_to_path_if_exist() {
    test -e "$1" && _add_to_path "$1" prepand
}

remove_path() {
    PATH=${PATH//":$1:"/":"}
    PATH=${PATH/#"$1:"/}
    PATH=${PATH/%":$1"/}
    export PATH
}

rebuild_gopath() {
    if [ -z "$GOPATH" ]; then
        echo "\$GOPATH is not set, abort."
        return 1
    fi

    if [ ! -d "$GOPATH" ]; then
        echo "\$GOPATH ($GOPATH) does not exist, abort."
        return 1
    fi

    if ! (echo $GOPATH | grep -iq 'cache'); then
        answer=
        while [[ -z "$answer" ]]; do
            read -p "\$GOPATH ($GOPATH) seems not in a cache dir, do you really want to purge it? (type 'yes' or 'no') " answer
        done
        if [[ "$answer" != "yes" ]]; then
            echo "abort"
            return 1
        fi
    fi

    if [ -z "$('ls' -A "$GOPATH")" ]; then
        echo "\$GOPATH ($GOPATH) is empty dir, abort."
        return 1
    fi

    set -x
    rm -rf $GOPATH/*
    set +x
}

# Syntax-highlight JSON strings or files
# Usage: `json <filename>` or `echo '{"foo":42}' | json`
json() {
    if [ -t 0 ]; then # argument
        python -mjson.tool < "$1" | pygmentize -l javascript;
    else # pipe
        python -mjson.tool | pygmentize -l javascript;
    fi;
}

# `tre` is a shorthand for `tree` with hidden files and color enabled, ignoring
# the `.git` directory, listing directories first. The output gets piped into
# `less` with options to preserve color and line numbers, unless the output is
# small enough for one screen.
tre() {
    tree -aC -I '.git|node_modules|bower_components' --dirsfirst "$@" | less -FRNX;
}

# code copied from: http://stackoverflow.com/a/4025065
vercomp () {
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}

# output golang coverage html
gocover() {
    local pkg=$1
    local pkg_short=${pkg##*/}
    go test -v -coverprofile=/tmp/cover.$$ $pkg
    go tool cover -html=/tmp/cover.$$ -o /tmp/cover.$pkg_short.html
    echo "Coverage HTML output: /tmp/cover.$pkg_short.html"
}

ipip() {
    curl -s http://freeapi.ipip.net/$1
    echo
}
