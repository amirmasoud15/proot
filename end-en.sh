#!/bin/bash

#############################################
#   Desktop & Software Installer - Stage 3 #
#   Complete Desktop Environment Setup     #
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
GEAR="⚙"
ROCKET="🚀"

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
║   ██████╗ ███████╗███████╗██╗  ██╗████████╗ ██████╗ ██████╗  ║
║   ██╔══██╗██╔════╝██╔════╝██║ ██╔╝╚══██╔══╝██╔═══██╗██╔══██╗ ║
║   ██║  ██║█████╗  ███████╗█████╔╝    ██║   ██║   ██║██████╔╝ ║
║   ██║  ██║██╔══╝  ╚════██║██╔═██╗    ██║   ██║   ██║██╔═══╝  ║
║   ██████╔╝███████╗███████║██║  ██╗   ██║   ╚██████╔╝██║      ║
║   ╚═════╝ ╚══════╝╚══════╝╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝      ║
║                                                          ║
║        Stage 3: Desktop & Software Installation          ║
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

# Progress bar function
show_progress_bar() {
    local current=$1
    local total=$2
    local width=50
    local percent=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    printf "\r${CYAN}["
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "] ${WHITE}%d%%${NC} " $percent
}

show_banner

echo ""
show_progress "Checking system requirements..."

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo ""
    show_error "This script requires root privileges!"
    echo ""
    echo -e "${YELLOW}Please run with:${NC}"
    echo -e "${GREEN}sudo bash end.sh${NC}"
    echo ""
    exit 1
fi

show_success "Root access verified"

export DEBIAN_FRONTEND=noninteractive

# Detect architecture for Box64/Box86
ARCH=$(uname -m)
show_info "System architecture: ${CYAN}${ARCH}${NC}"

echo ""
echo -e "${PURPLE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║${NC}  ${BOLD}${GEAR} Installation Overview${NC}                                  ${PURPLE}║${NC}"
echo -e "${PURPLE}╠══════════════════════════════════════════════════════════╣${NC}"
echo -e "${PURPLE}║${NC}  ${YELLOW}•${NC} XFCE Desktop Environment                              ${PURPLE}║${NC}"
echo -e "${PURPLE}║${NC}  ${YELLOW}•${NC} TigerVNC Server                                       ${PURPLE}║${NC}"
echo -e "${PURPLE}║${NC}  ${YELLOW}•${NC} Firefox Web Browser                                   ${PURPLE}║${NC}"
echo -e "${PURPLE}║${NC}  ${YELLOW}•${NC} Box64 (x86_64 emulator)                               ${PURPLE}║${NC}"
echo -e "${PURPLE}║${NC}  ${YELLOW}•${NC} Box86 (x86 emulator)                                  ${PURPLE}║${NC}"
echo -e "${PURPLE}║${NC}  ${YELLOW}•${NC} Wine (Windows compatibility layer)                    ${PURPLE}║${NC}"
echo -e "${PURPLE}║${NC}  ${YELLOW}•${NC} Additional utilities & tools                          ${PURPLE}║${NC}"
echo -e "${PURPLE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

show_warning "This process may take 30-60 minutes depending on your internet speed"
echo ""
read -p "$(echo -e ${CYAN}Press Enter to continue...${NC})"

# Step 1: System Update
echo ""
echo -e "${YELLOW}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║${NC}  ${BOLD}Step 1/7: Updating System${NC}                               ${YELLOW}║${NC}"
echo -e "${YELLOW}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

show_progress "Updating package lists..."
apt update > /dev/null 2>&1
show_success "Package lists updated"

show_progress "Upgrading installed packages..."
apt upgrade -y > /dev/null 2>&1
show_success "System upgraded"

sleep 1
clear

# Step 2: Install Desktop Environment
echo ""
echo -e "${YELLOW}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║${NC}  ${BOLD}Step 2/7: Installing XFCE Desktop${NC}                       ${YELLOW}║${NC}"
echo -e "${YELLOW}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

show_progress "Installing XFCE4 and components..."
apt install -y xfce4 xfce4-goodies dbus-x11 xfce4-terminal > /dev/null 2>&1
show_success "XFCE Desktop Environment installed"

sleep 1
clear

# Step 3: Install VNC Server
echo ""
echo -e "${YELLOW}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║${NC}  ${BOLD}Step 3/7: Installing VNC Server${NC}                         ${YELLOW}║${NC}"
echo -e "${YELLOW}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

show_progress "Installing TigerVNC Server..."
apt install -y tigervnc-standalone-server tigervnc-common > /dev/null 2>&1
show_success "TigerVNC Server installed"

sleep 1
clear

# Step 4: Install Firefox
echo ""
echo -e "${YELLOW}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║${NC}  ${BOLD}Step 4/7: Installing Firefox Browser${NC}                    ${YELLOW}║${NC}"
echo -e "${YELLOW}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

show_progress "Installing Firefox..."
apt install -y firefox > /dev/null 2>&1
show_success "Firefox installed"

sleep 1
clear

# Step 5: Install Box64 (for ARM64 only)
echo ""
echo -e "${YELLOW}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║${NC}  ${BOLD}Step 5/7: Installing Box64 Emulator${NC}                     ${YELLOW}║${NC}"
echo -e "${YELLOW}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

if [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
    show_progress "Installing build dependencies..."
    apt install -y wget git build-essential cmake > /dev/null 2>&1
    show_success "Build tools installed"
    
    show_progress "Cloning Box64 repository..."
    cd /tmp
    rm -rf box64
    git clone https://github.com/ptitSeb/box64.git > /dev/null 2>&1
    show_success "Repository cloned"
    
    show_progress "Building Box64 (this may take 10-15 minutes)..."
    cd box64
    mkdir -p build
    cd build
    cmake .. -DARM_DYNAREC=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo > /dev/null 2>&1
    make -j$(nproc) > /dev/null 2>&1
    make install > /dev/null 2>&1
    ldconfig
    show_success "Box64 installed successfully"
else
    show_warning "Box64 skipped (only for ARM64 architecture)"
fi

sleep 1
clear

# Step 6: Install Box86
echo ""
echo -e "${YELLOW}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║${NC}  ${BOLD}Step 6/7: Installing Box86 Emulator${NC}                     ${YELLOW}║${NC}"
echo -e "${YELLOW}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

if [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" || "$ARCH" == "armv7l" || "$ARCH" == "armv8l" ]]; then
    show_progress "Cloning Box86 repository..."
    cd /tmp
    rm -rf box86
    git clone https://github.com/ptitSeb/box86.git > /dev/null 2>&1
    show_success "Repository cloned"
    
    show_progress "Building Box86 (this may take 10-15 minutes)..."
    cd box86
    mkdir -p build
    cd build
    cmake .. -DARM_DYNAREC=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo > /dev/null 2>&1
    make -j$(nproc) > /dev/null 2>&1
    make install > /dev/null 2>&1
    ldconfig
    show_success "Box86 installed successfully"
else
    show_warning "Box86 skipped (only for ARM architecture)"
fi

sleep 1
clear

# Step 7: Install Wine
echo ""
echo -e "${YELLOW}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║${NC}  ${BOLD}Step 7/7: Installing Wine${NC}                               ${YELLOW}║${NC}"
echo -e "${YELLOW}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

show_progress "Adding i386 architecture..."
dpkg --add-architecture i386 2>/dev/null
apt update > /dev/null 2>&1
show_success "Architecture added"

show_progress "Installing Wine packages..."
apt install -y wine wine32 wine64 winetricks > /dev/null 2>&1
show_success "Wine installed"

sleep 1
clear

# Install additional useful packages
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  ${BOLD}Installing Additional Tools${NC}                             ${CYAN}║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

show_progress "Installing utilities..."
apt install -y \
    xterm \
    thunar \
    gedit \
    mousepad \
    vlc \
    htop \
    neofetch \
    screenfetch \
    fonts-noto \
    fonts-noto-color-emoji \
    fonts-liberation \
    pulseaudio \
    pavucontrol \
    file-roller \
    ristretto \
    galculator > /dev/null 2>&1
show_success "Additional tools installed"

sleep 1
clear

# Configure VNC Server
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  ${BOLD}Configuring VNC Server${NC}                                   ${CYAN}║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

show_progress "Creating VNC startup script..."

cat > /usr/local/bin/start-vnc << 'VNCEOF'
#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

VNC_PORT=5901
DISPLAY_NUM=1

echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║     Starting VNC Server...             ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
echo ""

# Create VNC directory
mkdir -p ~/.vnc

# Configure xstartup
cat > ~/.vnc/xstartup << 'XSTARTEOF'
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
export XKL_XMODMAP_DISABLE=1
export XDG_CURRENT_DESKTOP="XFCE"
export XDG_SESSION_TYPE="x11"

# Start XFCE
dbus-launch --exit-with-session startxfce4 &
XSTARTEOF

chmod +x ~/.vnc/xstartup

# Start VNC server
echo -e "${YELLOW}Starting VNC on display :${DISPLAY_NUM}...${NC}"
vncserver :$DISPLAY_NUM -geometry 1920x1080 -depth 24

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   VNC Server Started Successfully!     ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Connection Information:${NC}"
    echo -e "${YELLOW}  Address: ${NC}localhost:$VNC_PORT"
    echo -e "${YELLOW}  Display: ${NC}:$DISPLAY_NUM"
    echo -e "${YELLOW}  Resolution: ${NC}1920x1080"
    echo ""
    echo -e "${CYAN}To connect:${NC}"
    echo -e "${YELLOW}  1. Install a VNC Viewer app${NC}"
    echo -e "${YELLOW}  2. Connect to: localhost:$VNC_PORT${NC}"
    echo ""
    echo -e "${CYAN}To stop VNC Server:${NC}"
    echo -e "${YELLOW}  stop-vnc${NC}"
    echo ""
else
    echo -e "${RED}Failed to start VNC Server!${NC}"
    echo -e "${YELLOW}Please check the error messages above.${NC}"
fi
VNCEOF

chmod +x /usr/local/bin/start-vnc
show_success "VNC start script created"

# Create VNC stop script
cat > /usr/local/bin/stop-vnc << 'STOPVNCEOF'
#!/bin/bash

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}Stopping VNC Server...${NC}"
vncserver -kill :1 2>/dev/null
vncserver -kill :2 2>/dev/null
echo -e "${GREEN}VNC Server stopped${NC}"
STOPVNCEOF

chmod +x /usr/local/bin/stop-vnc
show_success "VNC stop script created"

# Configure Wine
echo ""
show_progress "Configuring Wine..."
mkdir -p /opt/wine
export WINEPREFIX=/opt/wine
export WINEARCH=win64
show_success "Wine configured"

# Create system info script
echo ""
show_progress "Creating system utilities..."

cat > /usr/local/bin/system-info << 'INFOEOF'
#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║      Ubuntu System Information         ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
echo ""

if command -v neofetch &> /dev/null; then
    neofetch
else
    screenfetch 2>/dev/null || echo "System: Ubuntu 22.04 on Termux"
fi

echo ""
echo -e "${GREEN}Installed Software:${NC}"
echo -e "${YELLOW}  ✓${NC} XFCE Desktop Environment"
echo -e "${YELLOW}  ✓${NC} TigerVNC Server"
echo -e "${YELLOW}  ✓${NC} Firefox Browser"
echo -e "${YELLOW}  ✓${NC} Box64 (x86_64 emulator)"
echo -e "${YELLOW}  ✓${NC} Box86 (x86 emulator)"
echo -e "${YELLOW}  ✓${NC} Wine (Windows compatibility)"
echo ""
echo -e "${CYAN}Useful Commands:${NC}"
echo -e "${YELLOW}  start-vnc${NC}  - Start VNC Server"
echo -e "${YELLOW}  stop-vnc${NC}   - Stop VNC Server"
echo -e "${YELLOW}  firefox${NC}    - Launch Firefox"
echo -e "${YELLOW}  wine${NC}       - Run Windows applications"
echo ""
INFOEOF

chmod +x /usr/local/bin/system-info
show_success "System info script created"

# Create README file
cat > /root/README.txt << 'READMEEOF'
╔════════════════════════════════════════════════════╗
║       Welcome to Ubuntu on Termux! 🚀              ║
╚════════════════════════════════════════════════════╝

INSTALLED SOFTWARE:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ XFCE Desktop Environment - Lightweight & beautiful
✓ TigerVNC Server - Remote desktop access
✓ Firefox - Web browser
✓ Box64 - x86_64 emulator for ARM64
✓ Box86 - x86 emulator for ARM
✓ Wine - Windows application compatibility

QUICK START GUIDE:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Start VNC Server:
   $ start-vnc
   
   Then connect using a VNC Viewer to: localhost:5901

2. Stop VNC Server:
   $ stop-vnc

3. Launch Firefox:
   $ firefox

4. Run Windows applications:
   $ wine program.exe

5. View system information:
   $ system-info

IMPORTANT NOTES:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
• Install a VNC Viewer app to access the desktop
• Set VNC password on first run of start-vnc
• Recommended: At least 2GB free RAM for best performance
• Box64/Box86 may not work with all applications

TROUBLESHOOTING:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
• VNC black screen: Restart with stop-vnc then start-vnc
• Firefox won't start: Check available memory
• Wine errors: Ensure Box64/Box86 are properly installed

RESOURCES:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
• Box64: https://github.com/ptitSeb/box64
• Box86: https://github.com/ptitSeb/box86
• Wine: https://www.winehq.org/

Enjoy your Ubuntu experience! 🎉
READMEEOF

show_success "README file created"

# Cleanup
echo ""
show_progress "Cleaning up temporary files..."
apt autoremove -y > /dev/null 2>&1
apt clean > /dev/null 2>&1
rm -rf /tmp/box64 /tmp/box86
show_success "Cleanup completed"

# Final summary
echo ""
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                          ║${NC}"
echo -e "${GREEN}║        ${ROCKET} Installation Completed Successfully! ${ROCKET}          ║${NC}"
echo -e "${GREEN}║                                                          ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${PURPLE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║${NC}  ${BOLD}Installed Software${NC}                                       ${PURPLE}║${NC}"
echo -e "${PURPLE}╠══════════════════════════════════════════════════════════╣${NC}"
echo -e "${PURPLE}║${NC}  ${GREEN}✓${NC} XFCE Desktop Environment                              ${PURPLE}║${NC}"
echo -e "${PURPLE}║${NC}  ${GREEN}✓${NC} TigerVNC Server                                       ${PURPLE}║${NC}"
echo -e "${PURPLE}║${NC}  ${GREEN}✓${NC} Firefox Browser                                       ${PURPLE}║${NC}"
echo -e "${PURPLE}║${NC}  ${GREEN}✓${NC} Box64 (x86_64 emulator)                               ${PURPLE}║${NC}"
echo -e "${PURPLE}║${NC}  ${GREEN}✓${NC} Box86 (x86 emulator)                                  ${PURPLE}║${NC}"
echo -e "${PURPLE}║${NC}  ${GREEN}✓${NC} Wine (Windows compatibility)                          ${PURPLE}║${NC}"
echo -e "${PURPLE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  ${BOLD}Getting Started${NC}                                          ${CYAN}║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}${ARROW}${NC} ${BOLD}Start VNC Server:${NC}"
echo -e "  ${GREEN}start-vnc${NC}"
echo ""
echo -e "${YELLOW}${ARROW}${NC} ${BOLD}View System Info:${NC}"
echo -e "  ${GREEN}system-info${NC}"
echo ""
echo -e "${YELLOW}${ARROW}${NC} ${BOLD}Read Documentation:${NC}"
echo -e "  ${GREEN}cat /root/README.txt${NC}"
echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo ""

# Clear screen after 1 second
sleep 1
clear
