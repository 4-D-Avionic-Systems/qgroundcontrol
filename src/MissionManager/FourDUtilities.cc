#include "FourDUtilities.h"
#include "QGCApplication.h"
#include "SettingsManager.h"
#include "PlanMasterController.h"
#include "QGCCorePlugin.h"

#include <QNetworkReply>

QGC_LOGGING_CATEGORY(FourDUtilitiesLog, "FourDUtilitiesLog")

FourDUtilities::FourDUtilities(void)
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

void FourDUtilities::putNewMItems(void)
{
    return;
}

void FourDUtilities::get4DWayPoints(void)
{
    return;
}

void FourDUtilities::getChangeStatus(void)
{
    return;
}