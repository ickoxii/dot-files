# Help target to display available targets
help:
	@echo "You may call the following targets `make <target>`"
	@echo "Targets:"
	@echo "all"
	@echo "general-terminal"
	@echo "nvim"
	@echo "bash"
	@echo "zsh"
	@echo "git"
	@echo "vim"
	@echo "latex"
	@echo "skeleton-files"
	@echo "neofetch"
	@echo "spotifycli"
	@echo "spotifyd"
	@echo "spotify-tui"
	@echo "tmux"
	@echo "clean -- Searches for and removes broken sym-links"
.PHONY: help

# Targets
all: general-terminal nvim bash zsh git vim latex skeleton-files neofetch spotifycli tmux
.PHONY: all

general-terminal:
	SRC = $(HOME)/.dotfiles/general-terminal
	DEST = $(HOME)
	ln -sf $(SRC)/.hush_login $(DEST)/.hush_login
	ln -sf $(SRC)/.profile $(DEST)/.profile
.PHONY: general-terminal

# hella shit, just symlink the whole directory lmao
nvim:
	SRC = $(HOME)/\.dotfiles/nvim
	DEST = $(HOME)/\.config/nvim
	ln -sf $(SRC) $(DEST)
.PHONY: nvim

# .bash_aliases .bash_functions .bash_profile .bash_prompt .bashrc
bash:
	SRC = $(HOME)/.dotfiles/bash
	DEST = $(HOME)/ickoxii
	ln -sf $(SRC)/.bash_aliases $(DEST)/.bash_aliases
	ln -sf $(SRC)/.bash_functions $(DEST)/.bash_functions
	ln -sf $(SRC)/.bash_profile $(DEST)/.bash_profile
	ln -sf $(SRC)/.bash_prompt $(DEST)/.bash_prompt
	ln -sf $(SRC)/.bashrc $(DEST)/.bashrc
.PHONY: bash

# .z_aliases .z_profile .z_prompt .zshrc
zsh:
	SRC = $(HOME)/.dotfiles/zsh
	DEST = $(HOME)
	ln -sf $(SRC)/.z_aliases $(DEST)/.z_aliases
	ln -sf $(SRC)/.z_profile $(DEST)/.z_profile
	ln -sf $(SRC)/.z_prompt $(DEST)/.z_prompt
	ln -sf $(SRC)/.zshrc $(DEST)/.zshrc
.PHONY: zsh

git:
	SRC = $(HOME)/.dotfiles/git
	DEST = $(HOME)
	ln -sf $(SRC)/.gitconfig $(DEST)/.gitconfig
.PHONY: git

# .vimrc autocmds.vim colors/ config.vim plugins.vim
vim:
	SRC = $(HOME)/.dotfiles/vim
	DEST = $(HOME)/.vim
	ln -sf $(SRC)/colors $(DEST)/colors
	ln -sf $(SRC)/.vimrc $(HOME)/.vimrc
	ln -sf $(SRC)/autocmds.vim $(DEST)/autocmds.vim
	ln -sf $(SRC)/config.vim $(DEST)/config.vim
	ln -sf $(SRC)/config.vim $(DEST)/plugins.vim
.PHONY: vim

latex:
	SRC = $(HOME)/.dotfiles/latex
	DEST = $(HOME)/.config/latex
	ln -sf $(SRC) $(DEST)
.PHONY: latex

# Fuck-it, symlink the whole directory
# NOTE: we hide .skeleton-files
skeleton-files:
	SRC = $(HOME)/.dotfiles/skeleton-files
	DEST = $(HOME)/.skeleton-files
	ln -sf $(SRC) $(DEST)
.PHONY: skeleton-files

neofetch:
	SRC = $(HOME)/.dotfiles/neofetch
	DEST = $(HOME)/.config/neofetch
	ln -sf $(SRC) $(DEST)
.PHONY: neofetch

# Update symlinks for SpotifyCLI configurations
spotifycli: spotifyd spotify-tui
.PHONY: spotifycli

spotifyd:
	SRC = $(HOME)/.dotfiles/spotifyd
	DEST = $(HOME)/.config/spotifyd
	ln -sf $(SRC) $(DEST)
.PHONY: spotifyd

spotify-tui:
	SRC = $(HOME)/.dotfiles/spotify-tui
	DEST = $(HOME)/.config/spotify-tui
	ln -sf $(SRC) $(DEST)
.PHONY: spotify-tui

tmux:
	SRC = ~/.dotfiles/tmux/.tmux.conf
	DEST = ~/.tmux.conf
	ln -sf $(SRC) $(DEST)
.PHONY: tmux

# Clean symlinks for all specified applications
clean:
.PHONY: clean