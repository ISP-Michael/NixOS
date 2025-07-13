## ⚡ Quick Start
> [!WARNING]
> You will have to set up your user

```bash
#!/bin/sh
nixos-rebuild switch --use-remote-sudo --flake 'github:ISP-Michael/NixOS#MagicBook'
home-manager switch --flake 'github:ISP-Michael/NixOS#Michael'
```
> [!TIP]
> nixos-rebuild — change system configs (/etc/*/**) and services, download packages  
> home-manager — change files inside ~/.config

## 📁 File Structure
- [📜 flake.nix](flake.nix) — configuration entry point
- [💻 host](host) — system configuration tool entry point
  - [🛠️ scripts](host/scripts)
  - [🔧 services](host/services) — system servcies
  - [⚙️ settings](host/settings) — garbage-collector, cache, features
  - [📦 soft](host/soft) — fonts, packages, virtualization
    - [🌐 programs](host/soft/programs) — packages via options
  - [🧩 system](host/system) — file system, swap
  - [👥 users](host/users) — user settings
- [👤 user](user) — user configuration tool entry point
  - [💭 hyprland](user/hyprland) — not configured via .nix yet
  - [</> programs](user/programs) — declarative program customization
    - [🐚 fish](user/programs/fish) — aliases, functions, plugins
    - [🪛 nh](user/programs/nh) — NixOS management utility
    - [💭 waybar](user/programs/waybar) — bar
  - [💬 services](user/services) — settings up services such as hyprpaper, mako (notifications)
  - [🎨 stylix](user/services) — theme managemant utility
- [🧩 dependencies](dependencies) — dependent files
  - [✉️ fonts](dependencies/fonts)
  - [⾕ from_home](dependencies/from_home) — files from home direcotory
  - [</> git](dependencies/git) — rewriting output of some git commands (git ref{,log})
  - [💭 hypr](dependencies/hypr) — submodule for hyprland configuration
  - [📝 n](dependencies/n) — submodule for neovim configuration
  - [🎥 images](dependencies/images)

> [!NOTE]
> Why Hyprland & Neovim are not configured via nix and included as submodules in the repository?
>
> I prefer fast dynamic configuration, which is impossible by implementing it through regular rebuild of home-manager after each change

## ✨ Desktop Preview
<b>Hyprland</b>
![ff.png](./dependencies/images/fastfetch.png)
<b>Neovim</b>
![n.png](./dependencies/images/n.png)

## 📦 Software
| Soft     | Name                                             |
|----------|--------------------------------------------------|
| OS       | [NixOS](https://nixos.org)                       |
| WM       | [Hyprland](https://hypr.land)                    |
| Theme    | [Stylix](https://nix-community.github.io/stylix) |
| Editor   | [Neovim](https://neovim.io/)                     |
| Bar      | [Waybar](https://github.com/Alexays/Waybar)      |
| Terminal | [Kitty](https://sw.kovidgoyal.net/kitty/)        |
| Shell    | [Fish](https://fishshell.com/)                   |

## ❤️ Thanks
- [TheMaxMur](https://github.com/TheMaxMur/NixOS-Configuration) for the README
- [s0me1newithhand7s](https://github.com/s0me1newithhand7s/reNixos) for the config

