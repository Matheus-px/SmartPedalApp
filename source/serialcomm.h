#ifndef SERIALCOMM_H
#define SERIALCOMM_H

#pragma once

#include <QObject>
#include <QVariantList>
#include <QVariantMap>

// Conditionally include headers based on the OS
#if defined(Q_OS_ANDROID)
    #include <QtCore/QJniObject>
#else
    #include <QSerialPort>
    #include <QSerialPortInfo>
#endif

class ESP32 : public QObject
{
    Q_OBJECT

public:
    explicit ESP32(QObject *parent = nullptr);
    ~ESP32();

    Q_INVOKABLE void connectToESP32();
    Q_INVOKABLE void disconnectESP32();
    Q_INVOKABLE void sendToESP32(const QVariantList &filters);

signals:
    void connectionStatus(bool connected);

private:
    void sendCommand(const QString &cmd);

#if defined(Q_OS_ANDROID)
    // Android requires an integer File Descriptor instead of QSerialPort
    int m_fileDescriptor = -1; 
#else
    // Desktop uses standard QSerialPort
    QSerialPort serial;
#endif
};

#endif // SERIALCOMM_H