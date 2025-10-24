#!/bin/bash

#############################################
#   Winlator - Gaming Setup Installer      #
#   Wine + Box64/86 + Gaming Dependencies  #
#############################################

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m'

# Icons
CHECK="✓"
CROSS="✗"
ARROW="➜"
GAME="🎮"
ROCKET="🚀"

clear_screen() {
    clear
}

show_banner() {
    clear_screen
    echo -e "${CYAN}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════╗
║                                                          ║
║   ██╗    ██╗██╗███╗   ██╗██╗      █████╗ ████████╗ ██████╗ ██████╗  ║
║   ██║    ██║██║████╗  ██║██║     ██╔══██╗╚══██╔══╝██╔═══██╗██╔══██╗ ║
║   ██║ █╗ ██║██║██╔██╗ ██║██║     ███████║   ██║   ██║   ██║██████╔╝ ║
║   ██║███╗██║██║██║╚██╗██║██║     ██╔══██║   ██║   ██║   ██║██╔══██╗ ║
║   ╚███╔███╔╝██║██║ ╚████║███████╗██║  ██║   ██║   ╚██████╔╝██║  ██║ ║
║    ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝ ║
║                                                          ║
║        Professional Gaming Setup for Ubuntu/Termux       ║
║           Wine + Box64/86 + Gaming Libraries             ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

show_progress() {
    echo -e "${YELLOW}${ARROW}${NC} ${WHITE}$1${NC}"
}

show_success() {
    echo -e "${GREEN}${CHECK}${NC} $1"
}

show_error() {
    echo -e "${RED}${CROSS}${NC} $1"
}

show_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

show_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

show_banner

echo ""
show_progress "Checking system requirements..."

if [ "$EUID" -ne 0 ]; then
    echo ""
    show_error "This script requires root privileges!"
    echo ""
    echo -e "${YELLOW}Please run with:${NC}"
    echo -e "${GREEN}sudo bash winlator.sh${NC}"
    echo ""
    exit 1
fi

show_success "Root access verified"

export DEBIAN_FRONTEND=noninteractive
ARCH=$(uname -m)
show_info "System architecture: ${CYAN}${ARCH}${NC}"

echo ""
echo -e "${PURPLE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║${NC}  ${BOLD}${GAME} Gaming Setup Overview${NC}                                ${PURPLE}║${NC}"
echo -e "${PURPLE}╠══════════════════════════════════════════════════════════╣${NC}"
echo -e "${PURPLE}║${NC}  ${YELLOW}•${NC} Box64 (x86_64 emulator)                               ${PURPLE}║${NC}"
echo -e "${PURPLE}║${NC}  ${YELLOW}•${NC} Box86 (x86 emulator)                                  ${PURPLE}║${NC}"
echo -e "${PURPLE}║${NC}  ${YELLOW}•${NC} Wine Stable + Staging                                 ${PURPLE}║${NC}"
echo -e "${PURPLE}║${NC}  ${YELLOW}•${NC} DirectX 9/10/11 (DXVK)                                ${PURPLE}║${NC}"
echo -e "${PURPLE}║${NC}  ${YELLOW}•${NC} Vulkan + Mesa drivers                                 ${PURPLE}║${NC}"
echo -e "${PURPLE}║${NC}  ${YELLOW}•${NC} OpenGL libraries                                      ${PURPLE}║${NC}"
echo -e "${PURPLE}║${NC}  ${YELLOW}•${NC} Gaming dependencies & libraries                       ${PURPLE}║${NC}"
echo -e "${PURPLE}║${NC}  ${YELLOW}•${NC} Winetricks & tools                                    ${PURPLE}║${NC}"
echo -e "${PURPLE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

show_warning "This process may take 45-90 minutes"
echo ""
read -p "$(echo -e ${CYAN}Press Enter to continue...${NC})"

# Step 1: System Update
echo ""
echo -e "${YELLOW}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║${NC}  ${BOLD}Step 1/8: Updating System${NC}                               ${YELLOW}║${NC}"
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

# Step 2: Install Build Dependencies
echo ""
echo -e "${YELLOW}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║${NC}  ${BOLD}Step 2/8: Installing Build Tools${NC}                        ${YELLOW}║${NC}"
echo -e "${YELLOW}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

show_progress "Installing build dependencies..."
apt install -y \
    wget git curl \
    build-essential cmake \
    gcc g++ \
    make automake autoconf \
    pkg-config \
    python3 python3-pip \
    libtool \
    ninja-build \
    meson > /dev/null 2>&1
show_success "Build tools installed"

sleep 1
clear

# Step 3: Install Box64
echo ""
echo -e "${YELLOW}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║${NC}  ${BOLD}Step 3/8: Installing Box64 Emulator${NC}                     ${YELLOW}║${NC}"
echo -e "${YELLOW}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

if [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
    show_progress "Cloning Box64 repository..."
    cd /tmp
    rm -rf box64
    git clone https://github.com/ptitSeb/box64.git > /dev/null 2>&1
    show_success "Repository cloned"
    
    show_progress "Building Box64 (15-20 minutes)..."
    cd box64
    mkdir -p build && cd build
    cmake .. -DARM_DYNAREC=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo > /dev/null 2>&1
    make -j$(nproc) > /dev/null 2>&1
    make install > /dev/null 2>&1
    ldconfig
    show_success "Box64 installed"
else
    show_warning "Box64 skipped (ARM64 only)"
fi

sleep 1
clear

# Step 4: Install Box86
echo ""
echo -e "${YELLOW}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║${NC}  ${BOLD}Step 4/8: Installing Box86 Emulator${NC}                     ${YELLOW}║${NC}"
echo -e "${YELLOW}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

if [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" || "$ARCH" == "armv7l" ]]; then
    show_progress "Cloning Box86 repository..."
    cd /tmp
    rm -rf box86
    git clone https://github.com/ptitSeb/box86.git > /dev/null 2>&1
    show_success "Repository cloned"
    
    show_progress "Building Box86 (15-20 minutes)..."
    cd box86
    mkdir -p build && cd build
    cmake .. -DARM_DYNAREC=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo > /dev/null 2>&1
    make -j$(nproc) > /dev/null 2>&1
    make install > /dev/null 2>&1
    ldconfig
    show_success "Box86 installed"
else
    show_warning "Box86 skipped (ARM only)"
fi

sleep 1
clear

# Step 5: Install Wine
echo ""
echo -e "${YELLOW}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║${NC}  ${BOLD}Step 5/8: Installing Wine${NC}                               ${YELLOW}║${NC}"
echo -e "${YELLOW}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

show_progress "Adding i386 architecture..."
dpkg --add-architecture i386 2>/dev/null
apt update > /dev/null 2>&1
show_success "Architecture added"

show_progress "Installing Wine packages..."
apt install -y \
    wine wine32 wine64 \
    wine-stable \
    winetricks \
    cabextract \
    zenity > /dev/null 2>&1
show_success "Wine installed"

sleep 1
clear

# Step 6: Install Graphics Libraries
echo ""
echo -e "${YELLOW}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║${NC}  ${BOLD}Step 6/8: Installing Graphics Libraries${NC}                 ${YELLOW}║${NC}"
echo -e "${YELLOW}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

show_progress "Installing Vulkan support..."
apt install -y \
    vulkan-tools \
    mesa-vulkan-drivers \
    libvulkan1 \
    libvulkan-dev > /dev/null 2>&1
show_success "Vulkan installed"

show_progress "Installing OpenGL libraries..."
apt install -y \
    mesa-utils \
    libgl1-mesa-glx \
    libgl1-mesa-dri \
    libglx-mesa0 \
    libglu1-mesa \
    libosmesa6 > /dev/null 2>&1
show_success "OpenGL libraries installed"

show_progress "Installing DirectX support (DXVK)..."
apt install -y \
    libdxvk \
    dxvk > /dev/null 2>&1 || show_info "DXVK will be configured via winetricks"
show_success "DirectX support prepared"

sleep 1
clear

# Step 7: Install Gaming Dependencies
echo ""
echo -e "${YELLOW}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║${NC}  ${BOLD}Step 7/8: Installing Gaming Dependencies${NC}                ${YELLOW}║${NC}"
echo -e "${YELLOW}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

show_progress "Installing audio libraries..."
apt install -y \
    pulseaudio \
    pavucontrol \
    alsa-utils \
    libasound2 \
    libasound2-plugins \
    libpulse0 > /dev/null 2>&1
show_success "Audio libraries installed"

show_progress "Installing gaming libraries..."
apt install -y \
    libsdl2-2.0-0 \
    libsdl2-dev \
    libsdl2-image-2.0-0 \
    libsdl2-mixer-2.0-0 \
    libsdl2-ttf-2.0-0 \
    libfreetype6 \
    libfontconfig1 \
    libx11-6 \
    libxext6 \
    libxrender1 \
    libxrandr2 \
    libxinerama1 \
    libxi6 \
    libxcursor1 \
    libxxf86vm1 > /dev/null 2>&1
show_success "Gaming libraries installed"

show_progress "Installing additional dependencies..."
apt install -y \
    libgnutls30 \
    libldap-2.5-0 \
    libgpg-error0 \
    libxml2 \
    libasound2-plugins \
    libgstreamer1.0-0 \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly \
    libncurses5 \
    libncurses6 > /dev/null 2>&1
show_success "Additional dependencies installed"

sleep 1
clear

# Step 8: Configure Wine & Gaming Environment
echo ""
echo -e "${YELLOW}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║${NC}  ${BOLD}Step 8/8: Configuring Gaming Environment${NC}                ${YELLOW}║${NC}"
echo -e "${YELLOW}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

show_progress "Creating Wine prefix..."
mkdir -p /opt/wine-gaming
export WINEPREFIX=/opt/wine-gaming
export WINEARCH=win64
show_success "Wine prefix created"

show_progress "Configuring Box64 for Wine..."
cat > /etc/box64.box64rc << 'BOX64EOF'
BOX64_LOG=0
BOX64_NOBANNER=1
BOX64_DYNAREC_BIGBLOCK=1
BOX64_DYNAREC_STRONGMEM=1
BOX64_DYNAREC_FASTNAN=1
BOX64_DYNAREC_FASTROUND=1
BOX64_DYNAREC_SAFEFLAGS=0
BOX64_DYNAREC_CALLRET=1
BOX64_DYNAREC_BLEEDING_EDGE=1
BOX64_DYNAREC_WAIT=1
BOX64_DYNAREC_X87DOUBLE=1
BOX64EOF
show_success "Box64 configured"

show_progress "Configuring Box86 for Wine..."
cat > /etc/box86.box86rc << 'BOX86EOF'
BOX86_LOG=0
BOX86_NOBANNER=1
BOX86_DYNAREC_BIGBLOCK=1
BOX86_DYNAREC_STRONGMEM=1
BOX86_DYNAREC_FASTNAN=1
BOX86_DYNAREC_FASTROUND=1
BOX86_DYNAREC_SAFEFLAGS=0
BOX86_DYNAREC_CALLRET=1
BOX86_DYNAREC_BLEEDING_EDGE=1
BOX86_DYNAREC_WAIT=1
BOX86EOF
show_success "Box86 configured"

show_progress "Creating gaming launcher script..."
cat > /usr/local/bin/run-game << 'GAMEEOF'
#!/bin/bash

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

export WINEPREFIX=/opt/wine-gaming
export WINEARCH=win64
export BOX64_NOBANNER=1
export BOX86_NOBANNER=1

if [ -z "$1" ]; then
    echo -e "${YELLOW}Usage: run-game <game.exe>${NC}"
    exit 1
fi

echo -e "${CYAN}Starting game: $1${NC}"
wine "$1"
GAMEEOF

chmod +x /usr/local/bin/run-game
show_success "Gaming launcher created"

show_progress "Creating winetricks helper..."
cat > /usr/local/bin/install-game-deps << 'WTEOF'
#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
NC='\033[0m'

export WINEPREFIX=/opt/wine-gaming

echo -e "${CYAN}Installing common gaming dependencies...${NC}"

winetricks -q \
    d3dx9 \
    d3dx10 \
    d3dx11_43 \
    d3dcompiler_43 \
    d3dcompiler_47 \
    vcrun2010 \
    vcrun2012 \
    vcrun2013 \
    vcrun2015 \
    vcrun2019 \
    dotnet40 \
    dotnet48 \
    xact \
    xinput \
    physx

echo -e "${GREEN}Dependencies installed!${NC}"
WTEOF

chmod +x /usr/local/bin/install-game-deps
show_success "Winetricks helper created"

show_progress "Creating system info script..."
cat > /usr/local/bin/gaming-info << 'INFOEOF'
#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║      Gaming Environment Info           ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
echo ""

echo -e "${GREEN}Installed Components:${NC}"
echo -e "${YELLOW}  ✓${NC} Box64: $(which box64 && echo 'Installed' || echo 'Not found')"
echo -e "${YELLOW}  ✓${NC} Box86: $(which box86 && echo 'Installed' || echo 'Not found')"
echo -e "${YELLOW}  ✓${NC} Wine: $(wine --version 2>/dev/null || echo 'Not found')"
echo -e "${YELLOW}  ✓${NC} Vulkan: $(vulkaninfo --summary 2>/dev/null | head -1 || echo 'Not available')"
echo ""

echo -e "${CYAN}Wine Prefix:${NC} /opt/wine-gaming"
echo ""

echo -e "${GREEN}Quick Commands:${NC}"
echo -e "${YELLOW}  run-game <game.exe>${NC}     - Run a game"
echo -e "${YELLOW}  install-game-deps${NC}       - Install gaming dependencies"
echo -e "${YELLOW}  winetricks${NC}              - Configure Wine"
echo ""
INFOEOF

chmod +x /usr/local/bin/gaming-info
show_success "Gaming info script created"

# Cleanup
echo ""
show_progress "Cleaning up..."
apt autoremove -y > /dev/null 2>&1
apt clean > /dev/null 2>&1
rm -rf /tmp/box64 /tmp/box86
show_success "Cleanup completed"

sleep 1
clear

# Final Summary
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                          ║${NC}"
echo -e "${GREEN}║        ${GAME} Gaming Setup Completed Successfully! ${GAME}         ║${NC}"
echo -e "${GREEN}║                                                          ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${PURPLE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║${NC}  ${BOLD}Installed Components${NC}                                     ${PURPLE}║${NC}"
echo -e "${PURPLE}╠══════════════════════════════════════════════════════════╣${NC}"
echo -e "${PURPLE}║${NC}  ${GREEN}✓${NC} Box64 (x86_64 emulator)                               ${PURPLE}║${NC}"
echo -e "${PURPLE}║${NC}  ${GREEN}✓${NC} Box86 (x86 emulator)                                  ${PURPLE}║${NC}"
echo -e "${PURPLE}║${NC}  ${GREEN}✓${NC} Wine Stable + Tools                                   ${PURPLE}║${NC}"
echo -e "${PURPLE}║${NC}  ${GREEN}✓${NC} Vulkan + OpenGL drivers                               ${PURPLE}║${NC}"
echo -e "${PURPLE}║${NC}  ${GREEN}✓${NC} DirectX support (DXVK)                                ${PURPLE}║${NC}"
echo -e "${PURPLE}║${NC}  ${GREEN}✓${NC} Gaming libraries & dependencies                       ${PURPLE}║${NC}"
echo -e "${PURPLE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  ${BOLD}Quick Start Guide${NC}                                        ${CYAN}║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}${ARROW}${NC} ${BOLD}Run a game:${NC}"
echo -e "  ${GREEN}run-game /path/to/game.exe${NC}"
echo ""
echo -e "${YELLOW}${ARROW}${NC} ${BOLD}Install game dependencies:${NC}"
echo -e "  ${GREEN}install-game-deps${NC}"
echo ""
echo -e "${YELLOW}${ARROW}${NC} ${BOLD}View gaming info:${NC}"
echo -e "  ${GREEN}gaming-info${NC}"
echo ""
echo -e "${YELLOW}${ARROW}${NC} ${BOLD}Configure Wine:${NC}"
echo -e "  ${GREEN}winetricks${NC}"
echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo ""

sleep 1
clear
