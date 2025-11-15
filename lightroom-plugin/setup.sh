#!/bin/bash

# Advanced Curve Editor Plugin - Setup Script for Ubuntu
# Copyright (c) 2024 PhotoStudio Pro

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script configuration
PLUGIN_NAME="Advanced Curve Editor"
PLUGIN_DIR="AdvancedCurves"
LR_MODULES_DIR="$HOME/.local/share/Adobe/Lightroom/Modules"
WINE_LR_MODULES_DIR="$HOME/.wine/drive_c/users/$USER/AppData/Roaming/Adobe/Lightroom/Modules"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE} $PLUGIN_NAME Setup Script${NC}"
echo -e "${BLUE}========================================${NC}"
echo

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install system dependencies
install_dependencies() {
    print_status "Installing system dependencies..."
    
    sudo apt update
    
    # Install Lua development tools
    if ! dpkg -l | grep -q lua5.3; then
        print_status "Installing Lua 5.3..."
        sudo apt install -y lua5.3 lua5.3-dev luarocks
    else
        print_status "Lua 5.3 already installed"
    fi
    
    # Install Git if not present
    if ! command_exists git; then
        print_status "Installing Git..."
        sudo apt install -y git
    else
        print_status "Git already installed"
    fi
    
    # Install development tools
    if ! dpkg -l | grep -q build-essential; then
        print_status "Installing build tools..."
        sudo apt install -y build-essential curl wget
    else
        print_status "Build tools already installed"
    fi
}

# Function to setup Wine for Lightroom
setup_wine() {
    print_status "Setting up Wine for Lightroom..."
    
    if ! command_exists wine; then
        print_status "Installing Wine..."
        sudo apt install -y wine winetricks
        
        # Initialize Wine prefix
        print_status "Initializing Wine prefix..."
        WINEARCH=win64 winecfg
        
        # Install required Windows components
        print_status "Installing Windows components..."
        winetricks -q vcrun2019 msxml6 gdiplus corefonts
    else
        print_status "Wine already installed"
    fi
    
    # Check if Lightroom is installed in Wine
    LIGHTROOM_PATH="$HOME/.wine/drive_c/Program Files/Adobe/Adobe Lightroom Classic"
    if [ ! -d "$LIGHTROOM_PATH" ]; then
        print_warning "Lightroom not found in Wine installation"
        print_warning "Please install Lightroom Classic via Wine before continuing"
        echo "Installation guide: https://appdb.winehq.org/objectManager.php?sClass=application&iId=16964"
    else
        print_status "Lightroom found in Wine installation"
    fi
}

# Function to create Lightroom modules directory
create_modules_directory() {
    print_status "Creating Lightroom modules directory..."
    
    # Native Lightroom directory (if exists)
    if [ ! -d "$LR_MODULES_DIR" ]; then
        mkdir -p "$LR_MODULES_DIR"
        print_status "Created native Lightroom modules directory: $LR_MODULES_DIR"
    else
        print_status "Native Lightroom modules directory exists"
    fi
    
    # Wine Lightroom directory
    if [ -d "$HOME/.wine" ]; then
        if [ ! -d "$WINE_LR_MODULES_DIR" ]; then
            mkdir -p "$WINE_LR_MODULES_DIR"
            print_status "Created Wine Lightroom modules directory: $WINE_LR_MODULES_DIR"
        else
            print_status "Wine Lightroom modules directory exists"
        fi
    fi
}

# Function to install plugin
install_plugin() {
    print_status "Installing Advanced Curve Editor plugin..."
    
    CURRENT_DIR=$(pwd)
    PLUGIN_SOURCE_DIR="$CURRENT_DIR/src"
    
    if [ ! -d "$PLUGIN_SOURCE_DIR" ]; then
        print_error "Plugin source directory not found: $PLUGIN_SOURCE_DIR"
        print_error "Please run this script from the lightroom-plugin directory"
        exit 1
    fi
    
    # Install to native Lightroom (if directory exists)
    if [ -d "$LR_MODULES_DIR" ]; then
        NATIVE_PLUGIN_DIR="$LR_MODULES_DIR/$PLUGIN_DIR"
        
        if [ -L "$NATIVE_PLUGIN_DIR" ] || [ -d "$NATIVE_PLUGIN_DIR" ]; then
            print_status "Removing existing plugin installation..."
            rm -rf "$NATIVE_PLUGIN_DIR"
        fi
        
        print_status "Creating symlink for native Lightroom..."
        ln -s "$CURRENT_DIR" "$NATIVE_PLUGIN_DIR"
        print_status "Plugin installed to: $NATIVE_PLUGIN_DIR"
    fi
    
    # Install to Wine Lightroom (if directory exists)
    if [ -d "$WINE_LR_MODULES_DIR" ]; then
        WINE_PLUGIN_DIR="$WINE_LR_MODULES_DIR/$PLUGIN_DIR"
        
        if [ -L "$WINE_PLUGIN_DIR" ] || [ -d "$WINE_PLUGIN_DIR" ]; then
            print_status "Removing existing Wine plugin installation..."
            rm -rf "$WINE_PLUGIN_DIR"
        fi
        
        print_status "Creating symlink for Wine Lightroom..."
        ln -s "$CURRENT_DIR" "$WINE_PLUGIN_DIR"
        print_status "Plugin installed to: $WINE_PLUGIN_DIR"
    fi
}

# Function to validate plugin
validate_plugin() {
    print_status "Validating plugin installation..."
    
    # Check Info.lua syntax
    if lua5.3 -c "dofile('src/Info.lua')" 2>/dev/null; then
        print_status "Plugin manifest (Info.lua) is valid"
    else
        print_error "Plugin manifest (Info.lua) has syntax errors"
        lua5.3 -c "dofile('src/Info.lua')"
        exit 1
    fi
    
    # Check CurveEngine.lua syntax
    if lua5.3 -c "dofile('src/CurveEngine.lua')" 2>/dev/null; then
        print_status "Curve engine is valid"
    else
        print_error "Curve engine has syntax errors"
        lua5.3 -c "dofile('src/CurveEngine.lua')"
        exit 1
    fi
    
    # Check other core files
    for file in "src/AdvancedCurveDialog.lua" "src/BatchCurveProcessor.lua" "src/MetadataDefinition.lua"; do
        if [ -f "$file" ]; then
            if lua5.3 -c "dofile('$file')" 2>/dev/null; then
                print_status "$(basename $file) is valid"
            else
                print_error "$(basename $file) has syntax errors"
                lua5.3 -c "dofile('$file')"
                exit 1
            fi
        fi
    done
}

# Function to run basic tests
run_tests() {
    print_status "Running basic functionality tests..."
    
    # Create simple test
    cat > /tmp/test_curve_engine.lua << 'EOF'
package.path = package.path .. ";src/?.lua"
local CurveEngine = require 'CurveEngine'

-- Test curve creation
print("Testing curve creation...")
local curve = CurveEngine.createCurve({{0, 0}, {1, 1}})
assert(curve ~= nil, "Failed to create curve")
print("✓ Curve creation successful")

-- Test curve evaluation
print("Testing curve evaluation...")
local result = CurveEngine.applyCurve(curve, 0.5)
assert(result ~= nil, "Failed to evaluate curve")
print("✓ Curve evaluation successful")

-- Test Lightroom conversion
print("Testing Lightroom conversion...")
local lrPoints = CurveEngine.convertToLightroomToneCurve(curve)
assert(lrPoints ~= nil, "Failed to convert to Lightroom format")
print("✓ Lightroom conversion successful")

print("All tests passed!")
EOF
    
    if lua5.3 /tmp/test_curve_engine.lua; then
        print_status "Basic tests passed"
    else
        print_error "Basic tests failed"
        exit 1
    fi
    
    rm /tmp/test_curve_engine.lua
}

# Function to create desktop launcher
create_launcher() {
    print_status "Creating desktop launcher..."
    
    LAUNCHER_DIR="$HOME/.local/share/applications"
    LAUNCHER_FILE="$LAUNCHER_DIR/lightroom-wine.desktop"
    
    if [ -d "$HOME/.wine" ] && [ ! -f "$LAUNCHER_FILE" ]; then
        mkdir -p "$LAUNCHER_DIR"
        
        cat > "$LAUNCHER_FILE" << EOF
[Desktop Entry]
Name=Adobe Lightroom Classic (Wine)
Comment=Professional photo editing and management
Exec=wine "$HOME/.wine/drive_c/Program Files/Adobe/Adobe Lightroom Classic/lightroom.exe"
Icon=lightroom
Terminal=false
Type=Application
Categories=Graphics;Photography;
MimeType=image/jpeg;image/png;image/tiff;image/raw;
EOF
        
        chmod +x "$LAUNCHER_FILE"
        print_status "Desktop launcher created: $LAUNCHER_FILE"
    fi
}

# Function to show completion message
show_completion_message() {
    echo
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN} Installation Complete!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo
    echo -e "${BLUE}Next Steps:${NC}"
    echo "1. Start Lightroom (Wine or native)"
    echo "2. Go to File > Plug-in Manager"
    echo "3. Click 'Add' and navigate to the plugin directory"
    echo "4. Select the Advanced Curve Editor plugin"
    echo "5. Enable the plugin"
    echo
    echo -e "${BLUE}Usage:${NC}"
    echo "• Library > Plug-in Extras > Advanced Curve Editor"
    echo "• Library > Plug-in Extras > Batch Apply Curves"
    echo
    echo -e "${BLUE}Plugin Directory:${NC}"
    echo "• Native: $LR_MODULES_DIR/$PLUGIN_DIR"
    echo "• Wine: $WINE_LR_MODULES_DIR/$PLUGIN_DIR"
    echo
    echo -e "${BLUE}Documentation:${NC}"
    echo "• README.md in plugin directory"
    echo "• GitHub: https://github.com/photostudiopro/lightroom-advanced-curves"
    echo
    echo -e "${YELLOW}Troubleshooting:${NC}"
    echo "• Check Lightroom plugin manager for errors"
    echo "• Verify plugin files have correct permissions"
    echo "• See setup.log for detailed installation information"
    echo
}

# Main installation function
main() {
    # Parse command line arguments
    INSTALL_WINE=false
    SKIP_DEPS=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --wine)
                INSTALL_WINE=true
                shift
                ;;
            --skip-deps)
                SKIP_DEPS=true
                shift
                ;;
            --help)
                echo "Usage: $0 [--wine] [--skip-deps] [--help]"
                echo "  --wine      Setup Wine and Lightroom compatibility"
                echo "  --skip-deps Skip system dependency installation"
                echo "  --help      Show this help message"
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    # Log installation
    exec > >(tee -a setup.log)
    exec 2>&1
    
    print_status "Starting installation at $(date)"
    print_status "Installation directory: $(pwd)"
    
    # Check if we're in the right directory
    if [ ! -f "setup.sh" ] || [ ! -d "src" ]; then
        print_error "Please run this script from the lightroom-plugin directory"
        exit 1
    fi
    
    # Install system dependencies
    if [ "$SKIP_DEPS" = false ]; then
        install_dependencies
    else
        print_status "Skipping dependency installation"
    fi
    
    # Setup Wine if requested
    if [ "$INSTALL_WINE" = true ]; then
        setup_wine
    fi
    
    # Create directories and install plugin
    create_modules_directory
    install_plugin
    
    # Validate and test
    validate_plugin
    run_tests
    
    # Create launcher
    create_launcher
    
    # Show completion message
    show_completion_message
    
    print_status "Installation completed at $(date)"
}

# Run main function
main "$@"