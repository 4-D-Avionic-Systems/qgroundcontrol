#include "FourDUtilities.h"
#include "QGCApplication.h"
#include "SettingsManager.h"
#include "PlanMasterController.h"
#include "QGCCorePlugin.h"



QGC_LOGGING_CATEGORY(FourDUtilitiesLog, "FourDUtilitiesLog")

FourDUtilities::FourDUtilities(QObject* parent, Vehicle* managerVehicleRef)
    : QObject(parent)
{
    _vehicle = managerVehicleRef;
    _localPositionFactGroup = _vehicle->localPositionFactGroup();
    _timer = new QTimer(this);
    // _toolbox = toolboxRef;

    _commonInit();

    qCInfo(FourDUtilitiesLog) << "FourDUtilities() - constructed";
}

FourDUtilities::~FourDUtilities()
{
}

void FourDUtilities::_commonInit(void)
{
    connect(_vehicle, &Vehicle::coordinateChanged, this, &FourDUtilities::postTelemData);
}

void FourDUtilities::setUrl(QString set_url)
{
    _apiUrl = QUrl(set_url);
    qCInfo(FourDUtilitiesLog) << "setURL() - " << _apiUrl;
    return;
}

void FourDUtilities::setParams(QJsonDocument planParams)
{
    _vehicleParams = planParams;
}

void FourDUtilities::setPlan(QJsonDocument planJson)
{
    _vehiclePlan = planJson;
}

QNetworkReply* FourDUtilities::postParams(void)
{
    QUrl post_url = _apiUrl.resolved(QUrl("/params"));
    QNetworkRequest request(post_url);

    request.setRawHeader("Content-Type", "application/json");
    _reply = _apiManager.post(request, _vehicleParams.toJson());

    // QObject::connect(_reply, &QNetworkReply::finished, this, &FourDUtilities::postNewPath);

    qCInfo(FourDUtilitiesLog) << "postParams";

    return _reply;
}

QNetworkReply* FourDUtilities::postNewPath(void)
{
    QUrl post_url = _apiUrl.resolved(QUrl("/flight"));
    QNetworkRequest request(post_url);

    request.setRawHeader("Content-Type", "application/json");
    _reply = _apiManager.post(request, _vehiclePlan.toJson());

    // QObject::connect(_reply, &QNetworkReply::finished, this, &FourDUtilities::get4DWayPoints);

    qCInfo(FourDUtilitiesLog) << "postNewPath"; 

    return _reply;
}

QNetworkReply* FourDUtilities::get4DWayPoints(void)
{
    QUrl post_url = _apiUrl.resolved(QUrl("/convert"));
    QNetworkRequest request(post_url);

    request.setRawHeader("Content-Type", "application/json");
    _reply = _apiManager.get(request);

    // QObject::connect(_reply, &QNetworkReply::finished, this, &FourDUtilities::_callback4DWayPoints);

    qCInfo(FourDUtilitiesLog) << "get4DWayPoints"; 

    return _reply;
}

QJsonObject FourDUtilities::getWptJsonObj(void)
{
    QByteArray wptByteArray;
    QJsonDocument wptJsonDoc;
    QJsonParseError parseError;

    std::vector<float> valHold;

    wptByteArray = _reply->readAll();
    wptJsonDoc = QJsonDocument::fromJson(wptByteArray, &parseError);

    if (parseError.error != QJsonParseError::NoError)
    {
        qCWarning(FourDUtilitiesLog) << "Parse Error at " << parseError.offset << ":" << parseError.errorString();
    }

    _wptJsonObj = wptJsonDoc.object();

    // qCInfo(FourDUtilitiesLog) << wptByteArray;
    // qCInfo(FourDUtilitiesLog) << "keys = " << _wptJsonObj.isEmpty();
    qCInfo(FourDUtilitiesLog) << "_callback4DWayPoints"; 

    return _wptJsonObj;
}

void FourDUtilities::postTelemData(void)
{
    if (_vehicle->armed())
    {
        QUrl post_url = _apiUrl.resolved(QUrl("/telem"));
        QNetworkRequest request(post_url);

        QJsonDocument telemDoc;
        QJsonArray    telemArray;

        telemArray.prepend(_localPositionFactGroup->getFact("vz")->rawValue().toDouble());
        telemArray.prepend(_localPositionFactGroup->getFact("vy")->rawValue().toDouble());
        telemArray.prepend(_localPositionFactGroup->getFact("vx")->rawValue().toDouble());
        telemArray.prepend(_localPositionFactGroup->getFact("z")->rawValue().toDouble());
        telemArray.prepend(_localPositionFactGroup->getFact("y")->rawValue().toDouble());
        telemArray.prepend(_localPositionFactGroup->getFact("x")->rawValue().toDouble());

        telemDoc.setArray(telemArray);

        request.setRawHeader("Content-Type", "application/json");
        _reply = _apiManager.post(request, telemDoc.toJson());
    }

    return;
}