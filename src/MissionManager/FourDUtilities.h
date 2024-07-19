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

    void postNewPath(void);
    void postParams(void);
    void postTelemData(void);
    void get4DWayPoints(void);
    void getChangeStatus(void);

private:
    void _commonInit(void);
    void _callback4DWayPoints(void);
    void _write4DWayPoints(void);

    QUrl _apiUrl;
    QNetworkReply* _reply;
    QNetworkAccessManager _apiManager;
    QTimer* _timer;

    QJsonDocument _vehicleParams;
    QJsonDocument _vehiclePlan;

    Vehicle* _vehicle;
    FactGroup*   _localPositionFactGroup;
    QGCToolbox* _toolbox;

    std::vector<std::vector<float>> _formatModel;

    int _messageNumber;
    int _numberOfMessages;
    int _numberOfWayPoints;

};