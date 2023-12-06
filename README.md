[Who inspired me to make this repo?](https://github.com/eieioxyz/Beyond-Dotfiles-in-100-Seconds)

## Steps to bootstrap a new Mac

1. Install Apple's Command Line Tools, which are prerequisites for Git and Homebrew.

```zsh
xcode-select --install
```

2. Clone repo into new directory.

```zsh
git clone https://github.com/Dolfost/dotfiles.git ~/dotfiles --recurse-submodules
```
3. Install Homebrew, followed by the software listed in the Brewfile.
```zsh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew bundle --file ~/dotfiles/Brewfile
cd ~/dotfiles && brew bundle
```

4. Link all config files with dotbot:
```
./install
```


## TODO List

- [x] Learn how to use [`defaults`](https://macos-defaults.com/#%F0%9F%99%8B-what-s-a-defaults-command) to record and restore System Preferences and other macOS configurations.
- [x] Organize these growing steps into multiple script files.
- [x] Automate symlinking and run script files with a bootstrapping tool like [Dotbot](https://github.com/anishathalye/dotbot).
- [x] Revisit the list in [`.zshrc`](.zshrc) to customize the shell.
- [ ] Make a checklist of steps to decommission your computer before wiping your hard drive.
- [x] Create a [bootable USB installer for macOS](https://support.apple.com/en-us/HT201372).
- [ ] Integrate other cloud services into your Dotfiles process (Dropbox, Google Drive, etc.).
- [ ] Find inspiration and examples in other Dotfiles repositories at [dotfiles.github.io](https://dotfiles.github.io/).

## Recommended readings
[Nvim Lua guide](https://neovim.io/doc/user/lua-guide.html)  
