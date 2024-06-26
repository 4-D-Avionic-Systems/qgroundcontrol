#pragma once

#include "QGCLoggingCategory.h"

#include <QNetworkAccessManager>
#include <QObject>

Q_DECLARE_LOGGING_CATEGORY(FourDUtilitiesLog)

class FourDUtilities : public QObject
{
    Q_OBJECT

public:
    FourDUtilities(QObject* parent = nullptr);
    ~FourDUtilities();

    void setUrl(QString);
    void postNewPath(QJsonDocument);
    void postParams(QJsonDocument);
    void get4DWayPoints(void);
    void getChangeStatus(void);

private:
    void callback4DWayPoints(void);

    QUrl api_url;
    QNetworkReply* reply;
    QNetworkAccessManager api_manager;

    bool api_request_complete = false;

};