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
    FourDUtilities(QObject* parent = nullptr, Vehicle* managerVehicleRef = nullptr, QGCToolbox* toolboxRef = nullptr);
    ~FourDUtilities();

    void setUrl(QString);
    void setParams(QJsonDocument planParams);
    void setPlan(QJsonDocument planJson);

    QNetworkReply* postParams(void);
    QNetworkReply* postNewPath(void);
    QNetworkReply* get4DWayPoints(void);
    QNetworkReply* getChangeStatus(void);
    QJsonObject getWptJsonObj(void);

    void postTelemData(void);

private:
    void _commonInit(void);

    QUrl _apiUrl;
    QNetworkReply* _reply;
    QNetworkAccessManager _apiManager;
    QTimer* _timer;

    QJsonDocument _vehicleParams;
    QJsonDocument _vehiclePlan;
    QJsonObject _wptJsonObj;

    Vehicle* _vehicle;
    FactGroup*   _localPositionFactGroup;
    QGCToolbox* _toolbox;

    std::vector<std::vector<float>> _formatModel;

    int _messageNumber;
    int _numberOfMessages;
    int _numberOfWayPoints;

};