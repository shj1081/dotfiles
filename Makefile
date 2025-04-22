# Define project root path
DOTFILES_ROOT := $(shell pwd)

.PHONY: vscode-ext-export vscode-ext vscode zsh szsh karabiner ssh md2pdf aerospace all

all: vscode-ext vscode zsh karabiner ssh aerospace

vscode-ext-export:
	@echo "Exporting vscode extensions..."
	@code --list-extensions > $(DOTFILES_ROOT)/vscode/vscode-ext.txt

vscode-ext:
	@echo "Installing vscode extensions..."
	@echo "Make sure you have the latest version of code installed..."
	@echo "Installing extensions from $(DOTFILES_ROOT)/vscode/vscode-ext.txt..."
	@while read -r line; do \
		code --install-extension $${line}; \
	done < $(DOTFILES_ROOT)/vscode/vscode-ext.txt

vscode:
	@echo "Remove the old symlinks if they exist..."
	@rm -f $(HOME)/Library/Application\ Support/Code/User/settings.json
	@rm -f $(HOME)/Library/Application\ Support/Code/User/keybindings.json
	@echo "Create vscode settings symlink..."
	@ln -sf $(DOTFILES_ROOT)/vscode/settings.json $(HOME)/Library/Application\ Support/Code/User/settings.json
	@ln -sf $(DOTFILES_ROOT)/vscode/keybindings.json $(HOME)/Library/Application\ Support/Code/User/keybindings.json

zsh: 
	@echo "Remove the old symlinks if they exist..."
	@rm -f $(HOME)/.zshrc
	@echo "Create zshrc symlink..."
	@ln -sf $(DOTFILES_ROOT)/.zshrc $(HOME)/.zshrc
	@echo "Sourcing .zshrc..."
	@/bin/zsh -c "source $(HOME)/.zshrc"

szsh: 
	@echo "Sourcing .zshrc..."
	@/bin/zsh -c "source $(HOME)/.zshrc"

karabiner:
	@echo "Setting up Karabiner Elements configuration..."
	@echo "Compiling Karabiner configuration from YAML..."
	@(cd $(DOTFILES_ROOT)/script/karabiner-setup && go run converter.go --yaml rules.yaml)
	@echo "Removing old configuration if it exists..."
	@rm -f $(HOME)/.config/karabiner/karabiner.json
	@echo "Creating Karabiner configuration symlink..."
	@mkdir -p $(HOME)/.config/karabiner
	@ln -sf $(DOTFILES_ROOT)/karabiner/karabiner.json $(HOME)/.config/karabiner/karabiner.json
	@echo "Karabiner configuration setup complete"

ssh:
	@echo "Setting up SSH wrapper script..."
	@echo "Compiling SSH wrapper script..."
	@(cd $(DOTFILES_ROOT)/script/ssh-wrapper && go build -o sc .)
	@echo "Installing SSH wrapper script to /usr/local/bin (requires sudo)..."
	@if [ -f /usr/local/bin/sc ]; then \
		sudo rm -f /usr/local/bin/sc; \
	fi
	@sudo cp $(DOTFILES_ROOT)/script/ssh-wrapper/sc /usr/local/bin/
	@sudo chmod +x /usr/local/bin/sc
	@echo "SSH wrapper script installed successfully"

md2pdf:
	@echo "Settingup md2pdf script..."
	@if [ -f /usr/local/bin/md2pdf ]; then \
		sudo rm -f /usr/local/bin/md2pdf; \
	fi
	@sudo cp $(DOTFILES_ROOT)/script/md2pdf/markdown-to-pdf.py /usr/local/bin/md2pdf
	@sudo chmod +x /usr/local/bin/md2pdf
	@echo "md2pdf script installed successfully"

aerospace:
	@echo "Setting up Aerospace configuration..."
	@echo "Remove the old symlink if it exists..."
	@rm -f $(HOME)/.aerospace.toml
	@echo "Create Aerospace configuration symlink..."
	@ln -sf $(DOTFILES_ROOT)/.aerospace.toml $(HOME)/.aerospace.toml
	@echo "Aerospace configuration setup complete"