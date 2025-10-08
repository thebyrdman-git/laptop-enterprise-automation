# 🧙‍♂️🌐 Browser Kerberos Integration Guide
## Seamless Red Hat SSO for Chrome, Firefox, and Edge

### **🎯 What This Provides**

- **Automatic login** to Red Hat websites
- **Single Sign-On (SSO)** across all Red Hat services
- **No more password prompts** for authenticated sites
- **Enterprise-grade security** with Kerberos delegation

### **🌐 Supported Red Hat Domains**

The following domains will automatically authenticate:
- `*.redhat.com` - Main Red Hat website and services
- `*.corp.redhat.com` - Internal corporate sites
- `*.ipa.redhat.com` - Identity management
- `*.access.redhat.com` - Customer portal and support
- `*.console.redhat.com` - Red Hat console and management
- `*.cloud.redhat.com` - Red Hat Cloud services
- `*.developers.redhat.com` - Developer resources

### **🚀 Using Kerberos-Enabled Browsers**

#### **Google Chrome with SSO**
```bash
# Launch Chrome with Kerberos support
google-chrome-kerberos

# Or use desktop launcher: "Google Chrome (Red Hat SSO)"
```

#### **Firefox with SSO**
```bash
# Launch Firefox with Kerberos support  
firefox-kerberos

# Or use desktop launcher: "Firefox (Red Hat SSO)"
```

#### **Testing SSO**
1. **Ensure Kerberos tickets are active:**
   ```bash
   klist  # Should show active tickets
   ```

2. **Launch Kerberos-enabled browser**
3. **Navigate to Red Hat site:**
   - https://access.redhat.com
   - https://console.redhat.com
   - https://cloud.redhat.com

4. **Verify automatic login** - no password prompts!

### **🔧 Troubleshooting Browser SSO**

#### **Problem: Still prompted for passwords**

**Solution 1: Check Kerberos tickets**
```bash
# Verify active tickets
klist

# Renew if needed
pai-simple-credential-store --kinit
```

**Solution 2: Verify browser configuration**
```bash
# Check Chrome flags
ps aux | grep chrome | grep auth-server-whitelist

# Check Firefox config
grep negotiate ~/.mozilla/firefox/*/user.js
```

**Solution 3: Test browser launcher**
```bash
# Test Chrome Kerberos launcher
google-chrome-kerberos --version

# Test Firefox launcher
firefox-kerberos --version
```

#### **Problem: Browser not using Kerberos**

**Check browser security settings:**
- Ensure cookies are enabled for Red Hat domains
- Disable strict privacy settings that block authentication
- Clear browser cache and cookies for Red Hat sites

**Verify network connectivity:**
```bash
# Test Red Hat site access
curl -I https://access.redhat.com

# Check corporate network
pai-vpn-kerberos-integration --status
```

### **⚙️ Advanced Configuration**

#### **Custom Domain Lists**
Edit the browser launcher scripts in `~/.local/bin/` to modify domain lists:
```bash
# Edit Chrome launcher
vi ~/.local/bin/google-chrome-kerberos

# Modify RED_HAT_DOMAINS variable
RED_HAT_DOMAINS="*.redhat.com,*.mycompany.com"
```

#### **Firefox Advanced Settings**
Access `about:config` in Firefox and modify:
- `network.negotiate-auth.trusted-uris`
- `network.negotiate-auth.delegation-uris`
- `network.automatic-ntlm-auth.trusted-uris`

#### **Security Considerations**
- **Only trusted domains** are configured for Kerberos
- **Credential delegation** limited to Red Hat corporate domains
- **Browser isolation** - Kerberos settings don't affect regular browsing
- **Session management** - SSO tied to active Kerberos tickets

### **🎪 Integration with VPN Automation**

The browser SSO integrates seamlessly with VPN automation:

1. **Connect Red Hat VPN** → Automatic Kerberos authentication
2. **Launch Kerberos browser** → Immediate Red Hat SSO access
3. **Browse Red Hat sites** → No authentication friction
4. **Disconnect VPN** → SSO continues until ticket expiration

### **📱 Mobile and Remote Access**

While this solution is for laptop/desktop browsers, Red Hat SSO works across:
- **Mobile browsers** (when on VPN with certificates)
- **Red Hat mobile apps** (with proper authentication setup)  
- **Remote sessions** (SSH with X11 forwarding + Kerberos delegation)

---

**🌐 Never enter Red Hat passwords in browsers again - seamless enterprise SSO with unlimited power! ⚡🏰✨**
