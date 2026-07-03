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
   is just the example used below) and make the script executable:

   ```sh
   chmod +x ~/local/tilde-require/bin/composer
   ```

2. Add the shell integration for whichever shell(s) you use.

   For fish, create `~/.config/fish/functions/composer.fish`:

   ```fish
   function composer
       command $HOME/local/tilde-require/bin/composer $argv
   end
   ```

   Fish auto-loads this file, so no further steps are needed.

   For zsh, add this to `~/.zshrc`, then reload with `source ~/.zshrc`:

   ```sh
   composer() { "$HOME/local/tilde-require/bin/composer" "$@"; }
   ```

   For bash, add the same function to `~/.bashrc`, then reload with
   `source ~/.bashrc`:

   ```sh
   composer() { "$HOME/local/tilde-require/bin/composer" "$@"; }
   ```

   If you installed to a different path, replace `~/local/tilde-require` (or
   `$HOME/local/tilde-require`) above with that path.

3. Verify it's active:

   ```sh
   type composer   # should show it's a shell function, not the composer binary
   composer require monolog/monolog   # check composer.json for a ~x.y.z constraint
   ```

## Uninstall

Remove the `composer` function/file from whichever shell config(s) you're
using, then delete this directory.
