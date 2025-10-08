# 🧙‍♂️⚡ Enterprise Laptop Automation Suite
## Seamless Red Hat Corporate Authentication & VPN Integration

**Transform your corporate laptop into an enterprise automation powerhouse with zero manual authentication!**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Red Hat](https://img.shields.io/badge/Red%20Hat-Compatible-red.svg)](https://redhat.com)
[![Kerberos](https://img.shields.io/badge/Kerberos-Automated-blue.svg)](https://web.mit.edu/kerberos/)

---

## 🚀 **What This Does**

### **Before This Suite:**
- Manual `kinit` every few hours
- Typing Kerberos passwords constantly  
- VPN connection + authentication friction
- Remembering to renew tickets
- Authentication failures disrupting workflow

### **After Installation:**
- ✅ **Connect VPN** → **Everything Else Automated**
- ✅ **Never touch `kinit` again**
- ✅ **Desktop notifications** for all auth events
- ✅ **30-minute auto-renewal** = never-expiring tickets
- ✅ **Secure encrypted password storage**
- ✅ **Enterprise-grade security and logging**

---

## 🎯 **Features**

### **🔐 Secure Credential Management**
- **AES-256-CBC encryption** with OpenSSL
- **GPG-based advanced vault** (optional)
- **Secure file permissions** (600)
- **Memory-safe password handling**

### **🌐 VPN Integration**
- **NetworkManager dispatcher** integration
- **Automatic Red Hat VPN detection**
- **Desktop notifications** for connection events
- **Multi-VPN endpoint support**

### **⚡ Automatic Kerberos Management**
- **VPN-triggered authentication** 
- **30-minute automatic renewal**
- **Self-healing ticket management**
- **Fallback to manual auth if needed**

### **🌐 Browser SSO Integration**
- **Automatic Red Hat website login**
- **Chrome, Firefox, and Chromium support**
- **Desktop launcher integration**
- **Zero password prompts for authenticated sites**

### **🏰 Enterprise Integration**
- **Red Hat corporate Kerberos** (IPA.REDHAT.COM)
- **Active Directory trust** support
- **Multi-factor authentication** ready
- **Comprehensive audit logging**

---

## 📋 **Requirements**

### **Operating System**
- **Fedora 40+** (primary target)
- **RHEL 8/9** (fully supported)
- **CentOS Stream** (compatible)
- **Other Linux** (may work with modifications)

### **Network Access**
- **Red Hat VPN** access configured
- **Corporate network** connectivity
- **Kerberos realm** access (IPA.REDHAT.COM)

### **System Packages**
```bash
# Required packages (installed by setup script)
sudo dnf install -y krb5-workstation openssl NetworkManager
```

---

## 🚀 **Quick Start**

### **1. Clone Repository**
```bash
git clone https://github.com/YOUR_USERNAME/laptop-enterprise-automation.git
cd laptop-enterprise-automation
```

### **2. Run Installation Script**
```bash
chmod +x install.sh
./install.sh
```

### **3. Store Your Password Securely**
```bash
pai-simple-credential-store --store
# Enter your Red Hat Kerberos password when prompted
```

### **4. Test Automatic Authentication**
```bash
pai-simple-credential-store --test
# Should show: ✅ Automatic kinit successful!
```

### **5. Connect Red Hat VPN**
```bash
# Use your usual VPN connection method
# Watch for desktop notification: "🔐 Enterprise authentication complete!"
```

### **6. Set Up Browser SSO**
```bash
pai-browser-kerberos-setup --install
# Configures Chrome and Firefox for Red Hat SSO
```

### **7. Test Red Hat SSO**
```bash
# Launch Chrome with automatic Red Hat authentication
google-chrome-kerberos

# Or launch Firefox with SSO
firefox-kerberos

# Navigate to any Red Hat site - automatic login!
# Try: https://access.redhat.com, https://console.redhat.com
```

### **8. Verify Ultimate Seamless Workflow**
```bash
pai-vpn-kerberos-integration --status
# Should show all green checkmarks ✅
```

---

## 🛠️ **Manual Installation**

### **Step 1: Install Scripts**
```bash
# Copy scripts to user bin directory
cp bin/* ~/.local/bin/
chmod +x ~/.local/bin/pai-*

# Ensure ~/.local/bin is in PATH
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### **Step 2: Install Systemd Services**
```bash
# Copy systemd user services
mkdir -p ~/.config/systemd/user
cp systemd/* ~/.config/systemd/user/

# Enable and start automatic renewal
systemctl --user daemon-reload
systemctl --user enable pai-kerberos-renewal.timer
systemctl --user start pai-kerberos-renewal.timer
```

### **Step 3: Install NetworkManager Integration**
```bash
# Install VPN integration (requires sudo)
pai-vpn-kerberos-integration --install
```

---

## 📖 **Usage Guide**

### **🔐 Credential Management**
```bash
# Store password securely
pai-simple-credential-store --store

# Test automatic authentication  
pai-simple-credential-store --kinit

# Check credential status
pai-simple-credential-store --status

# Remove stored credentials
pai-simple-credential-store --remove
```

### **🌐 VPN Integration**
```bash
# Check VPN integration status
pai-vpn-kerberos-integration --status

# Test authentication when on corporate network
pai-vpn-kerberos-integration --test-auth

# Monitor VPN events (interactive)
pai-vpn-kerberos-integration --monitor
```

### **⚡ Automatic Renewal**
```bash
# Check renewal service status
systemctl --user status pai-kerberos-renewal.timer

# Manual renewal test
pai-kerberos-auto-renew --renew

# View renewal logs
journalctl --user -u pai-kerberos-renewal.service -f
```

---

## 🔧 **Configuration**

### **🎛️ Customization Options**

#### **Change Renewal Frequency**
```bash
# Edit timer (default: 30 minutes)
systemctl --user edit pai-kerberos-renewal.timer

# Add override:
[Timer]
OnUnitActiveSec=15min  # Change to 15 minutes
```

#### **Disable Desktop Notifications**
```bash
# Edit scripts and comment out notify-send lines:
# - pai-vpn-kerberos-integration
# - pai-kerberos-auto-renew
```

#### **Advanced GPG Vault** (Optional)
```bash
# Use GPG-based credential storage instead
pai-credential-vault --init
pai-credential-vault --store
```

---

## 🛡️ **Security Features**

### **🔒 Credential Protection**
- **AES-256-CBC encryption** with user-unique keys
- **Secure file permissions** (600 - only user readable)
- **Memory-safe password handling** (variables cleared after use)
- **No plain-text storage** anywhere in the system

### **🔍 Audit & Logging**
- **Comprehensive logging** in `/tmp/pai-*.log`
- **Systemd journal** integration for service events  
- **Authentication event tracking** for security auditing
- **Error logging** for troubleshooting

### **🌐 Network Security**
- **Corporate network detection** before authentication attempts
- **VPN-only authentication** (no authentication on untrusted networks)
- **Kerberos ticket encryption** (standard Kerberos security)

---

## 🚨 **Troubleshooting**

### **Common Issues**

#### **"No VPN Connected" but VPN is active**
```bash
# Check VPN connection name detection
nmcli connection show --active | grep vpn

# Verify Red Hat VPN naming in script
pai-vpn-kerberos-integration --status
```

#### **"Automatic kinit failed"**
```bash
# Check stored password
pai-simple-credential-store --status

# Test manual kinit
kinit your_username@IPA.REDHAT.COM

# Re-store password if changed
pai-simple-credential-store --store
```

#### **"Kerberos server unreachable"**
```bash
# Test network connectivity
timeout 3 nc -z kerberos.corp.redhat.com 88
ping kerberos.corp.redhat.com

# Check VPN connection to corporate network
```

#### **Systemd service not running**
```bash
# Check service status
systemctl --user status pai-kerberos-renewal.timer

# Restart if needed
systemctl --user restart pai-kerberos-renewal.timer

# View logs
journalctl --user -u pai-kerberos-renewal.service
```

### **🔧 Debug Mode**
```bash
# Enable verbose logging
export PAI_DEBUG=1

# Run manual tests
pai-simple-credential-store --test
pai-vpn-kerberos-integration --test-auth
```

---

## 🤝 **Contributing**

### **🎯 Areas for Contribution**
- **Additional VPN providers** (Cisco AnyConnect, OpenVPN, etc.)
- **Multi-platform support** (macOS, Windows WSL)
- **Enhanced MFA integration** (FIDO2, smart cards)
- **Advanced credential backends** (HashiCorp Vault, etc.)
- **GUI management interface**

### **📝 Contribution Guidelines**
1. **Fork the repository**
2. **Create feature branch**: `git checkout -b feature/amazing-feature`
3. **Test thoroughly** on Fedora/RHEL
4. **Update documentation** for new features
5. **Submit pull request** with detailed description

---

## 📄 **License**

MIT License - see [LICENSE](LICENSE) for details.

---

## 🏆 **Acknowledgments**

- **Red Hat Corporation** - For excellent enterprise infrastructure
- **MIT Kerberos Team** - For robust authentication protocols  
- **Fedora Project** - For outstanding Linux distribution
- **NetworkManager Team** - For reliable network integration

---

## 📞 **Support**

### **🐛 Issues**
- **GitHub Issues**: [Report bugs or request features](https://github.com/YOUR_USERNAME/laptop-enterprise-automation/issues)
- **Documentation**: Check troubleshooting section above
- **Logs**: Include relevant logs from `/tmp/pai-*.log`

### **💬 Discussion**
- **GitHub Discussions**: [Community support and ideas](https://github.com/YOUR_USERNAME/laptop-enterprise-automation/discussions)
- **Red Hat Community**: Enterprise authentication best practices

---

## 🎯 **Roadmap**

### **🚀 Planned Features**
- [ ] **Multi-realm support** (REDHAT.COM + IPA.REDHAT.COM)
- [ ] **Browser SSO integration** (Firefox/Chrome Kerberos)
- [ ] **SSH key automation** (Kerberos-based SSH)
- [ ] **Certificate management** (automated SSL cert deployment)
- [ ] **Mobile integration** (smartphone notifications)
- [ ] **Team deployment** (organization-wide rollout tools)

---

**🧙‍♂️ Transform your corporate laptop experience from authentication friction to seamless enterprise power! ⚡🏰✨**
