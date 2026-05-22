#include "Filters.h"

// Builder

Filters::Filters()
    : m_bitcrusher(false)
    , m_delay(false)
    , m_drive(false)
    , m_equalizer(false)
    , m_tremolo(false)
{}

Filters::Filters(bool bitcrusher, bool delay, bool drive, bool equalizer, bool tremolo)
    : m_bitcrusher(bitcrusher)
    , m_delay(delay)
    , m_drive(drive)
    , m_equalizer(equalizer)
    , m_tremolo(tremolo)
{}

// Json methods

Filters Filters::fromJson(const QJsonObject &json)
{
    Filters f;
    f.m_bitcrusher = json["bitcrusher"].toBool();
    f.m_delay      = json["delay"].toBool();
    f.m_drive      = json["drive"].toBool();
    f.m_equalizer  = json["equalizer"].toBool();
    f.m_tremolo    = json["tremolo"].toBool();
    return f;
}

Filters Filters::loadFromJson(const QString &filename)
{
    QFile file(filename);
    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "Could not open file for reading:" << filename;
        return Filters();
    }

    QByteArray data = file.readAll();
    file.close();

    QJsonDocument doc = QJsonDocument::fromJson(data);
    if (doc.isNull()) {
        qWarning() << "Failed to parse JSON from file:" << filename;
        return Filters();
    }

    return fromJson(doc.object());
}

QJsonObject Filters::toJson()
{
    QJsonObject o;
    o["bitcrusher"] = m_bitcrusher;
    o["delay"]      = m_delay;
    o["drive"]      = m_drive;
    o["equalizer"]  = m_equalizer;
    o["tremolo"]    = m_tremolo;
    return o;
}

bool Filters::saveToJson(QString &filename)
{
    QFile file(filename);
    if (!file.open(QIODevice::WriteOnly)) {
        qWarning() << "Could not open file for writing:" << filename;
        return false;
    }

    QJsonDocument doc(toJson());
    file.write(doc.toJson());
    file.close();
    return true;
}
