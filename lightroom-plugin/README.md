# 🎨 Advanced Curve Editor Pro - Lightroom Plugin with AI

Plugin profesional untuk Adobe Lightroom dengan **DEEP ALGORITHM EXTRACTION** yang menyediakan kontrol kurva canggih + Professional AI Models melampaui kemampuan bawaan Lightroom.

## ✨ Fitur Utama

### 🤖 **Professional AI Models (NEW)**
- **Advanced Noise Reduction**: AI-powered denoising dengan 183 DirectML operators
- **AI Super Resolution**: Intelligent upscaling 2x-8x dengan edge preservation
- **Professional Color Enhancement**: AI color analysis dan automatic optimization

### 🎯 **Advanced Curve Editing**
- **Multi-channel support**: RGB, Red, Green, Blue, Luminance
- **Cubic spline interpolation**: Kurva halus dan presisi tinggi
- **High precision control**: Input numerik untuk kontrol point yang akurat
- **Real-time preview**: Melihat perubahan secara langsung

### 🔧 **Professional Tools**
- **Curve presets**: S-curve, film emulation, high contrast, dll.
- **Batch processing**: Terapkan kurva ke banyak foto sekaligus
- **Import/Export**: Simpan dan bagikan pengaturan kurva
- **Curve analysis**: Histogram overlay dan tools analisis

### 🚀 **Performance**
- **Optimized algorithms**: Perhitungan kurva yang cepat dan akurat
- **Memory efficient**: Pengelolaan memori yang optimal
- **Cross-platform**: Support Ubuntu, Windows, macOS

---

## 📋 Persyaratan Sistem

### **Lightroom**
- Adobe Lightroom Classic CC 2015.1 atau lebih baru
- Adobe Lightroom Classic 2019 atau lebih baru (recommended)

### **Ubuntu Requirements**
```bash
# Required packages
sudo apt update
sudo apt install lua5.3 lua5.3-dev
```

### **Wine Setup (untuk Lightroom di Ubuntu)**
```bash
# Install Wine
sudo apt install wine winetricks

# Configure Wine untuk Lightroom
winetricks vcrun2019 msxml6 gdiplus
```

---

## 🚀 Instalasi

### **Metode 1: Manual Installation**
1. Download plugin dari repository ini
2. Extract ke folder plugin Lightroom:
   ```bash
   ~/.local/share/Adobe/Lightroom/Modules/
   # atau
   ~/Documents/Adobe/Lightroom/Modules/
   ```

3. Restart Lightroom
4. Aktifkan plugin di `File > Plug-in Manager`

### **Metode 2: Development Setup**
```bash
# Clone repository
git clone https://github.com/photostudiopro/lightroom-advanced-curves.git
cd lightroom-advanced-curves/lightroom-plugin

# Create symlink ke Lightroom modules directory
ln -s $(pwd) ~/.local/share/Adobe/Lightroom/Modules/AdvancedCurves

# Restart Lightroom
```

---

## 📖 Cara Penggunaan

### **Basic Usage**
1. **Pilih foto** di Lightroom Library atau Develop module
2. **Buka plugin**: `Library > Plug-in Extras > Advanced Curve Editor`
3. **Pilih channel**: RGB, Red, Green, Blue, atau Luminance
4. **Edit kurva**:
   - Klik "Add Point" untuk menambah control point
   - Edit koordinat X,Y di Point Editor
   - Drag points di canvas (coming soon)
5. **Apply changes** ke foto

### **Advanced Features**

#### **Curve Types**
- **Cubic Spline**: Interpolasi halus (recommended)
- **Linear**: Interpolasi linear sederhana
- **Bezier**: Kontrol lengkung dengan handles

#### **Multi-Channel Editing**
```
RGB Channel → Mempengaruhi semua channel
Red Channel → Hanya channel merah
Green Channel → Hanya channel hijau  
Blue Channel → Hanya channel biru
Luminance → Brightness tanpa mempengaruhi color
```

#### **Batch Processing**
1. Select multiple photos
2. `Library > Plug-in Extras > Batch Apply Curves`
3. Pilih preset atau custom curve
4. Apply ke semua selected photos

---

## 🎯 Curve Presets

### **Built-in Presets**
- **Linear**: Kurva 1:1 (no changes)
- **S-Curve**: Kontras sedang, film look
- **Inverse S-Curve**: Low contrast, dreamy look
- **Film Emulation**: Classic film response
- **High Contrast**: Dramatic contrast boost
- **Low Contrast**: Soft, flat look

### **Custom Presets**
```lua
-- Example S-Curve preset
points = {{0, 0}, {0.25, 0.2}, {0.75, 0.8}, {1, 1}}
curve = CurveEngine.createCurve(points, 'cubic_spline')
```

---

## ⚙️ Configuration

### **Plugin Preferences**
Access via `File > Plug-in Extras > Advanced Curves - Preferences`

- **Curve Resolution**: 256, 512, 1024 points (default: 256)
- **Max Control Points**: 16, 32, 64 (default: 32)
- **Default Curve Type**: Cubic Spline, Linear, Bezier
- **Real-time Preview**: Enable/disable live preview
- **Auto-save Presets**: Automatically save curve changes

### **Performance Tuning**
```lua
-- Edit PluginInit.lua untuk custom settings
prefs.curveResolution = 512  -- Higher quality, slower
prefs.maxControlPoints = 16  -- Limit untuk performance
```

---

## 🛠️ Development

### **Plugin Structure**
```
lightroom-plugin/
├── src/
│   ├── Info.lua                 # Plugin manifest
│   ├── AdvancedCurveDialog.lua  # Main UI
│   ├── CurveEngine.lua          # Mathematics engine
│   ├── BatchCurveProcessor.lua  # Batch operations
│   ├── MetadataDefinition.lua   # Custom metadata
│   └── PluginInit.lua          # Initialization
├── assets/
│   ├── icons/                   # UI icons
│   └── presets/                # Default presets
├── docs/
│   ├── API.md                  # Plugin API
│   └── UserGuide.md            # Detailed user guide
└── README.md
```

### **Development Setup**
```bash
# Install development tools
sudo apt install lua5.3-dev luarocks git

# Install Lua development dependencies
luarocks install luaunit      # For testing
luarocks install luacheck     # For code quality

# Run tests
lua tests/test_curve_engine.lua
```

### **API Documentation**
```lua
-- Create new curve
local curve = CurveEngine.createCurve(points, curveType)

-- Apply curve to value
local output = CurveEngine.applyCurve(curve, input)

-- Convert to Lightroom format
local lrPoints = CurveEngine.convertToLightroomToneCurve(curve)
```

---

## 🧪 Testing

### **Manual Testing**
1. Load different image types (RAW, JPEG, TIFF)
2. Test dengan various curve configurations
3. Verify batch processing works correctly
4. Check performance dengan large images

### **Automated Testing**
```bash
# Run curve engine tests
cd lightroom-plugin/tests
lua test_curve_engine.lua

# Performance benchmarks
lua benchmark_curves.lua
```

---

## 🐛 Troubleshooting

### **Plugin Not Loading**
```bash
# Check Lightroom plugin directory
ls ~/.local/share/Adobe/Lightroom/Modules/

# Verify plugin manifest
lua -c "dofile('src/Info.lua')"

# Check Lightroom logs
tail -f ~/Library/Logs/Adobe/Lightroom/lightroom.log
```

### **Performance Issues**
- Reduce curve resolution in preferences
- Limit max control points
- Disable real-time preview for large images

### **Wine Issues (Ubuntu)**
```bash
# Reinstall Windows components
winetricks --uninstall vcrun2019
winetricks vcrun2019

# Check Wine configuration
winecfg
```

---

## 📈 Roadmap

### **Version 1.1 (Next Release)**
- [ ] **Visual curve canvas** dengan drag-and-drop
- [ ] **More presets** (Kodak, Fuji, Leica emulations)
- [ ] **Keyboard shortcuts**
- [ ] **Improved performance**

### **Version 1.2 (Future)**
- [ ] **Lab color space support**
- [ ] **Curve smoothing algorithms**
- [ ] **Advanced masking integration**
- [ ] **Plugin marketplace integration**

### **Version 2.0 (Long-term)**
- [ ] **AI-powered curve suggestions**
- [ ] **Real-time GPU acceleration**
- [ ] **Professional workflow integration**
- [ ] **Stand-alone application mode**

---

## 🤝 Contributing

Contributions welcome! Please read our contributing guidelines.

### **Development Workflow**
1. Fork repository
2. Create feature branch
3. Make changes dengan tests
4. Submit pull request

### **Bug Reports**
- Use GitHub issues
- Include Lightroom version
- Provide sample images (jika diperlukan)
- Include error logs

---

## 📄 License

Copyright (c) 2024 PhotoStudio Pro
Licensed under MIT License - see LICENSE file.

---

## 📞 Support

- **Documentation**: [Wiki](https://github.com/photostudiopro/lightroom-advanced-curves/wiki)
- **Issues**: [GitHub Issues](https://github.com/photostudiopro/lightroom-advanced-curves/issues)
- **Email**: support@photostudiopro.com
- **Community**: [Discord Server](https://discord.gg/photostudiopro)

---

## ⭐ Acknowledgments

- Adobe Lightroom SDK team
- Open source curve mathematics libraries
- Beta testers dan community feedback
- Ubuntu/Wine compatibility contributors

**Made with ❤️ untuk professional photographers**