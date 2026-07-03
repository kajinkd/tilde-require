# tilde-require

A thin wrapper around `composer` that changes the default version constraint
written by `composer require` / `composer require-dev`.

Composer normally writes `^x.y` when you run `composer require vendor/pkg`
with no version. This wrapper makes that default `~x.y.z` instead, resolving
the latest stable release of the package and pinning to it with a tilde
constraint (patch-level updates only).

## Behavior

- `composer require vendor/pkg`: no version given, so the latest stable
  version is resolved and the package is required as `vendor/pkg:~x.y.z`.
- `composer require vendor/pkg:^2.0`: version already given, passed through
  to Composer unchanged.
- Any other composer subcommand (`install`, `update`, `dump-autoload`, ...) is
  passed straight through to the real `composer` binary with no changes.

If the latest version has fewer than three segments (e.g. `3.4` or `3`), it's
padded with zeros to always produce a full `~x.y.z` (`~3.4.0`, `~3.0.0`).

## Files

`bin/composer` holds the actual logic (POSIX sh). It finds the real
`composer` binary on `PATH`, skipping its own directory, and re-execs it with
rewritten arguments.

## Shell integration

For fish, `~/.config/fish/functions/composer.fish` calls this script. For
zsh, a `composer()` function in `~/.zshrc` calls it. For bash, a `composer()`
function in `~/.bashrc` calls it.

## Install

1. Clone/copy this directory to `~/local/tilde-require` (any path works, this
   is just the example used below).

2. Run the install script:

   ```sh
   ~/local/tilde-require/install.sh
   ```

   This makes `bin/composer` executable and, for whichever of fish/zsh/bash
   are present on your machine, wires up a `composer` shell function that
   calls it. For fish it writes
   `~/.config/fish/functions/composer.fish` (auto-loaded, no further steps).
   For zsh/bash it appends a marked block to `~/.zshrc` / `~/.bashrc` —
   re-running the script is safe, it skips shells that are already set up.

3. Restart your shell (or `source` the relevant rc file), then verify it's
   active:

   ```sh
   type composer   # should show it's a shell function, not the composer binary
   composer require monolog/monolog   # check composer.json for a ~x.y.z constraint
   ```

## Uninstall

```sh
~/local/tilde-require/uninstall.sh
```

This removes the fish function file and the marked block from `~/.zshrc` /
`~/.bashrc`. It doesn't delete this directory — remove it yourself once
you're done.
