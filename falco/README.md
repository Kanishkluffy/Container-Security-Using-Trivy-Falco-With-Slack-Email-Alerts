# Falco Runtime Security Monitoring

Runtime security monitoring for the DevSecOps project using Falco with modern eBPF driver.

## 📋 Overview

Falco monitors runtime behavior and detects:
- Shell execution in containers
- Sensitive file access (`/etc/passwd`, `/etc/shadow`)
- Suspicious command execution
- Python subprocess spawning
- Network reconnaissance tools
- Package manager usage

## 🔧 Installation

### Step 1: Install Falco

```bash
chmod +x install-falco.sh
./install-falco.sh
```

This installs:
- Falco binary and systemd services
- falcoctl CLI tool
- Modern eBPF driver (no kernel modules needed)

### Step 2: Setup Custom Rules

```bash
chmod +x setup-falco.sh
./setup-falco.sh
```

This configures:
- Default Falco rules from falcosecurity
- Custom DevSecOps rules for container monitoring
- falcoctl for rule management
- JSON output for alert parsing

## 🚀 Usage

### Method 1: Run as Systemd Service (Recommended)

```bash
# Start Falco
sudo systemctl start falco-modern-bpf

# Enable on boot
sudo systemctl enable falco-modern-bpf

# Check status
sudo systemctl status falco-modern-bpf

# View logs
sudo journalctl -u falco-modern-bpf -f
```

### Method 2: Run Manually

```bash
chmod +x run-falco.sh
sudo ./run-falco.sh
```

Keep the terminal open to see real-time alerts.

## 🧪 Testing

### Run Test Suite

```bash
chmod +x test-falco-alerts.sh
./test-falco-alerts.sh
```

This triggers:
- Shell execution (whoami, id, ps)
- Sensitive file reads (/etc/passwd)
- Python subprocess calls

### Manual Testing

```bash
# Trigger shell execution alert
docker exec devsecops-demo-app /bin/sh -c "whoami"

# Trigger file read alert
docker exec devsecops-demo-app /bin/sh -c "cat /etc/passwd"

# Check Falco detected them
sudo journalctl -u falco-modern-bpf -n 20
```

## 📁 Files

```
falco/
├── install-falco.sh              # Installs Falco + falcoctl
├── setup-falco.sh                # Configures custom rules
├── run-falco.sh                  # Runs Falco manually
├── falco-custom-rules.yaml       # Custom security rules
├── test-falco-alerts.sh          # Triggers test alerts
└── README.md                     # This file
```

## 🔍 Viewing Alerts

### Real-time logs (systemd):
```bash
sudo journalctl -u falco-modern-bpf -f
```

### Log file:
```bash
sudo tail -f /var/log/falco/events.txt
```

### Recent alerts:
```bash
sudo journalctl -u falco-modern-bpf -n 50 | grep -i "warning\|critical"
```

## 🔄 Rule Management with falcoctl

### List available rules:
```bash
falcoctl artifact search rules
```

### Install additional rules:
```bash
sudo falcoctl artifact install falco-incubating-rules
```

### Update rules:
```bash
sudo falcoctl artifact follow
```

## 🛠️ Configuration Files

### Falco configuration:
- `/etc/falco/falco.yaml` - Main config
- `/etc/falco/falco_rules.yaml` - Default rules
- `/etc/falco/rules.d/` - Custom rules directory

### falcoctl configuration:
- `/etc/falcoctl/falcoctl.yaml` - falcoctl config
- Indexes: https://falcosecurity.github.io/falcoctl/index.yaml

## 🐛 Troubleshooting

### Falco not starting:
```bash
# Check service status
sudo systemctl status falco-modern-bpf

# Check logs for errors
sudo journalctl -u falco-modern-bpf -n 50

# Verify driver installed
sudo falcoctl driver printenv
```

### No alerts appearing:
```bash
# Verify container name matches rules
docker ps --format "{{.Names}}"

# Check rules are loaded
sudo falco --list-rules | grep "Shell Spawned"

# Run in verbose mode
sudo falco --modern-bpf -c /etc/falco/falco.yaml -o log_level=debug
```

### Reinstall driver:
```bash
sudo falcoctl driver cleanup
sudo falcoctl driver install
```

## 📚 References

- [Falco Official Docs](https://falco.org/docs/)
- [Falco Linux Quickstart](https://falco.org/docs/getting-started/falco-linux-quickstart/)
- [falcoctl Documentation](https://github.com/falcosecurity/falcoctl)
- [Falco Rules Repository](https://github.com/falcosecurity/rules)

## 🎯 Integration with Project

Falco integrates with:
1. **Trivy** - Scans images before deployment
2. **Falco** - Monitors runtime after deployment
3. **Slack/Email** - Sends alerts when threats detected

## ⚙️ systemd Services

Available services:
- `falco-modern-bpf.service` - Modern eBPF (recommended)
- `falco-bpf.service` - Legacy eBPF
- `falco-kmod.service` - Kernel module

Check which is enabled:
```bash
sudo systemctl list-units --all | grep falco
```

## 🔐 Security Notes

- Falco runs as root (required for system call monitoring)
- Modern eBPF is the recommended driver (no kernel module)
- Custom rules are specific to container `devsecops-demo-app`
- Alerts are logged locally and can be forwarded to SIEM

---

**For the complete DevSecOps project, see the main README.md**