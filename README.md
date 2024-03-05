# Install

```
git clone https://github.com/amjadameur/nordic-dev.git
cd nordic-dev
./setup.sh
```

## Custom packages

```
Usage: setup.sh [-h|--help] [--param]

Nordic environment for dev: gnome, vim, tmux, git, zsh and more.

Available options:

-h, --help	Print this help and exit
--terminal	Nordic GNOME Terminal	
--gtk		Nordic GNOME GTK
--zsh		Nordic ZSH
--bash		Nordic BASH
--vim		Nordic VIM
--tmux		Nordic TMUX
--git		Nordic GIT

All are installed if no options passed.
```

e.g, install only vim and tmux

```
./setup.sh --vim --tmux
```

Note that the order of options does not impact the setup logic, all dependencies are handled internally.
