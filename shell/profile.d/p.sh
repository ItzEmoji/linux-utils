p() {
    local BASE="/blfs-sources"
    local DEST

    # resolve via fd
    if [ $# -eq 1 ] && [ ! -d "$1" ]; then
        DEST=$(fd -d 1 -t d "$1" "$BASE" | head -n1)
        DEST="${DEST:-$1}"
    else
        DEST="$1"
    fi

    # cd in CURRENT shell (this is the key!)
    builtin cd "$DEST" || return 1

    # only inside BASE
    case "$PWD" in
        $BASE/*) ;;
        *) return 0 ;;
    esac

    # only if .fetch exists
    [ -f ".fetch" ] || return 0

    source .fetch

    # already extracted?
    local COUNT
    COUNT=$(fd -H -E .fetch . | wc -l)
    [ "$COUNT" -gt 0 ] && return 0

    echo "[+] Fetching $(basename "$PWD")"

    [ -f "$FILE" ] || wget --no-check-certificate "$URL"

    if wget --spider "$URL.md5sum" 2>/dev/null; then
        wget --no-check-certificate "$URL.md5sum"
        md5sum -c "$FILE.md5sum" || return 1
    fi

    echo "[+] Extracting (flat)"
    tar -xf "$FILE" --strip-components=1
}
