#!/bin/sh
# Installs tilde-require: makes bin/composer executable and wires up shell
# integration for whichever shell(s) are detected on this machine.

set -eu

SELF_DIR=$(cd "$(dirname "$0")" && pwd)
BIN_PATH="$SELF_DIR/bin/composer"

MARKER_BEGIN="# >>> tilde-require >>>"
MARKER_END="# <<< tilde-require <<<"

chmod +x "$BIN_PATH"

install_fish() {
    fish_dir="$HOME/.config/fish/functions"
    fish_file="$fish_dir/composer.fish"

    mkdir -p "$fish_dir"
    cat >"$fish_file" <<EOF
function composer
    command $BIN_PATH \$argv
end
EOF
    echo "fish: wrote $fish_file"
}

install_posix_rc() {
    rc_file="$1"
    [ -f "$rc_file" ] || return 0

    if grep -qF "$MARKER_BEGIN" "$rc_file" 2>/dev/null; then
        echo "$(basename "$rc_file"): already installed, skipping"
        return 0
    fi

    {
        printf '\n%s\n' "$MARKER_BEGIN"
        printf 'composer() { "%s" "$@"; }\n' "$BIN_PATH"
        printf '%s\n' "$MARKER_END"
    } >>"$rc_file"
    echo "$(basename "$rc_file"): added composer() function"
}

install_fish
install_posix_rc "$HOME/.zshrc"
install_posix_rc "$HOME/.bashrc"

echo
echo "Done. Restart your shell (or source the relevant rc file) and run:"
echo "  type composer   # should show it's a shell function, not the composer binary"
