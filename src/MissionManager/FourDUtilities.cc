#include "FourDUtilities.h"
#include "FourDRequestBody.h"
#include "FourDRequestItems.h"
#include "QGCApplication.h"
#include "SettingsManager.h"
#include "FourDSettings.h"
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

    _apiUrl = QUrl("http://127.0.0.1:5248");
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

QNetworkReply*  FourDUtilities::detectConflicts(FourDRequestBody* jsonRequest)
{
    QUrl post_url = _apiUrl.resolved(QUrl("/PX4MultiRotor"));
    QNetworkRequest request(post_url);

    request.setRawHeader("Content-Type", "application/json");

    _reply = _apiManager.post(request, jsonRequest->toJson().toUtf8());

    // Wait for the request to finish
    QEventLoop loop;
    QObject::connect(_reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    loop.exec();
    return _reply;
}

QNetworkReply*  FourDUtilities::debugDetectConflicts(FourDRequestBody* jsonRequest)
{
    QUrl post_url = _apiUrl.resolved(QUrl("/PX4MultiRotor/Debug"));
    QNetworkRequest request(post_url);
    
    request.setRawHeader("Content-Type", "application/json");

    _reply = _apiManager.post(request, jsonRequest->toJson().toUtf8());

    // Wait for the request to finish
    QEventLoop loop;
    QObject::connect(_reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    loop.exec();
    return _reply;
}

QNetworkReply* FourDUtilities::detectConflictsAllGeoFences(FourDRequestBody* jsonRequest)
{
    QUrl post_url = _apiUrl.resolved(QUrl("/PX4MultiRotor/DeconflictGeoFences"));
    QNetworkRequest request(post_url);

    request.setRawHeader("Content-Type", "application/json");

    _reply = _apiManager.post(request, jsonRequest->toJson().toUtf8());

    // Wait for the request to finish
    QEventLoop loop;
    QObject::connect(_reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    loop.exec();
    return _reply;
}

QNetworkReply* FourDUtilities::detectConflictSingleGeoFenceCircle(FourDRequestBody* jsonRequest, int fenceIndex)
{
    QUrl post_url = _apiUrl.resolved(QUrl("/PX4MultiRotor/DeconflictGeoFenceCircle/" + QString::number(fenceIndex)));
    QNetworkRequest request(post_url);

    request.setRawHeader("Content-Type", "application/json");

    _reply = _apiManager.post(request, jsonRequest->toJson().toUtf8());

    // Wait for the request to finish
    QEventLoop loop;
    QObject::connect(_reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    loop.exec();
    return _reply;
}

QNetworkReply* FourDUtilities::detectConflictSingleGeoFencePolygon(FourDRequestBody* jsonRequest, int fenceIndex)
{
    QUrl post_url = _apiUrl.resolved(QUrl("/PX4MultiRotor/DeconflictGeoFencePolygon/" + QString::number(fenceIndex)));
    QNetworkRequest request(post_url);

    request.setRawHeader("Content-Type", "application/json");

    _reply = _apiManager.post(request, jsonRequest->toJson().toUtf8());

    // Wait for the request to finish
    QEventLoop loop;
    QObject::connect(_reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    loop.exec();
    return _reply;
}

QNetworkReply* FourDUtilities::overwriteGeoFences(QJsonDocument geoFences){
    QUrl post_url = _apiUrl.resolved(QUrl("/GeoFence/Overwrite"));
    QNetworkRequest request(post_url);
    request.setRawHeader("Content-Type", "application/json");
    _reply = _apiManager.put(request, geoFences.toJson());
    return _reply;
}

QNetworkReply* FourDUtilities::addGeoFences(QJsonDocument geoFences){
    // Get customer ID from settings and add it to the geofence JSON
    QString customerID = SettingsManager::instance()->fourDSettings()->customerID()->rawValue().toString();
    
    // Parse existing geofence JSON and add customer ID
    QJsonObject geoFenceObj = geoFences.object();
    geoFenceObj["customerId"] = customerID;
    QJsonDocument geoFencesWithCustomerId(geoFenceObj);
    
    QUrl post_url = _apiUrl.resolved(QUrl("/GeoFence/Add"));
    QNetworkRequest request(post_url);
    request.setRawHeader("Content-Type", "application/json");
    _reply = _apiManager.post(request, geoFencesWithCustomerId.toJson());
    return _reply;
}

QNetworkReply* FourDUtilities::addDebugGeoFences(QJsonDocument geoFences){
    // Get customer ID from settings and add it to the geofence JSON
    QString customerID = SettingsManager::instance()->fourDSettings()->customerID()->rawValue().toString();
    
    // Parse existing geofence JSON and add customer ID
    QJsonObject geoFenceObj = geoFences.object();
    geoFenceObj["customerId"] = customerID;
    QJsonDocument geoFencesWithCustomerId(geoFenceObj);
    
    QUrl post_url = _apiUrl.resolved(QUrl("/GeoFence/AddDebug"));
    QNetworkRequest request(post_url);
    request.setRawHeader("Content-Type", "application/json");
    _reply = _apiManager.post(request, geoFencesWithCustomerId.toJson());
    
    // Wait for the request to finish synchronously (like debugDetectConflicts)
    QEventLoop loop;
    QObject::connect(_reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    loop.exec();
    
    return _reply;
}

QJsonDocument FourDUtilities::loadGeoFences() {
    QUrl post_url = _apiUrl.resolved(QUrl("/GeoFence/Load"));
    QNetworkRequest request(post_url);
    request.setRawHeader("Content-Type", "application/json");

    QNetworkReply* reply = _apiManager.get(request);

    QEventLoop loop;
    connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    loop.exec();

    QByteArray responseData = reply->readAll();
    QJsonDocument results = parseJsonFromReply(reply, responseData);
    reply->deleteLater();

    return results;
}

QNetworkReply* FourDUtilities::deleteGeoFences(void){
    QUrl post_url = _apiUrl.resolved(QUrl("/GeoFence/Delete"));
    QNetworkRequest request(post_url);
    request.setRawHeader("Content-Type", "application/json");
    _reply = _apiManager.sendCustomRequest(request, "DELETE", "");
    return _reply;
}

QJsonDocument FourDUtilities::parseJsonFromReply(QNetworkReply* reply, const QByteArray& responseData)
{
    if (reply->error() != QNetworkReply::NoError) {
        qWarning() << "Network error:" << reply->errorString();
        return QJsonDocument();
    }

    QJsonParseError parseError;
    QJsonDocument jsonDoc = QJsonDocument::fromJson(responseData, &parseError);

    if (parseError.error != QJsonParseError::NoError) {
        qWarning() << "Failed to parse JSON:" << parseError.errorString();
        return QJsonDocument();
    }

    qCInfo(FourDUtilitiesLog) << jsonDoc.toJson();
    return jsonDoc;
}

QNetworkReply* FourDUtilities::changeSeed(int seedIndex)
{
    QUrl post_url = _apiUrl.resolved(QUrl("/FlightPathSeeds/Seed/" + QString::number(seedIndex)));
    QNetworkRequest request(post_url);
    request.setRawHeader("Content-Type", "application/json");
    _reply = _apiManager.put(request, QByteArray());
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

