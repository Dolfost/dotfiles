So You decided to tinkle with macOS configuration. How brave of You! Good luck
with this rabbithole.

# General
To start off, you can make use of the Brewfile in the repository root to
install all pakages from homebrew:

    brew bundle install 

from the repo root, or specify brewfile
location with `--file`.

# Specifics
## zathura
There is no official zathura build for macOS, so you have to use
[homebrew-zathura](https://github.com/homebrew-zathura/homebrew-zathura). 
Note that zathura requires either
`zathura-pdf-mupdf` or `zathura-pdf-poppler` plugin in order to render PDFs.

    brew install zathura-cb zathura-djvu zathura-pdf-mupdf zathura-ps

After installing required plugins run the 

    d=$(brew --prefix zathura)/lib/zathura ; mkdir -p $d ; for n in cb djvu pdf-mupdf pdf-poppler ps ; do p=$(brew --prefix zathura-$n)/lib$n.dylib ; [[ -f $p ]] && ln -s $p $d ; done

to symlink them to the place zathura can find.

But this is not all --- to make the zathura the default pdf viewer OS-wide you have also to 

    curl https://raw.githubusercontent.com/homebrew-zathura/homebrew-zathura/refs/heads/master/convert-into-app.sh | sh

to make it into app bundle. It should be run after installing new plugins
(obiviously).

#### Uninstall 
It can not be uninstalled without uninstalling dependencies first:

    brew uninstall --force zathura-pdf-mupdf
    brew uninstall --ignore-dependencies --force girara
    brew uninstall zathura

## defaults
The macOS defaults are located in
`defaults.sh` in the repository root. You
can run it as-is to apply all of them at
once.
