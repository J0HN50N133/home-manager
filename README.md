1. Install nix

```sh
# single user is fine
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --no-daemon
```

2. Write private key into `/home/johnsonlee/.ssh/age`

3. Clone this repo and done

```sh
git clone https://github.com/J0HN50N133/home-manager.git ~/.config/home-manager/
cd ~/.config/home-manager
nix --add-experiment-features='flake nix-commands' run nix-pkgs#home-manager -- switch -b backup
```
