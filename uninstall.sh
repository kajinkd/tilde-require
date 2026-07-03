#!/bin/sh
# Removes the shell integration installed by install.sh. Does not delete
# this directory.

set -eu

MARKER_BEGIN="# >>> tilde-require >>>"
MARKER_END="# <<< tilde-require <<<"

remove_fish() {
    fish_file="$HOME/.config/fish/functions/composer.fish"
    if [ -f "$fish_file" ]; then
        rm -f "$fish_file"
        echo "fish: removed $fish_file"
    fi
}

remove_posix_rc() {
    rc_file="$1"
    [ -f "$rc_file" ] || return 0

    if ! grep -qF "$MARKER_BEGIN" "$rc_file" 2>/dev/null; then
        return 0
    fi

    tmp_file=$(mktemp)
    awk -v begin="$MARKER_BEGIN" -v end="$MARKER_END" '
        $0 == begin { skip = 1; next }
        $0 == end { skip = 0; next }
        !skip { print }
    ' "$rc_file" >"$tmp_file"
    mv "$tmp_file" "$rc_file"
    echo "$(basename "$rc_file"): removed composer() function"
}

remove_fish
remove_posix_rc "$HOME/.zshrc"
remove_posix_rc "$HOME/.bashrc"

echo
echo "Done. Restart your shell (or source the relevant rc file)."
echo "Delete this directory manually if you no longer need it."
