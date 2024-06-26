#include "FourDUtilities.h"
#include "QGCApplication.h"
#include "SettingsManager.h"
#include "PlanMasterController.h"
#include "QGCCorePlugin.h"

#include <QNetworkReply>

QGC_LOGGING_CATEGORY(FourDUtilitiesLog, "FourDUtilitiesLog")

FourDUtilities::FourDUtilities(QObject* parent)
    : QObject(parent)
{
    qCInfo(FourDUtilitiesLog) << "FourDUtilities() - constructed";
}

FourDUtilities::~FourDUtilities()
{

}

void FourDUtilities::setUrl(QString set_url)
{
    api_url = QUrl(set_url);
    qCInfo(FourDUtilitiesLog) << "setURL() - " << api_url;
    return;
}

void FourDUtilities::postNewPath(QJsonDocument planJson)
{
    QUrl post_url = api_url.resolved(QUrl("/flight"));
    QNetworkRequest request(post_url);

    request.setRawHeader("Content-Type", "application/json");
    api_manager.post(request, planJson.toJson());

    return;
}

void FourDUtilities::postParams(QJsonDocument planParams)
{
    QUrl post_url = api_url.resolved(QUrl("/params"));
    QNetworkRequest request(post_url);

    request.setRawHeader("Content-Type", "application/json");
    api_manager.post(request, planParams.toJson());

    return;
}

void FourDUtilities::get4DWayPoints(void)
{
    QUrl post_url = api_url.resolved(QUrl("/convert"));
    QNetworkRequest request(post_url);

    request.setRawHeader("Content-Type", "application/json");
    reply = api_manager.get(request);

    QObject::connect(reply, &QNetworkReply::finished, this, &FourDUtilities::callback4DWayPoints);

    return;
}

void FourDUtilities::callback4DWayPoints(void)
{
    qCInfo(FourDUtilitiesLog) << reply->readAll();

    return;
}

void FourDUtilities::getChangeStatus(void)
{
    return;
}