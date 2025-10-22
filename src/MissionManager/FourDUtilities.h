#pragma once

#include "FourDRequestBody.h"
#include "FourDRequestItems.h"
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
    FourDUtilities(QObject* parent = nullptr, Vehicle* managerVehicleRef = nullptr);
    ~FourDUtilities();
    QNetworkReply* detectConflicts(FourDRequestBody* jsonRequest);
    QNetworkReply* debugDetectConflicts(FourDRequestBody* jsonRequest);
    QNetworkReply* detectConflictsAllGeoFences(FourDRequestBody* jsonRequest);
    QNetworkReply* overwriteGeoFences(QJsonDocument geoFences);
    QNetworkReply* addGeoFences(QJsonDocument geoFences);
    QNetworkReply* detectConflictSingleGeoFenceCircle(FourDRequestBody* jsonRequest, int fenceIndex);
    QNetworkReply* detectConflictSingleGeoFencePolygon(FourDRequestBody* jsonRequest, int fenceIndex);
    QJsonDocument loadGeoFences(void);
    QNetworkReply* deleteGeoFences(void);
    QNetworkReply* changeSeed(int seedIndex);
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