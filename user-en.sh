#!/bin/bash

#############################################
#   User Creation Script - Stage 2         #
#   Professional User Setup for Ubuntu     #
#############################################

# Colors and Styles
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Unicode Characters
CHECK="✓"
CROSS="✗"
ARROW="➜"
USER_ICON="👤"

# Clear screen function
clear_screen() {
    clear
}

# Show banner function
show_banner() {
    clear_screen
    echo -e "${CYAN}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════╗
║                                                          ║
║   ██╗   ██╗███████╗███████╗██████╗     ███████╗███████╗ ║
║   ██║   ██║██╔════╝██╔════╝██╔══██╗    ██╔════╝██╔════╝ ║
║   ██║   ██║███████╗█████╗  ██████╔╝    ███████╗█████╗   ║
║   ██║   ██║╚════██║██╔══╝  ██╔══██╗    ╚════██║██╔══╝   ║
║   ╚██████╔╝███████║███████╗██║  ██║    ███████║███████╗ ║
║    ╚═════╝ ╚══════╝╚══════╝╚═╝  ╚═╝    ╚══════╝╚══════╝ ║
║                                                          ║
║                Stage 2: User Creation                    ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Progress display function
show_progress() {
    local message="$1"
    echo -e "${YELLOW}${ARROW}${NC} ${WHITE}${message}${NC}"
}

# Success display function
show_success() {
    local message="$1"
    echo -e "${GREEN}${CHECK}${NC} ${message}"
}

# Error display function
show_error() {
    local message="$1"
    echo -e "${RED}${CROSS}${NC} ${message}"
}

# Info display function
show_info() {
    local message="$1"
    echo -e "${BLUE}ℹ${NC} ${message}"
}

show_banner

echo ""
show_progress "Checking permissions..."

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo ""
    show_error "This script requires root privileges!"
    echo ""
    echo -e "${YELLOW}Please run with:${NC}"
    echo -e "${GREEN}sudo bash user.sh${NC}"
    echo ""
    exit 1
fi

show_success "Root access verified"

echo ""
echo -e "${PURPLE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║${NC}  ${BOLD}${USER_ICON} New User Information${NC}                              ${PURPLE}║${NC}"
echo -e "${PURPLE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Get username
while true; do
    read -p "$(echo -e ${CYAN}Enter username: ${NC})" USERNAME
    
    if [ -z "$USERNAME" ]; then
        show_error "Username cannot be empty!"
        continue
    fi
    
    # Check if user already exists
    if id "$USERNAME" &>/dev/null; then
        show_error "User '$USERNAME' already exists!"
        continue
    fi
    
    # Validate username format
    if [[ ! "$USERNAME" =~ ^[a-z][-a-z0-9]*$ ]]; then
        show_error "Username must start with lowercase letter and contain only letters, numbers, and hyphens"
        continue
    fi
    
    # Check username length
    if [ ${#USERNAME} -lt 3 ]; then
        show_error "Username must be at least 3 characters long"
        continue
    fi
    
    if [ ${#USERNAME} -gt 32 ]; then
        show_error "Username must be less than 32 characters"
        continue
    fi
    
    break
done

show_success "Username '$USERNAME' is valid"

echo ""
show_progress "Installing required packages..."
apt update > /dev/null 2>&1
apt install -y sudo adduser passwd > /dev/null 2>&1
show_success "Required packages installed"

echo ""
echo -e "${YELLOW}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║${NC}  ${BOLD}Creating user '$USERNAME'${NC}
echo -e "${YELLOW}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

show_progress "Creating user account..."
adduser --gecos "" "$USERNAME"

if [ $? -ne 0 ]; then
    echo ""
    show_error "Failed to create user!"
    exit 1
fi

show_success "User '$USERNAME' created successfully"

echo ""
show_progress "Configuring user permissions and groups..."

# Add user to sudo group
show_info "Adding to sudo group..."
usermod -aG sudo "$USERNAME"
show_success "Added to sudo group"

# Add user to additional system groups
show_info "Adding to system groups..."
usermod -aG audio,video,plugdev,netdev,bluetooth "$USERNAME" 2>/dev/null
show_success "System groups configured"

echo ""
show_progress "Creating user directory structure..."
USER_HOME="/home/$USERNAME"

show_info "Creating user folders..."
mkdir -p "$USER_HOME"/{Desktop,Documents,Downloads,Pictures,Videos,Music,Public,Templates}
chown -R "$USERNAME:$USERNAME" "$USER_HOME"
show_success "User directories created"

echo ""
show_progress "Configuring bash environment..."
cat > "$USER_HOME/.bashrc" << 'BASHEOF'
# ~/.bashrc - User bash configuration

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# History settings
HISTCONTROL=ignoreboth
HISTSIZE=5000
HISTFILESIZE=10000
shopt -s histappend

# Check window size after each command
shopt -s checkwinsize

# Make less more friendly for non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Set a fancy prompt (colored)
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='\u@\h:\w\$ '
fi

# Enable color support
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Useful aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias h='history'
alias c='clear'
alias update='sudo apt update && sudo apt upgrade'

# Welcome message with colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  Welcome to Ubuntu on Termux! 👋       ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
echo -e "${GREEN}User:${NC} $USER"
echo -e "${GREEN}Home:${NC} $HOME"
echo -e "${YELLOW}Type 'system-info' for system details${NC}"
echo ""
BASHEOF

chown "$USERNAME:$USERNAME" "$USER_HOME/.bashrc"
show_success "Bash environment configured"

# Create .profile
cat > "$USER_HOME/.profile" << 'PROFILEEOF'
# ~/.profile

# Set PATH
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# Load .bashrc if it exists
if [ -n "$BASH_VERSION" ]; then
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi
PROFILEEOF

chown "$USERNAME:$USERNAME" "$USER_HOME/.profile"

echo ""
show_progress "Creating utility scripts..."

# Create user switch script
SWITCH_SCRIPT="/usr/local/bin/switch-to-$USERNAME"
cat > "$SWITCH_SCRIPT" << SWITCHEOF
#!/bin/bash
echo -e "\033[0;36m╔════════════════════════════════════════╗\033[0m"
echo -e "\033[0;36m║  Switching to user: $USERNAME          \033[0m"
echo -e "\033[0;36m╚════════════════════════════════════════╝\033[0m"
echo ""
su - $USERNAME
SWITCHEOF

chmod +x "$SWITCH_SCRIPT"
show_success "User switch script created"

# Create 'ubuntu' command in Termux to login with this user
show_info "Creating 'ubuntu' command in Termux..."
cat > "/data/data/com.termux/files/usr/bin/ubuntu" << UBUNTUEOF
#!/data/data/com.termux/files/usr/bin/bash

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "\${CYAN}╔════════════════════════════════════════╗\${NC}"
echo -e "\${CYAN}║     Starting Ubuntu as $USERNAME...    ║\${NC}"
echo -e "\${CYAN}╚════════════════════════════════════════╝\${NC}"
echo ""

# Launch Ubuntu with user
proot-distro login ubuntu --user $USERNAME
UBUNTUEOF

chmod +x "/data/data/com.termux/files/usr/bin/ubuntu"
show_success "'ubuntu' command created for user $USERNAME"

# Create user info script
USER_INFO_SCRIPT="/usr/local/bin/userinfo-$USERNAME"
cat > "$USER_INFO_SCRIPT" << USERINFOEOF
#!/bin/bash

echo "╔════════════════════════════════════════╗"
echo "║      User Information                  ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo "Username: $USERNAME"
echo "Home Directory: $USER_HOME"
echo "Groups: \$(groups $USERNAME | cut -d: -f2)"
echo "Shell: \$(getent passwd $USERNAME | cut -d: -f7)"
echo ""
USERINFOEOF

chmod +x "$USER_INFO_SCRIPT"

echo ""
show_progress "Configuring sudo access..."
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$USERNAME"
chmod 0440 "/etc/sudoers.d/$USERNAME"
show_success "Sudo access configured (no password required)"

echo ""
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                          ║${NC}"
echo -e "${GREEN}║        ${CHECK} User Created Successfully!                       ║${NC}"
echo -e "${GREEN}║                                                          ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${PURPLE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║${NC}  ${BOLD}${USER_ICON} User Details${NC}                                         ${PURPLE}║${NC}"
echo -e "${PURPLE}╠══════════════════════════════════════════════════════════╣${NC}"
echo -e "${PURPLE}║${NC}  ${YELLOW}Username:${NC} ${CYAN}$USERNAME${NC}"
echo -e "${PURPLE}║${NC}  ${YELLOW}Home Directory:${NC} ${CYAN}$USER_HOME${NC}"
echo -e "${PURPLE}║${NC}  ${YELLOW}Groups:${NC} ${CYAN}$(groups $USERNAME | cut -d: -f2)${NC}"
echo -e "${PURPLE}║${NC}  ${YELLOW}Sudo Access:${NC} ${GREEN}Enabled (no password)${NC}"
echo -e "${PURPLE}║${NC}  ${YELLOW}Shell:${NC} ${CYAN}/bin/bash${NC}"
echo -e "${PURPLE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  ${BOLD}Useful Commands${NC}                                          ${CYAN}║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}${ARROW}${NC} ${BOLD}Start Ubuntu with your user:${NC}"
echo -e "  ${GREEN}ubuntu${NC}"
echo -e "  ${WHITE}(from Termux - will login as $USERNAME)${NC}"
echo ""
echo -e "${YELLOW}${ARROW}${NC} ${BOLD}Switch to user (inside Ubuntu):${NC}"
echo -e "  ${GREEN}su - $USERNAME${NC}"
echo -e "  ${CYAN}or${NC}"
echo -e "  ${GREEN}switch-to-$USERNAME${NC}"
echo ""
echo -e "${YELLOW}${ARROW}${NC} ${BOLD}View user info:${NC}"
echo -e "  ${GREEN}userinfo-$USERNAME${NC}"
echo ""
echo -e "${YELLOW}${ARROW}${NC} ${BOLD}Next step:${NC}"
echo -e "  ${GREEN}bash /root/end.sh${NC}"
echo -e "  ${WHITE}(Install Desktop Environment & Applications)${NC}"
echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo ""

# Clear screen after 1 second
sleep 1
clear
