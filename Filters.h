#ifndef FILTERS_H
#define FILTERS_H

#include "bibs.h"

class Filters
{
public: 
    // Builder
    Filters();
    Filters(bool bitcrusher, bool delay, bool drive, bool equalizer, bool tremolo);

    // Getters
    bool bitcrusher() { return m_bitcrusher; }
    bool delay()      { return m_delay; }
    bool drive()      { return m_drive; }
    bool equalizer()  { return m_equalizer; }
    bool tremolo()    { return m_tremolo; }

    // Setters
    void setBitcrusher(bool bitcrusher) { m_bitcrusher = bitcrusher; }
    void setDelay(bool delay)           { m_delay = delay; }
    void setDrive(bool drive)           { m_drive = drive; }
    void setEqualizer(bool equalizer)   { m_equalizer = equalizer; }
    void setTremolo(bool tremolo)       { m_tremolo = tremolo; }

    // Json methods
    Filters     fromJson(const QJsonObject &json);
    Filters     loadFromJson(const QString &filename);
    QJsonObject toJson();
    bool        saveToJson(QString &filename);

private:
    bool m_bitcrusher;
    bool m_delay;
    bool m_drive;
    bool m_equalizer;
    bool m_tremolo;
};

#endif