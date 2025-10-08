# 🧙‍♂️🔧 Troubleshooting Guide
## Enterprise Laptop Automation Suite

### **🚨 Quick Diagnostics**

#### **Check Overall System Status**
```bash
# Run comprehensive status check
pai-vpn-kerberos-integration --status
pai-simple-credential-store --status
systemctl --user status pai-kerberos-renewal.timer
```

---

## 🔐 **Authentication Issues**

### **Problem: "Automatic kinit failed"**

#### **Diagnosis:**
```bash
# Check if password is stored
pai-simple-credential-store --status

# Test manual kinit
kinit your_username@IPA.REDHAT.COM

# Check Kerberos configuration
cat /etc/krb5.conf | grep -A5 -B5 IPA.REDHAT.COM
```

#### **Solutions:**
1. **Password Changed:** Re-store password
   ```bash
   pai-simple-credential-store --store
   ```

2. **Network Issues:** Check corporate network access
   ```bash
   ping kerberos.corp.redhat.com
   timeout 3 nc -z kerberos.corp.redhat.com 88
   ```

3. **Kerberos Config Issues:** Verify `/etc/krb5.conf`
   ```bash
   # Should contain IPA.REDHAT.COM realm configuration
   grep -i "ipa.redhat.com" /etc/krb5.conf
   ```

### **Problem: "No current tickets" after successful auth**

#### **Diagnosis:**
```bash
# Check ticket cache location
echo $KRB5CCNAME
klist -A

# Check ticket cache permissions
ls -la /tmp/krb5cc_*
```

#### **Solutions:**
1. **Cache Location Issue:**
   ```bash
   # Set proper cache location
   export KRB5CCNAME=KEYRING:persistent:$(id -u)
   ```

2. **Permission Issues:**
   ```bash
   # Fix cache permissions
   chmod 600 /tmp/krb5cc_*
   ```

---

## 🌐 **VPN Integration Issues**

### **Problem: "No VPN Connected" but VPN is active**

#### **Diagnosis:**
```bash
# Check active VPN connections
nmcli connection show --active | grep vpn

# Check VPN name detection
grep -r "Red Hat" /etc/NetworkManager/dispatcher.d/
```

#### **Solutions:**
1. **VPN Name Mismatch:**
   ```bash
   # Edit VPN integration script
   vi ~/.local/bin/pai-vpn-kerberos-integration
   # Update RED_HAT_VPN_NAME variable to match your VPN name
   ```

2. **NetworkManager Dispatcher Not Working:**
   ```bash
   # Reinstall VPN integration
   pai-vpn-kerberos-integration --install
   
   # Check dispatcher script permissions
   ls -la /etc/NetworkManager/dispatcher.d/99-pai-vpn-kerberos
   ```

### **Problem: VPN connects but no automatic authentication**

#### **Diagnosis:**
```bash
# Check dispatcher logs
sudo journalctl -u NetworkManager -f

# Manual test VPN authentication
pai-vpn-kerberos-integration --test-auth
```

#### **Solutions:**
1. **Dispatcher Script Issues:**
   ```bash
   # Check if script exists
   ls -la /etc/NetworkManager/dispatcher.d/99-pai-vpn-kerberos
   
   # Reinstall if missing
   sudo pai-vpn-kerberos-integration --install
   ```

2. **Timing Issues:**
   ```bash
   # Add delay to VPN script (edit dispatcher script)
   # Add: sleep 5
   ```

---

## ⚡ **Systemd Service Issues**

### **Problem: Automatic renewal not working**

#### **Diagnosis:**
```bash
# Check service status
systemctl --user status pai-kerberos-renewal.timer
systemctl --user status pai-kerberos-renewal.service

# Check service logs
journalctl --user -u pai-kerberos-renewal.service -n 20
```

#### **Solutions:**
1. **Service Not Enabled:**
   ```bash
   systemctl --user enable pai-kerberos-renewal.timer
   systemctl --user start pai-kerberos-renewal.timer
   ```

2. **Service Failing:**
   ```bash
   # Check service file
   cat ~/.config/systemd/user/pai-kerberos-renewal.service
   
   # Fix path issues
   systemctl --user edit pai-kerberos-renewal.service
   ```

3. **Timer Issues:**
   ```bash
   # Check timer configuration
   systemctl --user list-timers pai-kerberos-renewal.timer
   
   # Reset if needed
   systemctl --user daemon-reload
   systemctl --user restart pai-kerberos-renewal.timer
   ```

---

## 🔒 **Security & Permissions Issues**

### **Problem: "Permission denied" errors**

#### **Diagnosis:**
```bash
# Check script permissions
ls -la ~/.local/bin/pai-*

# Check config directory permissions
ls -la ~/.config/pai/
```

#### **Solutions:**
1. **Script Permissions:**
   ```bash
   chmod +x ~/.local/bin/pai-*
   ```

2. **Config Directory Permissions:**
   ```bash
   chmod 700 ~/.config/pai/
   chmod 600 ~/.config/pai/credentials/*
   ```

### **Problem: "Failed to decrypt password"**

#### **Diagnosis:**
```bash
# Test password decryption
pai-simple-credential-store --status

# Check encryption key
echo "${USER}@$(hostname)@kerberos" | sha256sum
```

#### **Solutions:**
1. **Hostname Changed:**
   ```bash
   # Re-store password with new hostname
   pai-simple-credential-store --remove
   pai-simple-credential-store --store
   ```

2. **Corrupted Credentials:**
   ```bash
   # Remove and re-store
   pai-simple-credential-store --remove
   pai-simple-credential-store --store
   ```

---

## 🖥️ **Desktop Notification Issues**

### **Problem: No desktop notifications appearing**

#### **Diagnosis:**
```bash
# Test notification system
notify-send "Test" "This is a test notification"

# Check DISPLAY variable in service
systemctl --user show-environment | grep DISPLAY
```

#### **Solutions:**
1. **Missing notify-send:**
   ```bash
   # Install notification daemon
   sudo dnf install -y libnotify
   ```

2. **DISPLAY Variable Missing:**
   ```bash
   # Edit service file to include DISPLAY
   systemctl --user edit pai-kerberos-renewal.service
   # Add: Environment=DISPLAY=:0
   ```

3. **Notification Daemon Not Running:**
   ```bash
   # Check notification daemon
   ps aux | grep notification
   
   # Start desktop environment notification service
   /usr/libexec/notification-daemon &
   ```

---

## 🐧 **Distribution-Specific Issues**

### **Fedora 40+**
- **Issue:** SELinux may block scripts
- **Solution:** 
  ```bash
  # Check SELinux context
  ls -Z ~/.local/bin/pai-*
  
  # Fix if needed
  restorecon -R ~/.local/bin/
  ```

### **RHEL 8/9**
- **Issue:** Missing packages
- **Solution:**
  ```bash
  # Enable EPEL repository
  sudo dnf install -y epel-release
  
  # Install required packages
  sudo dnf install -y krb5-workstation openssl
  ```

### **CentOS Stream**
- **Issue:** Different NetworkManager version
- **Solution:**
  ```bash
  # Check NetworkManager version
  nmcli --version
  
  # Update if needed
  sudo dnf update NetworkManager
  ```

---

## 🔍 **Debug Mode**

### **Enable Comprehensive Debugging**
```bash
# Set debug environment variable
export PAI_DEBUG=1

# Run with verbose output
pai-simple-credential-store --test
pai-vpn-kerberos-integration --test-auth
pai-kerberos-auto-renew --renew

# Check all logs
tail -f /tmp/pai-*.log
```

### **Collect Diagnostic Information**
```bash
# Create diagnostic script
cat > diagnose.sh << 'EOF'
#!/bin/bash
echo "=== System Information ==="
uname -a
cat /etc/os-release

echo "=== Network Status ==="
nmcli connection show --active

echo "=== Kerberos Status ==="
klist -A

echo "=== Service Status ==="
systemctl --user status pai-kerberos-renewal.timer

echo "=== Script Permissions ==="
ls -la ~/.local/bin/pai-*

echo "=== Recent Logs ==="
tail -20 /tmp/pai-*.log
EOF

chmod +x diagnose.sh
./diagnose.sh > diagnostic-report.txt
```

---

## 🆘 **Emergency Procedures**

### **Complete Reset**
```bash
# Stop all services
systemctl --user stop pai-kerberos-renewal.timer

# Remove all configurations
rm -rf ~/.config/pai/
rm -f ~/.config/systemd/user/pai-kerberos-renewal.*

# Remove scripts
rm -f ~/.local/bin/pai-*

# Reinstall from scratch
cd laptop-enterprise-automation
./install.sh
```

### **Manual Kerberos Reset**
```bash
# Destroy all tickets
kdestroy -A

# Clear all caches
rm -f /tmp/krb5cc_*

# Manual authentication
kinit your_username@IPA.REDHAT.COM

# Verify tickets
klist
```

---

## 📞 **Getting Help**

### **Before Seeking Support:**
1. ✅ Run diagnostic script above
2. ✅ Check logs in `/tmp/pai-*.log`
3. ✅ Verify system requirements
4. ✅ Try manual authentication first

### **Support Channels:**
- **GitHub Issues**: Detailed bug reports with logs
- **GitHub Discussions**: General questions and ideas
- **Documentation**: Check README.md for common solutions

### **What to Include in Bug Reports:**
- Operating system and version
- Output from diagnostic script
- Relevant log files
- Steps to reproduce the issue
- Expected vs actual behavior

---

**🧙‍♂️ Remember: Most issues are network or configuration related. The magic works when the foundation is solid! ⚡🔧✨**
