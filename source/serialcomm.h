#ifndef SERIALCOMM_H
#define SERIALCOMM_H

#include "bibs.h"

class ESP32 : public QObject
{
    Q_OBJECT

public:
    explicit ESP32(QObject *parent = nullptr);

    Q_INVOKABLE void connectToESP32();
    Q_INVOKABLE void sendToESP32(const QVariantList &effects);
    void sendCommand(const QString &cmd);

signals:
    void connectionStatus(bool connection);

private slots:
    void readData();

private:
    QSerialPort serial;
};
#endif // SERIALCOMM_H