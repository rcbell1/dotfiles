# dotfiles

Linux config files (bash, nvim, tmux, git, starship) plus a setup script that
installs the whole toolchain into `~/.local` without root.

## Quick start on a new machine

```bash
git clone <this repo> ~/gitrepos/dotfiles
cd ~/gitrepos/dotfiles
./sudo_setup.sh --check   # do the system prerequisites already exist?
./sudo_setup.sh           # only if --check reported something missing
./setup.sh                # everything else, no sudo
./gnome_setup.sh          # native Ubuntu desktop only, skip on WSL
exec bash -l              # pick up the new PATH
```

On a standard Ubuntu image `sudo_setup.sh` has nothing to do, so in practice
`./setup.sh` is the only thing you need to run. It configures the terminal for
you as its last step.

## The scripts

| Script | Needs root | When to run |
| --- | --- | --- |
| `sudo_setup.sh` | yes | Once per machine, and only if prerequisites are missing |
| `setup.sh` | no | To install, and again any time to update |
| `terminal_setup.sh` | no | Automatically, as the `terminal` step of `setup.sh` |
| `gnome_setup.sh` | no | Once per native Ubuntu desktop (refuses to run on WSL) |

`setup.sh` never calls `sudo`. If a prerequisite is missing it names it and
tells you to run `sudo_setup.sh`, rather than escalating on its own, so the
script stays usable on machines where you have no root at all.

### sudo_setup.sh

Installs only what genuinely cannot be installed into `$HOME`: `git`, `curl`,
`tar`, `xz-utils`, `fontconfig`, `tmux`, `libx11-6`, `libxmu6`. It runs
`sudo apt update` and then installs just the missing packages.

`--check` prints installed/missing per package and exits without using sudo.

`apt-get` and `dpkg-deb` are verified rather than installed, since apt needs
them to install anything at all. Two things are deliberately left out:

- `build-essential`, only needed if you compile native npm addons
- `xclip`, because `setup.sh` unpacks it into `~/.local` so that it also works
  on a machine where you have no sudo

### setup.sh

```
./setup.sh                      # install or update everything
./setup.sh --only nvim,ripgrep  # just these steps
./setup.sh --force              # reinstall even when already up to date
./setup.sh --list               # show step names
./setup.sh --help
```

Set `GITHUB_TOKEN` to raise the GitHub API rate limit used for release version
lookups (60/hour unauthenticated, and a run makes about eight calls).

### terminal_setup.sh

Applies the Ubuntu dark colour scheme (aubergine `#300A24` with the Tango
palette) and the UbuntuMono Nerd Font. `setup.sh` runs it as the `terminal`
step, so it rarely needs invoking by hand. Which terminal it configures is
detected at runtime:

- **WSL** - Windows Terminal, by editing `settings.json` on the C: drive. It
  adds an `Ubuntu Dark` scheme, points `profiles.defaults` at it, sets the font
  face, and switches the app theme to dark. It also registers the font for the
  Windows user by copying the `.ttf` files into
  `%LOCALAPPDATA%\Microsoft\Windows\Fonts` and adding an `HKCU` registry value,
  which needs no administrator rights. **Restart Windows Terminal afterwards**
  so a newly registered font is picked up.
- **Native Ubuntu** - GNOME Terminal's default profile, via `gsettings`.

```
./terminal_setup.sh --check     # show what would change, write nothing
./terminal_setup.sh --no-font   # skip registering the font with Windows
```

`settings.json` is copied to `settings.json.bak-<timestamp>` before any write,
and the replacement is validated as JSON first. Re-runs are no-ops.

The scheme is called `Ubuntu Dark` rather than `Ubuntu` on purpose: Windows
Terminal ships a built-in scheme named `Ubuntu` and silently renames any user
scheme that shadows it to `Ubuntu (modified)`, which would make the script
rewrite `settings.json` on every run.

### Screen blanking

`setup.sh` has a `screen-blank` step that stops the screen blanking and
locking on idle. It sets three gsettings keys, so no sudo is needed:

| Key | Value | Equivalent GUI setting |
| --- | --- | --- |
| `org.gnome.desktop.session idle-delay` | `uint32 0` | Power -> Screen Blank -> Never |
| `org.gnome.desktop.screensaver lock-enabled` | `false` | Privacy -> Screen Lock -> off |
| `org.gnome.desktop.screensaver idle-activation-enabled` | `false` | no screensaver on idle |

Skipped on WSL, where Windows owns the lock screen. Automatic suspend is left
alone on purpose, since disabling it on a laptop is rarely wanted; if you do
want that, set `sleep-inactive-ac-type` and `sleep-inactive-battery-type` under
`org.gnome.settings-daemon.plugins.power` to `'nothing'`.

### gnome_setup.sh

The gnome-tweaks settings, applied to the same `gsettings` keys the GUI writes,
so neither sudo nor the `gnome-tweaks` package is needed. Exits immediately on
WSL. Two things are deliberately elsewhere to avoid duplication: terminal
colours belong to `terminal_setup.sh`, and screen blanking is the
`screen-blank` step of `setup.sh`.

| Area | Setting |
| --- | --- |
| Appearance | `Yaru-dark` plus `prefer-dark`, monospace font `UbuntuMono Nerd Font Mono 12` |
| Windows | minimize and maximize titlebar buttons, new windows centred, workspaces span all displays |
| Touchpad | tap to click, natural scrolling |
| Top bar | battery percentage, weekday in the clock |

```
./gnome_setup.sh --check   # show what would change, write nothing
```

Each key is only written when it differs, so the summary reports how much
actually changed and a re-run reports zero.

## Updating

Re-running `./setup.sh` is the upgrade path; it replaces `apt upgrade` for
these tools. Each step resolves the latest upstream version, compares it with
what is installed, and reinstalls only on a mismatch. The summary at the end
reports `INSTALLED`, `UPDATED`, `UP-TO-DATE` or `FAILED` per tool.

Not covered by a re-run:

- Neovim plugins - lazy.nvim owns those; `lazy-lock.json` here is
  version-controlled on purpose. Use `:Lazy update` inside the editor.
- tmux plugin updates - `prefix + U` inside tmux. Missing plugins listed in
  `.tmux.conf` are installed by the `tpm` step of `setup.sh`.
- Anything a previous sudo-based install left in `/usr` or `/snap`. Those go
  stale but are shadowed, because `~/.local/bin` comes first on `PATH`. To
  clean them up (optional, needs root):
  `sudo snap remove nvim; sudo apt remove bat fd-find; sudo rm /usr/local/bin/lazygit`

## What gets installed where

Nothing outside `$HOME`:

```
~/.local/bin                binaries and symlinks
~/.local/opt/<tool>/        unpacked trees (nvim, node, xclip)
~/.local/share/fonts/       UbuntuMono Nerd Font
~/.local/share/dotfiles-setup/  recorded versions for artifacts with no --version
```

| Tool | Source |
| --- | --- |
| nvim | official `nvim-linux-x86_64.tar.gz` release |
| tree-sitter | `cargo install tree-sitter-cli` (rustup if needed). Official linux builds need GLIBC 2.39 / Ubuntu 24.04; Mason is not allowed to own this tool. |
| ripgrep, bat, fd | `x86_64-unknown-linux-musl` release tarballs |
| lazygit | release tarball |
| node, npm, npx | `nodejs.org/dist/latest` (Current, not LTS) |
| starship | vendor install script, `-b ~/.local/bin` |
| uv | vendor install script, then `uv self update` |
| fzf | git clone in `~/.fzf` |
| tpm | git clone in `~/.tmux/plugins/tpm`, then `bin/install_plugins` |
| xclip, wl-clipboard | `.deb` unpacked with `dpkg-deb -x` (no root needed) |
| nerd font | `UbuntuMono.tar.xz` from nerd-fonts releases |

`apt-get download` is used for the clipboard tools because it needs no root:
it only reads the package lists in `/var/lib/apt/lists` and drops the `.deb` in
the working directory, which `dpkg-deb -x` then unpacks into `~/.local/opt`.
Refreshing those lists needs root, reading them does not.

## Clipboard: yank in nvim, ctrl+v anywhere

LazyVim sets `clipboard = "unnamedplus"`, so the only requirement is a working
provider for the `+` register:

- **WSL** - `xclip` under WSLg, whose X11 clipboard is synced with the Windows
  clipboard. If no X11 or Wayland tool is available,
  `nvim/lua/config/options.lua` falls back to `clip.exe` for copy and
  `powershell.exe Get-Clipboard` (CRLF stripped) for paste.
- **Native Linux** - `xclip` on X11, `wl-clipboard` on Wayland.
- **Remote/headless** - Neovim's built-in OSC 52 provider, no setup needed.

`.tmux.conf` picks between `xclip`, `wl-copy` and `clip.exe` the same way.

## Fonts

`setup.sh` installs the nerd font into `~/.local/share/fonts` for Linux GUI
apps, and on WSL `terminal_setup.sh` additionally registers it for the Windows
user so Windows Terminal can use it. Both are automatic; restart the terminal
afterwards.

To undo the Windows-side font install, delete the `UbuntuMonoNerdFontMono-*`
files from `%LOCALAPPDATA%\Microsoft\Windows\Fonts` and remove the matching
values under `HKCU\Software\Microsoft\Windows NT\CurrentVersion\Fonts`.
