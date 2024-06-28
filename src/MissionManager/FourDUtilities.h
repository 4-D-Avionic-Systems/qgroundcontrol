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
    FourDUtilities(QObject* parent = nullptr, Vehicle* _vehicle = nullptr);
    ~FourDUtilities();

    void setUrl(QString);
    void postNewPath(QJsonDocument);
    void postParams(QJsonDocument);
    void get4DWayPoints(void);
    void getChangeStatus(void);

private:
    void _callback4DWayPoints(void);
    void _write4DWayPoints(void);

    QUrl _apiUrl;
    QNetworkReply* _reply;
    QNetworkAccessManager _apiManager;

    Vehicle* _vehicle;

    std::vector<std::vector<float>> _formatModel;

};