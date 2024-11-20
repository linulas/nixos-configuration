# Linulas NixOS configuration

Welcome to my NixOS configuration repository! This setup is divided into two main flakes: the system configuration [configuration.nix](configuration.nix) and the home-manager configuration [home/default.nix](./home/default.nix). Feel free to explore and customize the configurations as per your requirements. Happy hacking with NixOS!

## Setup

1. **Start by cloning the configuration to your system:**

```bash
git clone https://github.com/linulas/nixos-configuration
```
2. **Copy your hardware-configuration.nix to linulas/nixos-configuration (usually found in /etc/nixos).**

3. **Create local configuration. Start by copying the default configurations:**

```bash
cd /path/to/linulas/nixos-configuration
cp -r ./home/local_default/ ./home/local/
```
Then you can edit the the files in ./home/local/ according to your needs.

4. **Configure sops (optional).**

If you are not going to use sops for managing secrets you can skip this step.

Start by creating .sops.yaml
```bash
touch .sops.yaml
```
Edit the file according to your needs. Example:

```yaml
keys:
  - &primary <your-key>
creation_rules:
  - path_regex: /path/to/your/secrets.yaml$
    key_groups:
    - age:
      - *primary
```

Refer to [sops github](https://github.com/getsops/sops) for reference on how to setup sops, or [this excellent video](https://www.youtube.com/watch?v=G5f6GC7SnhU) by [Vimyoyer](https://www.youtube.com/@vimjoyer) 

## Build

```bash
# Rebuilds the NixOS configuration.
sudo nixos-rebuild switch --flake /path/to/linulas/nixos-configuration#default

# Rebuilds the home-manager configuration.
home-manager switch --flake /path/to/linulas/nixos-configuration/home
```
NOTE: After the first build, you can use the shell aliases for updating:

```bash
# Rebuilds the NixOS configuration.
update

# Rebuilds the home-manager configuration.
updatehome
```

## Upgrade

After build, you can get the latest updates from the current channel with these aliases (this will generate new flake.lock files):

```bash
# Get the latest updates from the current channel
upgrade

# Get the latest update from the current channel for home-manager
upgradehome
```
