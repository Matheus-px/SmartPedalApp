#include "bibs.h"
#include "serialcomm.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    qmlRegisterType<ESP32>(
        "ESPFunctions",
        1,
        0,
        "ESP32"
    );
    engine.loadFromModule("SmartPedalApp", "Main");

    return app.exec();
}
