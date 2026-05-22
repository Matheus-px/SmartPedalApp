#ifndef SERIALCOMM_H
#define SERIALCOMM_H

#include <QCoreApplication>
#include <QSerialPort>
#include <QSerialPortInfo>
#include <QDebug>
#include <QObject>

class ESP32 : public QObject
{
    Q_OBJECT

public:
    explicit ESP32(QObject *parent = nullptr);

    void connectToESP32();
    void sendCommand(const QString &cmd);
private slots:
    void readData();

private:
    QSerialPort serial;
};
#endif // SERIALCOMM_H