# Midcentury Dark

![Desktop screenshot](images/screenshot.png)

A minimal Sway desktop for Ubuntu 26.04 with a warm, dark palette and sharp corners, plus the tools I use every day around it.

## Palette

Deep blacks and grays with an earthy accent, easy on the eyes and still clear about what's active.

| Element | Color | Hex |
|---|---|---|
| Background | Deep Onyx | `#101010` |
| Background (raised) | Raised Gray | `#252525` |
| Borders | Subtle Outline | `#303030` |
| Foreground | Warm White | `#f6f1ea` |
| Accent | Midcentury Wood | `#afa193` |

Critical alerts and the terminal use muted tones in the same spirit, such as `#cc6666` for red and `#d8a657` for gold.

## Components

| Role | Tool |
|---|---|
| Window manager | Sway (Wayland) |
| Bar | Waybar, with an event-driven volume module and a pomodoro timer |
| Launcher | rofi |
| Terminal | foot |
| Notifications | mako, with snooze and live calendar reminders |
| Lock screen | swaylock-effects, built from source with a patch |
| Displays | kanshi |
| Editor | Neovim 0.12 with lazy.nvim |
| Audio | PipeWire and WirePlumber, with a filter chain for a Blue Snowball mic |
| 2FA | `totp`: codes from age files unlocked by a YubiKey, also published as [jaborvs/totp](https://github.com/jaborvs/totp) |
| Coding agent | omp: config, theme, extensions and skills |
| Font | JetBrainsMono Nerd Font |
| Icons and GTK | Papirus icons, Yaru GTK theme (dark, brown accent) |

## Install

```bash
git clone https://github.com/jaborvs/dotfiles.git ~/Documents/personal/repositories/dotfiles
cd ~/Documents/personal/repositories/dotfiles
./install.sh
```

Run it as your normal user. It calls `sudo` where it needs to, and every step can be rerun safely. It asks what to do:

| Option | What it does |
|---|---|
| 1 | Install the dependencies |
| 2 | Deploy the dotfiles |
| 3 | Both; use this on a new machine |

The dependencies are apt packages, the Chrome, Tailscale, NodeSource and HashiCorp apt repos, a few snaps, swaylock-effects and Oh My Zsh. Neovim, LuaLS, StyLua, shfmt, tree-sitter, age-plugin-fido2-hmac, uv, omp and context-mode go to `~/.local`. Every download is pinned to a version and checked against its SHA-256.

Deploying links everything under `home/` into `~` with [GNU Stow](https://www.gnu.org/software/stow/), file by file (`--no-folding`). Files already in the way are moved to `~/.dotfiles-backup-<date>/` first. Then it applies the GTK theme and enables the filter-chain user service.

## Layout

`home/` mirrors `$HOME`. The deployed files are symlinks into this repo, so editing a config in place edits the repo, and `git status` shows what changed. To track a new file, move it into `home/` at the same path and run `./install.sh` with option 2.

## Secrets and keys

Nothing secret lives in this repo. After a reinstall:

| What | How to get it back |
|---|---|
| SSH and commit signing key | It's an `ed25519-sk` resident key on the YubiKey, so there is nothing to back up. Plug in the key and run `cd ~/.ssh && ssh-keygen -K` (asks for the FIDO PIN) to recreate `id_ed25519_sk_rk_kaladin`. |
| OpenDev SSH key | `~/.ssh/id_ed25519_opendev` isn't backed up. Generate a new one and register it in Gerrit. |
| totp accounts | Restore `~/.local/share/totp/*.age` and `~/.config/totp/recipient` from a private backup. |

There's no ssh-agent: every connection and every signed commit asks for a fingerprint on the key.

OpenDev gets its own passphrase-protected key for now. `review.opendev.org` runs Gerrit 3.13, whose Apache MINA 2.16 rejects FIDO signatures that carry the user-verified flag, and this YubiKey always sets it. Drop the key once OpenDev runs Gerrit 3.14 or later.

## omp proxy

`~/bin/omp` sends omp's traffic through an HTTP proxy on a Tailscale node, which it finds at startup with `tailscale ip -4 dalinar`. If the proxy is unreachable, omp doesn't start. `OMP_DIRECT=1 omp` bypasses the proxy.

## License

MIT, see [LICENSE](LICENSE). Two parts are excluded. The wallpaper `images/frame_106.png` is someone else's work, so this license doesn't cover it. The humanizer skill in `home/.omp/agent/skills/humanizer` keeps its own MIT license, copyright Siqi Chen.
