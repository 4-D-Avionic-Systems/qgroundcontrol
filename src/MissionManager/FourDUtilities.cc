#include "FourDUtilities.h"
#include "QGCApplication.h"
#include "SettingsManager.h"
#include "PlanMasterController.h"
#include "QGCCorePlugin.h"


QGC_LOGGING_CATEGORY(FourDUtilitiesLog, "FourDUtilitiesLog")

FourDUtilities::FourDUtilities(QObject* parent, Vehicle* managerVehicleRef, QString urlStr)
    : QObject(parent)
{
    _vehicle = managerVehicleRef;
    _localPositionFactGroup = _vehicle->localPositionFactGroup();
    _timer = new QTimer(this);
    // _toolbox = toolboxRef;

    _commonInit();

    _apiUrl = QUrl(urlStr);
    qCInfo(FourDUtilitiesLog) << "setURL() - " << _apiUrl;
    qCInfo(FourDUtilitiesLog) << "FourDUtilities() - constructed";

}

FourDUtilities::~FourDUtilities()
{
}

void FourDUtilities::_commonInit(void)
{
    connect(_vehicle, &Vehicle::coordinateChanged, this, &FourDUtilities::postTelemData);
}

QNetworkReply* FourDUtilities::detectConflicts(QJsonDocument planParams, QJsonDocument planJson)
{
    QUrl post_url = _apiUrl.resolved(QUrl("/PX4MultiRotor"));
    QNetworkRequest request(post_url);

     _vehicleParams = planParams;
     _vehiclePlan = planJson;
    request.setRawHeader("Content-Type", "application/json");
    _reply = _apiManager.post(request, "{\"{params\": " + _vehicleParams.toJson() + ", \"missionItems\": "  + _vehiclePlan.toJson() + "}");

    // QObject::connect(_reply, &QNetworkReply::finished, this, &FourDUtilities::postNewPath);

    qCInfo(FourDUtilitiesLog) << "Detect Conflicts";

    return _reply;
}

QNetworkReply* FourDUtilities::overwriteGeoFences(QJsonDocument geoFences){
    QUrl post_url = _apiUrl.resolved(QUrl("/GeoFence/Overwrite"));
    QNetworkRequest request(post_url);
    request.setRawHeader("Content-Type", "application/json");
    _reply = _apiManager.post(request, geoFences.toJson());
    return _reply;
}

void FourDUtilities::postTelemData(void)
{
    if (_vehicle->armed())
    {
        QUrl post_url = _apiUrl.resolved(QUrl("/telem"));
        QNetworkRequest request(post_url);

        QJsonObject param_object = _vehicleParams.object();

        QJsonDocument telemDoc;
        QJsonArray    telemArray;

        telemArray.prepend(_localPositionFactGroup->getFact("vz")->rawValue().toDouble());
        telemArray.prepend(_localPositionFactGroup->getFact("vy")->rawValue().toDouble());
        telemArray.prepend(_localPositionFactGroup->getFact("vx")->rawValue().toDouble());
        telemArray.prepend(_localPositionFactGroup->getFact("z")->rawValue().toDouble());
        telemArray.prepend(_localPositionFactGroup->getFact("y")->rawValue().toDouble());
        telemArray.prepend(_localPositionFactGroup->getFact("x")->rawValue().toDouble());
        telemArray.prepend(param_object["MAV_SYS_ID"]);

        telemDoc.setArray(telemArray);

        request.setRawHeader("Content-Type", "application/json");
        _reply = _apiManager.post(request, telemDoc.toJson());
    }

    return;
}

