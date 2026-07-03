#include "bibs.h"
#include "serialcomm.h"

#include <QQuickWindow>

int main(int argc, char *argv[])
{
    QQuickWindow::setGraphicsApi(QSGRendererInterface::OpenGL);

    QGuiApplication app(argc, argv);
    QQuickStyle::setStyle("Fusion");

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    ESP32 esp32;
    engine.rootContext()->setContextProperty("esp32",&esp32);
    
    engine.loadFromModule("SmartPedalApp", "Main");

    return app.exec();
}
