#include "FourDRequestItems.h"
#include <QString>
#include "QGCCorePlugin.h"
#include "SettingsManager.h"
#include "FourDSettings.h"
#include "Fact.h"   

FourDRequestItems::FourDRequestItems(QObject* parent) : QObject(parent)
{
    _droneNickname = "test";
    _faaRegistrationNumber = "FAXXXXXXXX";
    _horizontalLOSBound = 10;
    _verticalLOSBound = 10;
    _secondsToMissionStart = 60;
    _lidarAvailable = false;
}

FourDRequestItems::FourDRequestItems(QObject* parent, QString droneNickname, QString faaRegistrationNumber, int horizontalLOSBound, int verticalLOSBound, int secondsToMissionStart, bool lidarAvailable) : QObject(parent)
{
    _droneNickname = droneNickname;
    _faaRegistrationNumber = faaRegistrationNumber;
    _horizontalLOSBound = horizontalLOSBound;
    _verticalLOSBound = verticalLOSBound;
    _secondsToMissionStart = secondsToMissionStart;
    _lidarAvailable = lidarAvailable;
    
}

FourDRequestItems::FourDRequestItems(const QVariantMap& map, QObject* parent)
    : QObject(parent)
{
    _droneNickname = map.value("droneNickname").toString();
    _faaRegistrationNumber = map.value("faaRegistrationNumber").toString();
    _horizontalLOSBound = map.value("horizontalLOSBound").toInt();
    _verticalLOSBound = map.value("verticalLOSBound").toInt();
    _secondsToMissionStart = map.value("secondsToMissionStart").toInt();
    _lidarAvailable = map.value("lidarAvailable").toBool();
}

FourDRequestItems::~FourDRequestItems()
{
}

QString FourDRequestItems::toJson()
{
    QString customerID = SettingsManager::instance()->fourDSettings()->customerID()->rawValue().toString();

    QString jsonString = "\"droneNickname\": \"" + _droneNickname + "\"" +
                         ", \"faaRegistrationNumber\": \"" + _faaRegistrationNumber + "\"" +
                         ", \"horizontalLOSBound\": " + QString::number(_horizontalLOSBound) +
                         ", \"verticalLOSBound\": " + QString::number(_verticalLOSBound) +
                         ", \"secondsToMissionStart\": " + QString::number(_secondsToMissionStart) +
                         ", \"lidarAvailable\": " + (_lidarAvailable ? "true" : "false") +
                         ", \"customerId\": \"" + customerID + "\"";

    return jsonString;
}