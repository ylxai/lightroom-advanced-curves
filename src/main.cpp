/**
 * PhotoStudio Pro - Professional Image Processing Suite
 * 
 * Main application entry point
 * 
 * Features:
 * - Professional RAW processing (LibRAW integration)
 * - Advanced color management (LCMS2)
 * - GPU-accelerated processing (OpenCL/DirectML)
 * - Interactive curve editing
 * - AI-powered enhancements
 * 
 * Copyright (c) 2024 PhotoStudio Team
 * Licensed under Commercial License
 */

#include <QApplication>
#include <QStyleFactory>
#include <QDir>
#include <QStandardPaths>
#include <QCommandLineParser>
#include <QMessageBox>
#include <QSplashScreen>
#include <QPixmap>
#include <QTimer>

#include "ui/MainWindow.h"
#include "core/Application.h"
#include "core/ConfigManager.h"
#include "core/PluginManager.h"
#include "core/PerformanceProfiler.h"
#include "gpu/GPUManager.h"

#ifdef DIRECTML_ENABLED
#include "gpu/DirectMLProcessor.h"
#endif

// Application metadata
constexpr char APP_NAME[] = "PhotoStudio Pro";
constexpr char APP_VERSION[] = "1.0.0";
constexpr char APP_ORGANIZATION[] = "PhotoStudio";
constexpr char APP_DOMAIN[] = "photostudio.pro";

class PhotoStudioApplication : public QApplication {
public:
    PhotoStudioApplication(int& argc, char** argv) 
        : QApplication(argc, argv) {
        
        // Set application properties
        setApplicationName(APP_NAME);
        setApplicationVersion(APP_VERSION);
        setOrganizationName(APP_ORGANIZATION);
        setOrganizationDomain(APP_DOMAIN);
        
        // Enable high DPI support
        setAttribute(Qt::AA_EnableHighDpiScaling, true);
        setAttribute(Qt::AA_UseHighDpiPixmaps, true);
    }
    
    bool initialize() {
        // Initialize logging
        if (!initializeLogging()) {
            return false;
        }
        
        // Load configuration
        config_manager = std::make_unique<PhotoStudio::ConfigManager>();
        if (!config_manager->initialize()) {
            QMessageBox::critical(nullptr, "Error", "Failed to initialize configuration system.");
            return false;
        }
        
        // Initialize GPU subsystem
        gpu_manager = std::make_unique<PhotoStudio::GPUManager>();
        if (!gpu_manager->initialize()) {
            QMessageBox::warning(nullptr, "Warning", 
                "GPU acceleration not available. Application will run with CPU-only processing.");
        }
        
        // Initialize plugin system
        plugin_manager = std::make_unique<PhotoStudio::PluginManager>();
        plugin_manager->loadPlugins(getPluginDirectory());
        
        // Apply theme
        applyTheme();
        
        return true;
    }
    
    void showSplashScreen() {
        // Create splash screen
        QPixmap splash_pixmap(":/images/splash.png");
        splash_screen = std::make_unique<QSplashScreen>(splash_pixmap);
        splash_screen->show();
        
        // Show initialization progress
        splash_screen->showMessage("Initializing PhotoStudio Pro...", 
                                  Qt::AlignBottom | Qt::AlignCenter, Qt::white);
        
        processEvents();
    }
    
    void hideSplashScreen() {
        if (splash_screen) {
            splash_screen->finish(main_window.get());
            splash_screen.reset();
        }
    }
    
    bool createMainWindow() {
        main_window = std::make_unique<PhotoStudio::MainWindow>();
        
        // Connect application-level signals
        connect(main_window.get(), &PhotoStudio::MainWindow::applicationExit,
                this, &PhotoStudioApplication::quit);
        
        return true;
    }
    
    void showMainWindow() {
        if (main_window) {
            main_window->show();
            main_window->raise();
            main_window->activateWindow();
        }
    }
    
private:
    std::unique_ptr<PhotoStudio::ConfigManager> config_manager;
    std::unique_ptr<PhotoStudio::GPUManager> gpu_manager;
    std::unique_ptr<PhotoStudio::PluginManager> plugin_manager;
    std::unique_ptr<PhotoStudio::MainWindow> main_window;
    std::unique_ptr<QSplashScreen> splash_screen;
    
    bool initializeLogging() {
        // Setup logging directory
        QString log_dir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/logs";
        QDir().mkpath(log_dir);
        
        // Initialize spdlog or Qt logging
        // Implementation would go here
        return true;
    }
    
    QString getPluginDirectory() const {
        QString app_dir = applicationDirPath();
        
#ifdef Q_OS_WIN
        return app_dir + "/plugins";
#elif defined(Q_OS_MAC)
        return app_dir + "/../PlugIns";
#else
        return app_dir + "/plugins";
#endif
    }
    
    void applyTheme() {
        QString theme = config_manager ? config_manager->getValue("ui/theme", "dark").toString() : "dark";
        
        if (theme == "dark") {
            // Load dark theme stylesheet
            QFile style_file(":/themes/dark.qss");
            if (style_file.open(QFile::ReadOnly)) {
                setStyleSheet(style_file.readAll());
            }
        } else {
            // Use system theme
            setStyle(QStyleFactory::create("Fusion"));
        }
    }
};

void setupCommandLineOptions(QCommandLineParser& parser) {
    parser.setApplicationDescription("Professional Image Processing Suite");
    parser.addHelpOption();
    parser.addVersionOption();
    
    // File options
    parser.addOption({{"f", "file"}, "Open image file on startup", "file"});
    parser.addOption({{"d", "directory"}, "Set working directory", "directory"});
    
    // Performance options
    parser.addOption({{"no-gpu"}, "Disable GPU acceleration"});
    parser.addOption({{"threads"}, "Set number of processing threads", "count"});
    
    // Debug options
    parser.addOption({{"debug"}, "Enable debug mode"});
    parser.addOption({{"profile"}, "Enable performance profiling"});
    
    // Plugin options
    parser.addOption({{"no-plugins"}, "Disable plugin loading"});
    parser.addOption({{"plugin-dir"}, "Additional plugin directory", "directory"});
}

bool checkSystemRequirements() {
    // Check minimum system requirements
    // RAM, GPU capabilities, etc.
    
    // This would contain actual system checks
    return true;
}

void handleCrash() {
    // Crash handler implementation
    // Save recovery data, send crash reports, etc.
}

int main(int argc, char *argv[]) {
    // Enable crash handling
    // setupCrashHandler();
    
    // Create application instance
    PhotoStudioApplication app(argc, argv);
    
    // Setup command line parser
    QCommandLineParser parser;
    setupCommandLineOptions(parser);
    parser.process(app);
    
    // Check system requirements
    if (!checkSystemRequirements()) {
        QMessageBox::critical(nullptr, "System Requirements", 
            "Your system does not meet the minimum requirements for PhotoStudio Pro.\n"
            "Please check the documentation for system requirements.");
        return -1;
    }
    
    // Show splash screen
    app.showSplashScreen();
    
    // Initialize application
    if (!app.initialize()) {
        QMessageBox::critical(nullptr, "Initialization Error", 
            "Failed to initialize PhotoStudio Pro. Please check your installation.");
        return -1;
    }
    
    // Update splash screen
    QTimer::singleShot(1000, [&]() {
        // Create main window
        if (!app.createMainWindow()) {
            QMessageBox::critical(nullptr, "Startup Error", 
                "Failed to create main window.");
            app.quit();
            return;
        }
        
        // Hide splash and show main window
        app.hideSplashScreen();
        app.showMainWindow();
        
        // Process command line arguments
        if (parser.isSet("file")) {
            QString file_path = parser.value("file");
            // Load file in main window
            // main_window->openFile(file_path);
        }
        
        if (parser.isSet("directory")) {
            QString dir_path = parser.value("directory");
            // Set working directory
            // main_window->setWorkingDirectory(dir_path);
        }
    });
    
    // Start event loop
    return app.exec();
}