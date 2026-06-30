#include "serialcomm.h"
#include <QDebug>

#if defined(Q_OS_ANDROID)
#include <unistd.h> // For raw read/write on Android
#endif

ESP32::ESP32(QObject *parent) : QObject(parent)
{
    //
}

ESP32::~ESP32()
{
    disconnectESP32();
}

void ESP32::connectToESP32()
{
#if defined(Q_OS_ANDROID)
    // --- ANDROID LOGIC ---
    qDebug() << "Requesting USB permissions via Android JNI...";
    
    // Call your custom Java class to handle the Android UsbManager
    QJniObject javaSerialWrapper = QJniObject("com/yourcompany/app/UsbSerialHelper");
    m_fileDescriptor = javaSerialWrapper.callMethod<jint>("openDevice");

    if (m_fileDescriptor != -1)
    {
        qDebug() << "Android USB Port Opened successfully!";
        emit connectionStatus(true);
        sendCommand("HELLO\n");
    } 
    else
    {
        qDebug() << "Failed to open Android USB port.";
        emit connectionStatus(false);
    }

#else
    // --- DESKTOP LOGIC ---
    if (serial.isOpen()) serial.close();
    bool connected = false;

    for (const QSerialPortInfo &port : QSerialPortInfo::availablePorts())
    {
        int vid = port.vendorIdentifier();
        if (vid == 0x10C4 || vid == 0x1A86 || vid == 0x303A || vid == 0x0403)
        {
            serial.setPort(port);
            serial.setBaudRate(QSerialPort::Baud115200);
            
            if (serial.open(QIODevice::ReadWrite))
            {
                connected = true;
                emit connectionStatus(true);
                //sendCommand("HELLO\n");
                break;
            }
        }
    }
    if (!connected) emit connectionStatus(false);
#endif
}

void ESP32::disconnectESP32()
{
#if defined(Q_OS_ANDROID)
    if (m_fileDescriptor != -1)
    {
        close(m_fileDescriptor);
        m_fileDescriptor = -1;
        emit connectionStatus(false);
    }
#else
    if (serial.isOpen())
    {
        serial.close();
        emit connectionStatus(false);
    }
#endif
}

void ESP32::sendToESP32(const QVariantList &filters)
{
    QString message;
    for (const QVariant &item : filters)
    {
        QVariantMap map = item.toMap();
        message += QString::number(map["effectId"].toInt()) + "," + QString::number(map["enable"].toBool()) + "\n";
    }
    message += "END\n";
    sendCommand(message);
    qDebug().noquote() << message;
}

void ESP32::sendCommand(const QString &cmd)
{
    QByteArray payload = cmd.toUtf8();

#if defined(Q_OS_ANDROID)
    if (m_fileDescriptor != -1)
    {
        // Write directly to the Android file descriptor
        write(m_fileDescriptor, payload.data(), payload.size());
    }
#else
    if (serial.isOpen() && serial.isWritable())
    {
        serial.write(payload);
        serial.flush();
        qDebug() << "message sent";
    }
    
#endif
}
