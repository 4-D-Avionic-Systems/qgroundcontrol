#pragma once

#include <QObject>
#include <QString>
#include <QVariantMap>
#include <QJsonDocument>

class FourDRequestItems : public QObject
{
    Q_OBJECT

public:
    explicit FourDRequestItems(QObject* parent = nullptr);

    explicit FourDRequestItems(QObject* parent,
                               QString droneNickname,
                               QString faaRegistrationNumber,
                               int horizontalLOSBound,
                               int verticalLOSBound,
                               int secondsToMissionStart,
                               bool lidarAvailable);

    explicit FourDRequestItems(const QVariantMap& map, QObject* parent = nullptr);

    ~FourDRequestItems();

    QString toJson();

private:
    QString _droneNickname;
    QString _faaRegistrationNumber;
    int _horizontalLOSBound = 0;
    int _verticalLOSBound = 0;
    int _secondsToMissionStart = 0;
    bool _lidarAvailable = false;
};