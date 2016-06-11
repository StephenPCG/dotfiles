function detect_os() {
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

function source_if_exist() {
    if [ -r "$1" ]; then
        . $1
    fi
}

function _add_to_path() {
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

function append_to_path() {
    _add_to_path "$1" append
}

function prepend_to_path() {
    _add_to_path "$1" prepand
}

function rebuild_gopath() {
    if [ -z "$GOPATH" ]; then
        echo "\$GOPATH is not set, abort."
        return 1
    fi

    if [ -d "$GOPATH" ]; then
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
