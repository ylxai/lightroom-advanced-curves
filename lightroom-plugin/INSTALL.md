# 🚀 Instalasi Advanced Curve Editor Plugin

## Panduan Instalasi untuk Ubuntu

### 📋 Persiapan Sistem

#### 1. Update sistem Ubuntu
```bash
sudo apt update && sudo apt upgrade -y
```

#### 2. Install dependencies dasar
```bash
sudo apt install -y git curl wget build-essential lua5.3 lua5.3-dev luarocks
```

#### 3. Setup Wine untuk Lightroom (Pilihan)
```bash
# Install Wine
sudo dpkg --add-architecture i386
sudo mkdir -pm755 /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources

sudo apt update
sudo apt install -y winehq-stable winetricks

# Setup Wine prefix
WINEARCH=win64 winecfg

# Install Windows components untuk Lightroom
winetricks -q vcrun2019 msxml6 gdiplus corefonts
```

---

### 🔧 Instalasi Plugin

#### Metode 1: Instalasi Otomatis (Recommended)
```bash
# Clone repository
git clone https://github.com/photostudiopro/lightroom-advanced-curves.git
cd lightroom-advanced-curves/lightroom-plugin

# Jalankan script setup
./setup.sh

# Untuk setup dengan Wine
./setup.sh --wine
```

#### Metode 2: Instalasi Manual
```bash
# 1. Download plugin
wget -O advanced-curves.zip https://github.com/photostudiopro/lightroom-advanced-curves/archive/main.zip
unzip advanced-curves.zip
cd lightroom-advanced-curves-main/lightroom-plugin

# 2. Test plugin
lua5.3 test_plugin.lua

# 3. Copy ke direktori Lightroom
mkdir -p ~/.local/share/Adobe/Lightroom/Modules
cp -r . ~/.local/share/Adobe/Lightroom/Modules/AdvancedCurves

# 4. Set permissions
chmod -R 755 ~/.local/share/Adobe/Lightroom/Modules/AdvancedCurves
```

---

### 🎯 Aktivasi di Lightroom

#### 1. Start Lightroom
```bash
# Native Lightroom (jika ada)
lightroom

# Wine Lightroom
wine ~/.wine/drive_c/Program\ Files/Adobe/Adobe\ Lightroom\ Classic/lightroom.exe
```

#### 2. Enable Plugin
1. Buka **File → Plug-in Manager**
2. Klik **Add**
3. Navigate ke plugin directory:
   - Native: `~/.local/share/Adobe/Lightroom/Modules/AdvancedCurves`
   - Wine: `~/.wine/drive_c/users/USERNAME/AppData/Roaming/Adobe/Lightroom/Modules/AdvancedCurves`
4. Select folder dan klik **OK**
5. Pastikan plugin **Enabled**

---

### ✅ Verifikasi Instalasi

#### 1. Check Plugin Menu
- **Library → Plug-in Extras → Advanced Curve Editor** ✓
- **Library → Plug-in Extras → Batch Apply Curves** ✓

#### 2. Test Basic Functionality
1. Select photo di Library
2. Open **Advanced Curve Editor**
3. Change curve channel ke **Red**
4. Click **Add Point**
5. Set koordinat X: 0.5, Y: 0.7
6. Click **Apply**
7. Verify photo berubah

#### 3. Test Batch Processing
1. Select multiple photos
2. Open **Batch Apply Curves**
3. Select **S-Curve** preset
4. Click **Process**
5. Verify semua photos processed

---

### 🐛 Troubleshooting

#### Plugin Tidak Muncul
```bash
# Check plugin directory
ls -la ~/.local/share/Adobe/Lightroom/Modules/AdvancedCurves/

# Check Info.lua syntax
cd ~/.local/share/Adobe/Lightroom/Modules/AdvancedCurves/
lua5.3 -c "dofile('src/Info.lua')"

# Check permissions
chmod -R 755 ~/.local/share/Adobe/Lightroom/Modules/AdvancedCurves/
```

#### Lightroom Crash saat Load Plugin
```bash
# Check Lightroom logs
tail -f ~/.wine/drive_c/users/$USER/AppData/Roaming/Adobe/Lightroom/lightroom.log

# Test plugin standalone
lua5.3 test_plugin.lua

# Reinstall dengan dependencies check
./setup.sh --skip-deps
```

#### Wine Lightroom Issues
```bash
# Reconfigure Wine
winecfg

# Reinstall vcrun
winetricks --uninstall vcrun2019
winetricks vcrun2019

# Check Wine errors
wine ~/.wine/drive_c/Program\ Files/Adobe/Adobe\ Lightroom\ Classic/lightroom.exe 2>&1 | grep -i error
```

#### Performance Issues
```bash
# Reduce curve resolution
# Edit src/PluginInit.lua
prefs.curveResolution = 128  # Default 256

# Limit control points
prefs.maxControlPoints = 16  # Default 32

# Disable real-time preview
prefs.enableRealTimePreview = false
```

---

### 📊 Performance Tuning

#### Untuk sistem Low-End
```lua
-- Edit src/PluginInit.lua
prefs.curveResolution = 128
prefs.maxControlPoints = 16
prefs.enableRealTimePreview = false
```

#### Untuk sistem High-End
```lua
-- Edit src/PluginInit.lua
prefs.curveResolution = 512
prefs.maxControlPoints = 64
prefs.enableRealTimePreview = true
```

---

### 📁 Lokasi File Penting

#### Plugin Files
- **Source**: `~/.local/share/Adobe/Lightroom/Modules/AdvancedCurves/`
- **Config**: `~/.local/share/Adobe/Lightroom/Preferences/`
- **Presets**: `~/.local/share/Adobe/Lightroom/Modules/AdvancedCurves/assets/presets/`

#### Wine Lightroom
- **Lightroom**: `~/.wine/drive_c/Program Files/Adobe/Adobe Lightroom Classic/`
- **Plugin Dir**: `~/.wine/drive_c/users/$USER/AppData/Roaming/Adobe/Lightroom/Modules/`
- **Preferences**: `~/.wine/drive_c/users/$USER/AppData/Roaming/Adobe/Lightroom/Preferences/`

#### Logs
- **Setup Log**: `lightroom-plugin/setup.log`
- **Lightroom Log**: `~/.wine/drive_c/users/$USER/AppData/Roaming/Adobe/Lightroom/lightroom.log`

---

### 🔧 Development Setup

#### Untuk Contributors
```bash
# Clone untuk development
git clone https://github.com/photostudiopro/lightroom-advanced-curves.git
cd lightroom-advanced-curves/lightroom-plugin

# Install development tools
sudo apt install -y luacheck

# Setup development symlink
ln -s $(pwd) ~/.local/share/Adobe/Lightroom/Modules/AdvancedCurvesDev

# Run development tests
lua5.3 test_plugin.lua

# Code quality check
luacheck src/
```

#### Hot Reload Development
```bash
# Create development script
cat > dev_reload.sh << 'EOF'
#!/bin/bash
while inotifywait -e modify,create,delete src/; do
    echo "Reloading plugin..."
    # Restart Lightroom atau reload plugin
    killall lightroom.exe 2>/dev/null || true
    sleep 1
    wine ~/.wine/drive_c/Program\ Files/Adobe/Adobe\ Lightroom\ Classic/lightroom.exe &
done
EOF

chmod +x dev_reload.sh
```

---

### 📞 Support

#### Jika masih ada masalah:
1. **Create issue** di GitHub dengan:
   - Ubuntu version: `lsb_release -a`
   - Lightroom version
   - Error messages
   - setup.log file

2. **Join community** Discord untuk support realtime

3. **Check documentation** di GitHub Wiki

4. **Email support**: support@photostudiopro.com

---

**Selamat menggunakan Advanced Curve Editor! 🎨**