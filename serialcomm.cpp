#include "serialcomm.h"

ESP32::ESP32(QObject *parent) : QObject(parent)
{
    //connectToESP32();
    connect(&serial, &QSerialPort::readyRead, this, &ESP32::readData);
}

void ESP32::connectToESP32()
{
    for (const QSerialPortInfo &port : QSerialPortInfo::availablePorts())
        qDebug() << "Found:" << port.portName() << port.description();
    
    // PORTA,TROCAR
    serial.setPortName("COM3");

    serial.setBaudRate(QSerialPort::Baud115200);
    serial.setDataBits(QSerialPort::Data8);
    serial.setParity(QSerialPort::NoParity);
    serial.setStopBits(QSerialPort::OneStop);
    serial.setFlowControl(QSerialPort::NoFlowControl);

    if (serial.open(QIODevice::ReadWrite))
    {
        qDebug() << "Connected to ESP32";
        sendCommand("HELLO\n");
    }
    else
    {
        qDebug() << "Connection failed:" << serial.errorString();
    }
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