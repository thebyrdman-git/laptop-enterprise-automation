#!/bin/bash

# 🧙‍♂️⚡ Enterprise Laptop Automation Suite Installer
# Seamless Red Hat Corporate Authentication & VPN Integration

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Configuration
INSTALL_DIR="$HOME/.local/bin"
SYSTEMD_DIR="$HOME/.config/systemd/user"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Logging function
log_message() {
    local level=$1
    local message=$2
    
    case $level in
        "INFO") echo -e "${CYAN}ℹ️  $message${NC}" ;;
        "SUCCESS") echo -e "${GREEN}✅ $message${NC}" ;;
        "WARNING") echo -e "${YELLOW}⚠️  $message${NC}" ;;
        "ERROR") echo -e "${RED}❌ $message${NC}" ;;
        "MAGIC") echo -e "${PURPLE}🧙‍♂️ $message${NC}" ;;
    esac
}

# Magical progress bar function
show_magical_progress() {
    local current=$1
    local total=$2
    local task=$3
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((current * width / total))
    
    printf "${PURPLE}⚡ ${BOLD}${WHITE}Installation Magic:${NC} "
    printf "${CYAN}[${NC}"
    
    # Create rainbow gradient in progress bar
    for ((i=1; i<=completed; i++)); do
        if ((i <= width/6)); then printf "${RED}█${NC}"
        elif ((i <= width/3)); then printf "${YELLOW}█${NC}"
        elif ((i <= width/2)); then printf "${GREEN}█${NC}"
        elif ((i <= 2*width/3)); then printf "${CYAN}█${NC}"
        elif ((i <= 5*width/6)); then printf "${BLUE}█${NC}"
        else printf "${PURPLE}█${NC}"
        fi
    done
    
    printf "%$((width-completed))s" | tr ' ' '░'
    printf "${CYAN}]${NC} ${BOLD}%3d%%${NC} ${PURPLE}⚡ %s${NC}\n" "$percentage" "$task"
}

# Check requirements
check_requirements() {
    log_message "MAGIC" "Checking system requirements"
    
    # Check OS
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case $ID in
            fedora|rhel|centos)
                log_message "SUCCESS" "Operating system: $PRETTY_NAME ✅"
                ;;
            *)
                log_message "WARNING" "Untested OS: $PRETTY_NAME - may work with modifications"
                ;;
        esac
    fi
    
    # Check required commands
    local required_commands=("kinit" "klist" "nmcli" "openssl" "systemctl")
    for cmd in "${required_commands[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            log_message "SUCCESS" "Command available: $cmd ✅"
        else
            log_message "ERROR" "Required command missing: $cmd"
            log_message "INFO" "Install with: sudo dnf install -y krb5-workstation openssl NetworkManager systemd"
            exit 1
        fi
    done
    
    # Check NetworkManager
    if systemctl is-active NetworkManager >/dev/null 2>&1; then
        log_message "SUCCESS" "NetworkManager is running ✅"
    else
        log_message "ERROR" "NetworkManager is not running"
        exit 1
    fi
}

# Install system packages
install_packages() {
    log_message "MAGIC" "Installing required system packages"
    
    local packages=("krb5-workstation" "openssl" "NetworkManager")
    local missing_packages=()
    
    for package in "${packages[@]}"; do
        if ! rpm -q "$package" >/dev/null 2>&1; then
            missing_packages+=("$package")
        fi
    done
    
    if [ ${#missing_packages[@]} -gt 0 ]; then
        log_message "INFO" "Installing missing packages: ${missing_packages[*]}"
        if sudo dnf install -y "${missing_packages[@]}"; then
            log_message "SUCCESS" "Packages installed successfully"
        else
            log_message "ERROR" "Package installation failed"
            exit 1
        fi
    else
        log_message "SUCCESS" "All required packages already installed ✅"
    fi
}

# Create directories
create_directories() {
    show_magical_progress 1 8 "Creating directory structure"
    
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$SYSTEMD_DIR"
    
    log_message "SUCCESS" "Directories created: $INSTALL_DIR, $SYSTEMD_DIR"
}

# Install scripts
install_scripts() {
    show_magical_progress 2 8 "Installing automation scripts"
    
    if [ ! -d "$SCRIPT_DIR/bin" ]; then
        log_message "ERROR" "Scripts directory not found: $SCRIPT_DIR/bin"
        exit 1
    fi
    
    # Copy scripts
    cp "$SCRIPT_DIR"/bin/* "$INSTALL_DIR/"
    chmod +x "$INSTALL_DIR"/pai-*
    
    log_message "SUCCESS" "Automation scripts installed to $INSTALL_DIR"
    
    # Verify PATH
    if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
        log_message "WARNING" "Adding $INSTALL_DIR to PATH in ~/.bashrc"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
        log_message "INFO" "Please run: source ~/.bashrc or restart your terminal"
    fi
}

# Install systemd services
install_systemd_services() {
    show_magical_progress 3 8 "Installing systemd user services"
    
    if [ -d "$SCRIPT_DIR/systemd" ]; then
        cp "$SCRIPT_DIR"/systemd/* "$SYSTEMD_DIR/"
        log_message "SUCCESS" "Systemd services copied"
    else
        log_message "WARNING" "Systemd services directory not found - creating services"
        
        # Create service file
        cat > "$SYSTEMD_DIR/pai-kerberos-renewal.service" << EOF
[Unit]
Description=PAI Kerberos Ticket Auto-Renewal
After=network.target

[Service]
Type=oneshot
ExecStart=$INSTALL_DIR/pai-kerberos-auto-renew --renew
Environment=DISPLAY=:0

[Install]
WantedBy=default.target
EOF

        # Create timer file
        cat > "$SYSTEMD_DIR/pai-kerberos-renewal.timer" << EOF
[Unit]
Description=PAI Kerberos Ticket Auto-Renewal Timer
Requires=pai-kerberos-renewal.service

[Timer]
OnBootSec=5min
OnUnitActiveSec=30min
Persistent=true

[Install]
WantedBy=timers.target
EOF
        
        log_message "SUCCESS" "Systemd services created"
    fi
}

# Enable systemd services
enable_systemd_services() {
    show_magical_progress 4 8 "Enabling automatic renewal service"
    
    systemctl --user daemon-reload
    
    if systemctl --user enable pai-kerberos-renewal.timer; then
        log_message "SUCCESS" "Systemd timer enabled"
    else
        log_message "ERROR" "Failed to enable systemd timer"
        exit 1
    fi
    
    if systemctl --user start pai-kerberos-renewal.timer; then
        log_message "SUCCESS" "Systemd timer started"
    else
        log_message "WARNING" "Failed to start systemd timer - may need manual start"
    fi
}

# Install VPN integration
install_vpn_integration() {
    show_magical_progress 5 8 "Installing VPN integration"
    
    log_message "INFO" "Installing NetworkManager VPN integration (requires sudo)"
    
    if "$INSTALL_DIR/pai-vpn-kerberos-integration" --install; then
        log_message "SUCCESS" "VPN integration installed"
    else
        log_message "WARNING" "VPN integration installation failed - can be done manually later"
        log_message "INFO" "Run: pai-vpn-kerberos-integration --install"
    fi
}

# Install browser Kerberos integration
install_browser_integration() {
    show_magical_progress 6 8 "Installing browser Kerberos SSO"
    
    log_message "INFO" "Setting up browser Kerberos integration for Red Hat SSO"
    
    if "$INSTALL_DIR/pai-browser-kerberos-setup" --install >/dev/null 2>&1; then
        log_message "SUCCESS" "Browser Kerberos SSO installed"
    else
        log_message "WARNING" "Browser integration setup failed - can be done manually later"
        log_message "INFO" "Run: pai-browser-kerberos-setup --install"
    fi
}

# Verify installation
verify_installation() {
    show_magical_progress 7 8 "Verifying installation"
    
    # Check scripts
    local scripts=("pai-kerberos-auto-renew" "pai-vpn-kerberos-integration" "pai-simple-credential-store")
    for script in "${scripts[@]}"; do
        if [ -x "$INSTALL_DIR/$script" ]; then
            log_message "SUCCESS" "Script installed: $script ✅"
        else
            log_message "ERROR" "Script missing: $script ❌"
        fi
    done
    
    # Check systemd service
    if systemctl --user is-enabled pai-kerberos-renewal.timer >/dev/null 2>&1; then
        log_message "SUCCESS" "Systemd timer enabled ✅"
    else
        log_message "WARNING" "Systemd timer not enabled ⚠️"
    fi
}

# Show next steps
show_next_steps() {
    show_magical_progress 8 8 "Installation complete"
    
    echo ""
    echo -e "${PURPLE}🧙‍♂️⚡ ${BOLD}${WHITE}Enterprise Laptop Automation Suite Installed!${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${GREEN}✅ Scripts installed to: $INSTALL_DIR${NC}"
    echo -e "${GREEN}✅ Systemd services configured${NC}"
    echo -e "${GREEN}✅ VPN integration ready${NC}"
    echo ""
    echo -e "${YELLOW}🎯 NEXT STEPS:${NC}"
    echo ""
    echo -e "${CYAN}1. ${BOLD}Reload shell environment:${NC}"
    echo -e "   ${BLUE}source ~/.bashrc${NC}"
    echo ""
    echo -e "${CYAN}2. ${BOLD}Store your Kerberos password securely:${NC}"
    echo -e "   ${BLUE}pai-simple-credential-store --store${NC}"
    echo ""
    echo -e "${CYAN}3. ${BOLD}Test automatic authentication:${NC}"
    echo -e "   ${BLUE}pai-simple-credential-store --test${NC}"
    echo ""
    echo -e "${CYAN}4. ${BOLD}Check system status:${NC}"
    echo -e "   ${BLUE}pai-vpn-kerberos-integration --status${NC}"
    echo ""
    echo -e "${CYAN}5. ${BOLD}Connect Red Hat VPN and enjoy seamless automation!${NC}"
    echo ""
    echo -e "${CYAN}6. ${BOLD}Launch browser with Red Hat SSO:${NC}"
    echo -e "   ${BLUE}google-chrome-kerberos${NC}  ${GREEN}# Chrome with automatic Red Hat login${NC}"
    echo -e "   ${BLUE}firefox-kerberos${NC}        ${GREEN}# Firefox with automatic Red Hat login${NC}"
    echo ""
    echo -e "${PURPLE}🔮 ULTIMATE WORKFLOW:${NC}"
    echo -e "${WHITE}   Connect VPN → Auto auth → Launch SSO browser → Never enter passwords!${NC}"
    echo ""
    echo -e "${GREEN}📖 Documentation: README.md${NC}"
    echo -e "${GREEN}🐛 Issues: GitHub Issues${NC}"
    echo -e "${GREEN}💬 Support: GitHub Discussions${NC}"
    echo ""
}

# Main installation function
main() {
    echo -e "${PURPLE}🧙‍♂️⚡ ${BOLD}${WHITE}Enterprise Laptop Automation Suite${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
    echo -e "${PURPLE}Seamless Red Hat Corporate Authentication & VPN Integration${NC}"
    echo ""
    
    check_requirements
    install_packages
    create_directories
    install_scripts
    install_systemd_services
    enable_systemd_services
    install_vpn_integration
    install_browser_integration
    verify_installation
    show_next_steps
}

# Run installation
main "$@"
