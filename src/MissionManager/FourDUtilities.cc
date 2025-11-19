#include "FourDUtilities.h"
#include "FourDRequestBody.h"
#include "FourDRequestItems.h"
#include "QGCApplication.h"
#include "SettingsManager.h"
#include "FourDSettings.h"
#include "PlanMasterController.h"
#include "QGCCorePlugin.h"
#include <QUrlQuery>


QGC_LOGGING_CATEGORY(FourDUtilitiesLog, "FourDUtilitiesLog")

FourDUtilities::FourDUtilities(QObject* parent, Vehicle* managerVehicleRef)
    : QObject(parent)
    , _deleteReply(nullptr)
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

QVariant FourDUtilities::_getCustomerID(void)
{
    QString customerIDString = SettingsManager::instance()->fourDSettings()->customerID()->rawValue().toString();
    bool conversionOk;
    int customerID = customerIDString.toInt(&conversionOk);
    
    if (conversionOk) {
        return QVariant(customerID);
    } else {
        return QVariant(customerIDString);
    }
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
    QJsonObject geoFenceObj = geoFences.object();
    geoFenceObj["customerId"] = QJsonValue::fromVariant(_getCustomerID());
    QJsonDocument geoFencesWithCustomerId(geoFenceObj);
    
    QUrl post_url = _apiUrl.resolved(QUrl("/GeoFence/Overwrite"));
    QNetworkRequest request(post_url);
    request.setRawHeader("Content-Type", "application/json");
    _reply = _apiManager.put(request, geoFencesWithCustomerId.toJson());
    return _reply;
}

QNetworkReply* FourDUtilities::addGeoFences(QJsonDocument geoFences){
    QJsonObject geoFenceObj = geoFences.object();
    geoFenceObj["customerId"] = QJsonValue::fromVariant(_getCustomerID());
    QJsonDocument geoFencesWithCustomerId(geoFenceObj);
    
    QUrl post_url = _apiUrl.resolved(QUrl("/GeoFence/Add"));
    QNetworkRequest request(post_url);
    request.setRawHeader("Content-Type", "application/json");
    _reply = _apiManager.post(request, geoFencesWithCustomerId.toJson());
    return _reply;
}

QJsonDocument FourDUtilities::loadGeoFences() {
    QString endpoint = QString("/GeoFence/Load/%1").arg(_getCustomerID().toString());
    
    QUrl post_url = _apiUrl.resolved(QUrl(endpoint));
    
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

bool FourDUtilities::deleteGeoFences(void){
    QString endpoint = QString("/GeoFence/Delete/%1").arg(_getCustomerID().toString());
    
    QUrl delete_url = _apiUrl.resolved(QUrl(endpoint));
    
    QNetworkRequest request(delete_url);
    request.setRawHeader("Content-Type", "application/json");
    
    _deleteReply = _apiManager.sendCustomRequest(request, "DELETE", QByteArray());
    connect(_deleteReply, &QNetworkReply::finished, this, &FourDUtilities::_handleDeleteGeoFencesFinished);
    
    return true; // Request initiated successfully
}

void FourDUtilities::_handleDeleteGeoFencesFinished(void)
{
    if (!_deleteReply) {
        return;
    }
    
    int statusCode = _deleteReply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    bool hasNetworkError = (_deleteReply->error() != QNetworkReply::NoError);    
    bool success = (statusCode == 200 || statusCode == 204 || statusCode == 202) && !hasNetworkError;
    
    _deleteReply->deleteLater();
    _deleteReply = nullptr;
    
    emit deleteGeoFencesCompleted(success);
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

