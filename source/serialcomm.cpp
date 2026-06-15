#include "serialcomm.h"

ESP32::ESP32(QObject *parent) : QObject(parent)
{
    //connectToESP32();
    connect(&serial, &QSerialPort::readyRead, this, &ESP32::readData);
}

void ESP32::connectToESP32()
{
    bool connected = false;

    for (const QSerialPortInfo &port : QSerialPortInfo::availablePorts())
    {
        int vid = port.vendorIdentifier();
        if(vid == 0x10C4 || vid == 0x1A86 || vid == 0x303A || vid == 0x0403)
        {
            qDebug() << "Trying:" << port.portName() << port.description();

            serial.setPort(port);

            serial.setBaudRate(QSerialPort::Baud115200);
            serial.setDataBits(QSerialPort::Data8);
            serial.setParity(QSerialPort::NoParity);
            serial.setStopBits(QSerialPort::OneStop);
            serial.setFlowControl(QSerialPort::NoFlowControl);

            if (serial.open(QIODevice::ReadWrite))
            {
                qDebug() << "Connected to:" << port.portName();

                sendCommand("HELLO\n");

                connected = true;
                emit connectionStatus(true);
                break;
            }
            else qDebug() << "Failed:" << serial.errorString();
            emit connectionStatus(false);
        }
    }

    if (!connected)
    { 
        qDebug() << "No ESP32 found";
        emit connectionStatus(false);
    }
}

void ESP32::sendToESP32(const QVariantList &filters)
{
    QString message;

    for (const QVariant &item : filters)
    {
        QVariantMap map = item.toMap();

        int id = map["effectId"].toInt();
        bool enabled = map["enable"].toBool();

        message += QString::number(id)
                + ","
                + QString::number(enabled)
                + "\n";
    }

    message += "END\n";

    qDebug().noquote() << message;

    sendCommand(message);
}

void ESP32::sendCommand(const QString &cmd)
{
    if (serial.isOpen())
    {
        serial.write(cmd.toUtf8());
        serial.flush();
    }
}

void ESP32::readData()
{
    QByteArray data = serial.readAll();

    qDebug() << "ESP32 says:" << data;
}