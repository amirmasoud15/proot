#!/data/data/com.termux/files/usr/bin/bash

#############################################
#                                           #
#   Ubuntu Auto Installer for Termux       #
#   Professional Automated Installation    #
#                                           #
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

# Unicode characters for beautiful display
CHECK="✓"
CROSS="✗"
ARROW="➜"
STAR="★"
ROCKET="🚀"

# Script paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROOT_SCRIPT="$SCRIPT_DIR/proot-en.sh"
USER_SCRIPT="$SCRIPT_DIR/user-en.sh"
END_SCRIPT="$SCRIPT_DIR/end-en.sh"

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
    ║   ██╗   ██╗██████╗ ██╗   ██╗███╗   ██╗████████╗██╗   ██╗║
    ║   ██║   ██║██╔══██╗██║   ██║████╗  ██║╚══██╔══╝██║   ██║║
    ║   ██║   ██║██████╔╝██║   ██║██╔██╗ ██║   ██║   ██║   ██║║
    ║   ██║   ██║██╔══██╗██║   ██║██║╚██╗██║   ██║   ██║   ██║║
    ║   ╚██████╔╝██████╔╝╚██████╔╝██║ ╚████║   ██║   ╚██████╔╝║
    ║    ╚═════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝   ╚═╝    ╚═════╝ ║
    ║                                                          ║
    ║          Automated Ubuntu Installer for Termux          ║
    ║                  Ubuntu 25.10 (Oracular)                 ║
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

# Warning display function
show_warning() {
    local message="$1"
    echo -e "${YELLOW}⚠${NC} ${message}"
}

# Loading animation function
loading_animation() {
    local pid=$1
    local message=$2
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) %10 ))
        printf "\r${CYAN}${spin:$i:1}${NC} ${message}"
        sleep 0.1
    done
    printf "\r"
}

# Overall progress display
show_overall_progress() {
    local step=$1
    local total=3
    local percent=$((step * 100 / total))
    local filled=$((percent / 5))
    local empty=$((20 - filled))
    
    echo ""
    echo -e "${BOLD}Overall Progress:${NC}"
    printf "["
    printf "${GREEN}%${filled}s${NC}" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "] ${CYAN}%d%%${NC} (Step %d of %d)\n" $percent $step $total
    echo ""
}

# Check required files
check_files() {
    show_progress "Checking required files..."
    sleep 0.5
    
    local all_exist=true
    
    if [ ! -f "$PROOT_SCRIPT" ]; then
        show_error "File proot-en.sh not found!"
        all_exist=false
    else
        show_success "proot-en.sh found"
    fi
    
    if [ ! -f "$USER_SCRIPT" ]; then
        show_error "File user-en.sh not found!"
        all_exist=false
    else
        show_success "user-en.sh found"
    fi
    
    if [ ! -f "$END_SCRIPT" ]; then
        show_error "File end-en.sh not found!"
        all_exist=false
    else
        show_success "end-en.sh found"
    fi
    
    if [ "$all_exist" = false ]; then
        echo ""
        show_error "Please ensure all files are in the same directory!"
        exit 1
    fi
    
    echo ""
}

# Show system information
show_system_info() {
    echo -e "${PURPLE}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${NC}              ${BOLD}System Information${NC}                        ${PURPLE}║${NC}"
    echo -e "${PURPLE}╠════════════════════════════════════════════════════════╣${NC}"
    echo -e "${PURPLE}║${NC}  Architecture: ${CYAN}$(uname -m)${NC}"
    echo -e "${PURPLE}║${NC}  OS: ${CYAN}Android (Termux)${NC}"
    echo -e "${PURPLE}║${NC}  Install Path: ${CYAN}$HOME/ubuntu${NC}"
    echo -e "${PURPLE}║${NC}  Available Space: ${CYAN}$(df -h $HOME | awk 'NR==2 {print $4}')${NC}"
    echo -e "${PURPLE}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Show main menu
show_main_menu() {
    show_banner
    show_system_info
    
    echo -e "${BOLD}${WHITE}This script will automatically perform the following steps:${NC}"
    echo ""
    echo -e "  ${CYAN}1.${NC} Install Ubuntu 25.10 with PRoot"
    echo -e "  ${CYAN}2.${NC} Create a new user with sudo access"
    echo -e "  ${CYAN}3.${NC} Install XFCE Desktop Environment"
    echo -e "  ${CYAN}4.${NC} Install VNC Server for graphical access"
    echo -e "  ${CYAN}5.${NC} Install Firefox Browser"
    echo -e "  ${CYAN}6.${NC} Install Box64 & Box86 (emulators)"
    echo -e "  ${CYAN}7.${NC} Install Wine for Windows applications"
    echo ""
    
    show_warning "This process may take 1-2 hours"
    show_info "Requires at least 3GB free space and stable internet connection"
    echo ""
    
    echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  Do you want to start the installation?                ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${GREEN}[1]${NC} Yes, start installation"
    echo -e "  ${RED}[2]${NC} No, exit"
    echo ""
    read -p "$(echo -e ${YELLOW}Your choice: ${NC})" choice
    
    case $choice in
        1)
            return 0
            ;;
        2)
            echo ""
            show_info "Installation cancelled"
            exit 0
            ;;
        *)
            show_error "Invalid choice!"
            sleep 2
            show_main_menu
            ;;
    esac
}

# Stage 1: Install PRoot and Ubuntu
install_proot() {
    clear_screen
    show_banner
    show_overall_progress 1
    
    echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  ${BOLD}Stage 1: Installing Ubuntu with PRoot${NC}              ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    show_progress "Starting Ubuntu installation..."
    echo ""
    
    chmod +x "$PROOT_SCRIPT"
    bash "$PROOT_SCRIPT"
    
    if [ $? -ne 0 ]; then
        echo ""
        show_error "Ubuntu installation failed!"
        exit 1
    fi
    
    echo ""
    show_success "Stage 1 completed successfully!"
    echo ""
    show_info "Press Enter to continue..."
    read
}

# Stage 2: Create user
create_user() {
    clear_screen
    show_banner
    show_overall_progress 2
    
    echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  ${BOLD}Stage 2: Creating User in Ubuntu${NC}                   ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    show_info "In this stage, you need to enter Ubuntu and run the scripts"
    echo ""
    
    # Copy files to Ubuntu
    show_progress "Copying files to Ubuntu..."
    cp "$USER_SCRIPT" "$HOME/ubuntu/root/" 2>/dev/null
    cp "$END_SCRIPT" "$HOME/ubuntu/root/" 2>/dev/null
    chmod +x "$HOME/ubuntu/root/user-en.sh"
    chmod +x "$HOME/ubuntu/root/end-en.sh"
    show_success "Files copied"
    echo ""
    
    echo -e "${YELLOW}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║${NC}  ${BOLD}Execute these commands in order:${NC}                    ${YELLOW}║${NC}"
    echo -e "${YELLOW}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${CYAN}1.${NC} Enter Ubuntu:"
    echo -e "     ${GREEN}./start-ubuntu.sh${NC}"
    echo ""
    echo -e "  ${CYAN}2.${NC} Run initial setup:"
    echo -e "     ${GREEN}bash /root/setup.sh${NC}"
    echo ""
    echo -e "  ${CYAN}3.${NC} Create user:"
    echo -e "     ${GREEN}bash /root/user-en.sh${NC}"
    echo ""
    echo -e "  ${CYAN}4.${NC} Install Desktop & Software:"
    echo -e "     ${GREEN}bash /root/end-en.sh${NC}"
    echo ""
    echo -e "  ${CYAN}5.${NC} Exit Ubuntu:"
    echo -e "     ${GREEN}exit${NC}"
    echo ""
    
    show_warning "After running all commands, return to this menu"
    echo ""
    show_info "Press Enter to continue..."
    read
}

# Show final guide
show_final_guide() {
    clear_screen
    show_banner
    
    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}  ${BOLD}${GREEN}${CHECK} Installation Completed Successfully!${NC}               ${GREEN}║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${BOLD}${WHITE}${STAR} Installed Software:${NC}"
    echo ""
    echo -e "  ${GREEN}${CHECK}${NC} Ubuntu 22.04 LTS"
    echo -e "  ${GREEN}${CHECK}${NC} XFCE Desktop Environment"
    echo -e "  ${GREEN}${CHECK}${NC} TigerVNC Server"
    echo -e "  ${GREEN}${CHECK}${NC} Firefox Browser"
    echo -e "  ${GREEN}${CHECK}${NC} Box64 (x86_64 emulator)"
    echo -e "  ${GREEN}${CHECK}${NC} Box86 (x86 emulator)"
    echo -e "  ${GREEN}${CHECK}${NC} Wine (Windows compatibility)"
    echo ""
    
    echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  ${BOLD}Usage Guide${NC}                                          ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${YELLOW}${ARROW}${NC} ${BOLD}Enter Ubuntu:${NC}"
    echo -e "  ${GREEN}./start-ubuntu.sh${NC}"
    echo ""
    
    echo -e "${YELLOW}${ARROW}${NC} ${BOLD}Start VNC Server:${NC}"
    echo -e "  ${GREEN}start-vnc${NC}"
    echo ""
    
    echo -e "${YELLOW}${ARROW}${NC} ${BOLD}Connect to Desktop:${NC}"
    echo -e "  1. Install a VNC Viewer (e.g., VNC Viewer, bVNC)"
    echo -e "  2. Connect to: ${CYAN}localhost:5901${NC}"
    echo ""
    
    echo -e "${YELLOW}${ARROW}${NC} ${BOLD}Useful Commands:${NC}"
    echo -e "  ${CYAN}system-info${NC}    - Display system information"
    echo -e "  ${CYAN}stop-vnc${NC}       - Stop VNC Server"
    echo -e "  ${CYAN}firefox${NC}        - Launch Firefox"
    echo -e "  ${CYAN}wine app.exe${NC}   - Run Windows applications"
    echo ""
    
    echo -e "${PURPLE}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${NC}  ${BOLD}Important Notes${NC}                                     ${PURPLE}║${NC}"
    echo -e "${PURPLE}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${BLUE}•${NC} For more information: ${CYAN}cat /root/README.txt${NC}"
    echo -e "  ${BLUE}•${NC} Set VNC password on first run"
    echo -e "  ${BLUE}•${NC} Recommended: At least 2GB free RAM"
    echo ""
    
    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}           ${BOLD}${ROCKET} Enjoy your Ubuntu experience! ${ROCKET}${NC}           ${GREEN}║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Clear screen after 1 second
    sleep 1
    clear
}

# Main function
main() {
    # Check if running in Termux
    if [ ! -d "/data/data/com.termux" ]; then
        show_error "This script can only run in Termux!"
        exit 1
    fi
    
    # Check files
    check_files
    
    # Show main menu
    show_main_menu
    
    # Stage 1: Install PRoot
    install_proot
    
    # Stage 2: User creation guide
    create_user
    
    # Show final guide
    show_final_guide
}

# Run main program
main
