.PHONY: vscode zsh szsh

all: vscode zsh	

vscode:
	@echo "remove the old symlinks if they exist..."
	@rm -f $(HOME)/Library/Application\ Support/Code/User/settings.json
	@rm -f $(HOME)/Library/Application\ Support/Code/User/keybindings.json
	@echo "create vscode settings symlink..."
	@ln -sf $(HOME)/dotfiles/vscode/settings.json $(HOME)/Library/Application\ Support/Code/User/settings.json
	@ln -sf $(HOME)/dotfiles/vscode/keybindings.json $(HOME)/Library/Application\ Support/Code/User/keybindings.json

zsh: 
	@echo "remove the old symlinks if they exist..."
	@rm -f $(HOME)/.zshrc
	@echo "create zshrc symlink..."
	@ln -sf $(HOME)/dotfiles/.zshrc $(HOME)/.zshrc
	@echo "Sourcing .zshrc..."
	@/bin/zsh -c "source $(HOME)/.zshrc"

szsh: 
	@echo "Sourcing .zshrc..."
	@/bin/zsh -c "source $(HOME)/.zshrc"