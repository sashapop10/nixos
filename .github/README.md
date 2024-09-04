<h1 align="center">Deep dive into declarative configuration</h1>

<h5 align="center">
  <a href="https://github.com/sashapop10/nixos/issues">
    <img src="https://img.shields.io/github/issues/sashapop10/nixos?color=dd5c89&labelColor=282828&style=for-the-badge&logo=sparkfun&logoColor=dd5c89">
  </a>
  <a href="https://github.com/sashapop10/nixos/stargazers">
    <img src="https://img.shields.io/github/repo-size/sashapop10/nixos?color=9c76ef&labelColor=282828&style=for-the-badge&logo=github&logoColor=9c76ef">
  </a>
  <a href="https://github.com/sashapop10/nixos">
    <img src="https://img.shields.io/badge/NixOS-unstable-blue.svg?style=for-the-badge&labelColor=282828&logo=NixOS&logoColor=2ba1f6&color=2ba1f6">
  </a>
  <a href="https://github.com/sashapop10/nixos/blob/main/.github/LICENCE">
    <img src="https://img.shields.io/static/v1.svg?style=for-the-badge&label=License&message=MIT&colorA=282828&colorB=00b557&logo=unlicense&logoColor=00b557&"/>
  </a>
</h5>

<h5 align="center">

<details open="true">
  <summary><b>👉 Atlas</b> <i>"</i>State of 2024-08-09<i>"</i> 👈</summary><br/>

![Atlas](./assets/atlas.png "State of 2024-08-09")

</details>

<details >
  <summary><b>👉 Hermes</b> <i>"</i>State of 2024-08-22<i>"</i> 👈</summary><br/>

![Hermes](./assets/hermes.jpg "State of 2024-08-22")

</details>

</h5>

## Installation

> [!CAUTION]
>
> Applying custom configurations, especially those related to your operating system, can have unexpected consequences and may interfere with your system's normal behavior. While I have tested these configurations on my own setup, there is no guarantee that they will work flawlessly for you. I am not responsible for any issues that may arise from using this configuration.

```bash
# Automatic installation
# Working with Live CD
nix-shell -p curl git
./install.sh
```

```bash
# Manual installation
# Working with Live CD
nix-shell -p curl git
curl https://raw.githubusercontent.com/sashapop10/nixos/main/core/hosts/<hostname>/disko.nix > /mnt/config/disko.nix
# Edit disko.nix (Replace device with name from lsblk result at least)
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko /mnt/config/disko.nix
git clone https://github.com/sashapop10/nixos /mnt/flake
sudo nixos-generate-config --dir /mnt/config
mv -f /mnt/config/hardware-configuration.nix /mnt/flake/core/hosts/<hostname>
sudo nixos-install --flake /mnt/flake#<hostname>
# reboot 🚀
```

## Update

```bash
nix-channel --update
nix flake update
sudo nixos-rebuild --upgrade switch --flake .#<hostname>
```

## Rebuild

```bash
git add . # Important if new files were created
sudo nixos-rebuild switch --flake .#<hostname> # If Hosts updated
home-manager switch --flake .#<username>@<hostname> # If ONLY Home updated
```

## Highlights

- Multiple **NixOS configurations**
- Almost fully **Declarative** / **Self-hosted** stuff
- Flexible **Home Manager** Configs through **feature flags**
- Extensively configured wayland environment (**hyprland**) and editors (**nixvim** and **vscode**)
- **Declarative** **themes** and **wallpapers** with **nix-colors**
- **DNS** Encryption and **DPI** fooling
- Host-specific **environment variables**
- Standalone **Home Manager**
- Hosts **state syncing**
- **Auto**matic installation

## Structure

```graphql
/flake.nix                           # Entrypoint
/shell.nix                           # Exposes a dev shell for bootstrapping.
/install.sh                          # Shell script for automatic installation.
/.vscode                             # Makes vscode more performant in this directory.
/.github                             # Docs, assets, workflows
/core
  ├─ /global                         # Global NixOS configurations (auto-imported)
  ├─ /users                          # Users configuration (auto-imported)
  ├─ /options                        # Optional configurations (access via host/configuration.nix)
  └─ /default.nix                    # Loader, imported by hosts/default.nix
/home
  ├─ /global                         # Global Home-manager configurations (auto-imported)
  ├─ /options                        # Optional configurations (access via host/home.nix)
  └─ /default.nix                    # Loader, imported by hosts/default.nix
/hosts
  ├─ /atlas                          # Desktop  32GB RAM, i9-9900k, RTX 2080S & UHD630 | Hyprland
  ├─ /hermes                         # Laptop   16GB RAM, i7-1165G7, Iris XE G7 | Hyprland
  ├─ /iso                            # Minimal ISO image configuration for bootable USB
  ├─ /example
  │  ├─ /configuration.nix           # NixOS Configuration
  │  ├─ /home.nix                    # Home-manager configuration
  │  ├─ /disko.nix                   # Disko configuration       (optional)
  │  ├─ /hardware-configuration.nix  # Hardware configuration    (optional)
  │  ├─ /environment.nix             # Host specific environment (optional)
  │  └─ /host_ed25519.pub            # Ssh ed25519 public key    (optional)
  ├─ /environment.nix                # Global environment
  └─ /default.nix                    # Loader
/library
  ├─ /overlays                       # Patches and custom overrides for some packages.
  ├─ /modules                        # Modules for more accurate customization.
  ├─ /utils                          # Utilities for Nix language.
  └─ /pkgs                           # Self hosted packages
```

<p align="center">
Copyright © 2023-2024 <a href="https://github.com/sashapop10">sashapop10</a>.<br/>
This package is <a href="./LICENSE">MIT licensed</a>.<br/>
</p>

<h5 align="center">
<img href="https://builtwithnix.org" src="https://builtwithnix.org/badge.svg"/>
</h5>
