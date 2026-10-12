# Felix Official APT Repository

Official APT Package Repository for **Felix Security Auditor** (`v2.0.0`) on Kali Linux, Debian, and Ubuntu.

## Quick Install (Kali Linux / Debian)

### 1. One-Line Setup

Run the official repository setup script:

```bash
curl -fsSL https://jothish-blip.github.io/apt-repo/setup.sh | sudo bash
```

### 2. Install Felix

```bash
sudo apt update
sudo apt install felix
```

### 3. Verify Installation

```bash
felix --version
felix doctor
```

---

## Manual Repository Setup

If you prefer to configure the APT repository manually:

```bash
# 1. Create modern keyrings directory
sudo mkdir -p /etc/apt/keyrings

# 2. Download and verify the official repository GPG key
curl -fsSL https://jothish-blip.github.io/apt-repo/felix-archive-keyring.gpg | sudo tee /etc/apt/keyrings/felix-archive-keyring.gpg > /dev/null
sudo chmod 0644 /etc/apt/keyrings/felix-archive-keyring.gpg

# 3. Add the APT repository source
echo "deb [signed-by=/etc/apt/keyrings/felix-archive-keyring.gpg arch=amd64] https://jothish-blip.github.io/apt-repo stable main" | sudo tee /etc/apt/sources.list.d/felix.list
sudo chmod 0644 /etc/apt/sources.list.d/felix.list

# 4. Update index and install
sudo apt update
sudo apt install -y felix
```

---

## Clean Uninstallation

### Standard Removal
Removes Felix binaries and system completions while **strictly preserving** your assessment databases, scan reports, and configurations in `~/.felix/`:

```bash
sudo apt remove felix
```

### Complete Purge
Removes all system configuration files:

```bash
sudo apt purge felix
sudo rm -f /etc/apt/sources.list.d/felix.list /etc/apt/keyrings/felix-archive-keyring.gpg
```
