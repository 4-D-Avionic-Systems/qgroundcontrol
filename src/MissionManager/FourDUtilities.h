#pragma once

#include "QGCLoggingCategory.h"

#include <QNetworkAccessManager>

Q_DECLARE_LOGGING_CATEGORY(FourDUtilitiesLog)

class FourDUtilities
{
public:
    FourDUtilities(void);
    ~FourDUtilities();

    void setUrl(QString);
    void postNewPath(QJsonDocument);
    void putNewMItems(void);
    void get4DWayPoints(void);
    void getChangeStatus(void);

private:
    QUrl api_url;
    QNetworkAccessManager api_manager;

};