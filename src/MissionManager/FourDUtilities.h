#pragma once

#include "QGCLoggingCategory.h"
#include "Vehicle.h"

#include <QNetworkAccessManager>
#include <QObject>
#include <QNetworkReply>
#include <vector>


Q_DECLARE_LOGGING_CATEGORY(FourDUtilitiesLog)
class FourDUtilities : public QObject
{
    Q_OBJECT

public:
    FourDUtilities(QObject* parent = nullptr, Vehicle* managerVehicleRef = nullptr, QString urlStr = "");
    ~FourDUtilities();
    QNetworkReply* detectConflicts(QString partialJSON, QJsonDocument planParams, QJsonDocument planJson);
    QNetworkReply* debugDetectConflicts(QString partialJSON, QJsonDocument planParams, QJsonDocument planJson);
    QNetworkReply* overwriteGeoFences(QJsonDocument geoFences);
    QNetworkReply* addGeoFences(QJsonDocument geoFences);
    QJsonDocument loadGeoFences(void);
    QNetworkReply* deleteGeoFences(void);
    QJsonDocument parseJsonFromReply(QNetworkReply* reply, const QByteArray& responseData);

    void postTelemData(void);

private:
    void _commonInit(void);

    QUrl _apiUrl;
    QNetworkReply* _reply;
    QNetworkAccessManager _apiManager;
    QTimer* _timer;

    Vehicle* _vehicle;
    FactGroup*   _localPositionFactGroup;
    // QGCToolbox* _toolbox;

    std::vector<std::vector<float>> _formatModel;

    int _messageNumber;
    int _numberOfMessages;
    int _numberOfWayPoints;

    QJsonDocument _vehicleParams;
    QJsonDocument _vehiclePlan;

};