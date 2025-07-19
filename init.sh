#!/usr/bin/env bash

# -------------------------------------------------------------------------------
# init.sh - Dotfiles initialization script for new Mac setup
# 
# This script sets up a new Mac with all necessary tools and configurations
# from the dotfiles repository.
#
# Usage: ./init.sh
# -------------------------------------------------------------------------------

set -e  # Exit immediately if a command exits with non-zero status

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print section headers
print_header() {
    echo -e "\n${BLUE}===============================================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${BLUE}===============================================================${NC}\n"
}

# Function to print success messages
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Function to print error messages
print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Function to print info messages
print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Detect Apple Silicon
IS_APPLE_SILICON=false
if [[ $(uname -m) == "arm64" ]]; then
    IS_APPLE_SILICON=true
    print_info "Detected Apple Silicon Mac"
else
    print_info "Detected Intel Mac"
fi

# Check if the script is run from the dotfiles directory
if [[ "$(basename $(pwd))" != "dotfiles" ]]; then
    print_error "This script must be run from the dotfiles directory"
    exit 1
fi

print_header "Dotfiles Setup - Starting initialization"

# Check if Rosetta 2 is installed (Apple Silicon only)
if [[ "$IS_APPLE_SILICON" == true ]]; then
    print_header "Checking for Rosetta 2"
    if ! /usr/bin/pgrep -q oahd; then
        print_info "Installing Rosetta 2..."
        /usr/sbin/softwareupdate --install-rosetta --agree-to-license
        print_success "Rosetta 2 installed successfully"
    else
        print_success "Rosetta 2 is already installed"
    fi
fi

# Check if Homebrew is installed
print_header "Checking for Homebrew"
if ! command -v brew &>/dev/null; then
    print_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for the current session
    if [[ "$IS_APPLE_SILICON" == true ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        
        # Add Homebrew to zshrc for persistence if not already there
        if ! grep -q "eval \"\$(/opt/homebrew/bin/brew shellenv)\"" ~/.zshrc 2>/dev/null; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
        fi
    else
        eval "$(/usr/local/bin/brew shellenv)"
        
        # Add Homebrew to zshrc for persistence if not already there
        if ! grep -q "eval \"\$(/usr/local/bin/brew shellenv)\"" ~/.zshrc 2>/dev/null; then
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zshrc
        fi
    fi
    print_success "Homebrew installed successfully"
else
    print_success "Homebrew is already installed"
fi

# Install packages from Brewfile if it exists
print_header "Installing packages from Brewfile"
if [[ -f "BrewFile" ]]; then
    print_info "Installing packages from BrewFile..."
    brew bundle --file=BrewFile
    print_success "Packages installed successfully"
else
    print_info "BrewFile not found. Installing essential packages..."
    
    # Install essential CLI tools
    brew install git zoxide bat lsd
    
    # Install window management tools
    brew install koekeishiya/formulae/yabai nikitabobko/tap/aerospace
    
    # Install development tools
    brew install go
    
    # Apple Silicon specific optimizations for development tools
    if [[ "$IS_APPLE_SILICON" == true ]]; then
        # Check if any Intel-based tools need special handling
        print_info "Setting up architecture-specific optimizations for Apple Silicon..."
        
        # Add arm64 homebrew to PATH if using multi-arch setup
        if [[ -d "/opt/homebrew" && -d "/usr/local/Homebrew" ]]; then
            echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zshrc
            print_success "Added ARM Homebrew to PATH priority"
        fi
    fi
    
    # Install cask applications
    brew install --cask karabiner-elements visual-studio-code iterm2
    
    print_success "Essential packages installed"
fi

# Install Oh My Zsh if not already installed
print_header "Setting up Oh My Zsh"
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    print_info "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    print_success "Oh My Zsh installed"
else
    print_success "Oh My Zsh is already installed"
fi

# Install Powerlevel10k theme
if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]]; then
    print_info "Installing Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    print_success "Powerlevel10k installed"
else
    print_success "Powerlevel10k is already installed"
fi

# Install ZSH plugins
print_info "Installing ZSH plugins..."
if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    print_success "zsh-syntax-highlighting installed"
else 
    print_success "zsh-syntax-highlighting is already installed"
fi

if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    print_success "zsh-autosuggestions installed"
else
    print_success "zsh-autosuggestions is already installed"
fi

# Create symlinks using the Makefile
print_header "Setting up dotfiles"

# Run make commands
print_info "Setting up ZSH configuration..."
make zsh
print_success "ZSH configuration set up"

print_info "Setting up VSCode configuration..."
make vscode
print_success "VSCode configuration set up"

print_info "Setting up Karabiner Elements configuration..."
make karabiner
print_success "Karabiner configuration set up"

print_info "Setting up Aerospace window manager configuration..."
make aerospace
print_success "Aerospace configuration set up"

print_info "Setting up SSH wrapper tool..."
make ssh
print_success "SSH wrapper set up"

print_info "Setting up Markdown to PDF converter..."
make md2pdf
print_success "Markdown to PDF converter set up"

# Install VSCode extensions
print_header "Installing VSCode extensions"
print_info "This may take a while..."
make vscode-ext
print_success "VSCode extensions installed"


# Final instructions
print_header "Setup Complete!"
print_info "Your dotfiles have been set up successfully!"
print_info "Some additional steps you may want to complete:"
echo -e "  ${PURPLE}1. Restart your terminal to apply ZSH changes${NC}"
echo -e "  ${PURPLE}2. Open Karabiner-Elements and grant permissions${NC}"
echo -e "  ${PURPLE}3. Configure Aerospace permissions in System Preferences > Security & Privacy > Accessibility${NC}"
echo -e "  ${PURPLE}4. Set up your SSH keys and copy them to ~/.ssh/${NC}"
echo -e "  ${PURPLE}5. Run 'p10k configure' to set up your ZSH theme${NC}"

echo ""
print_success "Enjoy your new setup!"