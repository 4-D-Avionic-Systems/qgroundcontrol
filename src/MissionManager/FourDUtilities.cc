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
    _timer = new QTimer(this);
    qCInfo(FourDUtilitiesLog) << "FourDUtilities() - constructed";
}

FourDUtilities::~FourDUtilities()
{

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

void FourDUtilities::postParams(void)
{
    QUrl post_url = _apiUrl.resolved(QUrl("/params"));
    QNetworkRequest request(post_url);

    request.setRawHeader("Content-Type", "application/json");
    _reply = _apiManager.post(request, _vehicleParams.toJson());

    QObject::connect(_reply, &QNetworkReply::finished, this, &FourDUtilities::postNewPath);

    return;
}

void FourDUtilities::postNewPath(void)
{
    QUrl post_url = _apiUrl.resolved(QUrl("/flight"));
    QNetworkRequest request(post_url);

    request.setRawHeader("Content-Type", "application/json");
    _reply = _apiManager.post(request, _vehiclePlan.toJson());

    QObject::connect(_reply, &QNetworkReply::finished, this, &FourDUtilities::get4DWayPoints);

    return;
}

void FourDUtilities::get4DWayPoints(void)
{
    QUrl post_url = _apiUrl.resolved(QUrl("/convert"));
    QNetworkRequest request(post_url);

    request.setRawHeader("Content-Type", "application/json");
    _reply = _apiManager.get(request);

    QObject::connect(_reply, &QNetworkReply::finished, this, &FourDUtilities::_callback4DWayPoints);

    return;
}

void FourDUtilities::_callback4DWayPoints(void)
{
    QByteArray wptByteArray;
    QJsonDocument wptJsonDoc;
    QJsonParseError parseError;
    QJsonObject wptJsonObj;

    std::vector<float> valHold;

    wptByteArray = _reply->readAll();
    wptJsonDoc = QJsonDocument::fromJson(wptByteArray, &parseError);

    if (parseError.error != QJsonParseError::NoError)
    {
        qCWarning(FourDUtilitiesLog) << "Parse Error at " << parseError.offset << ":" << parseError.errorString();
    }

    wptJsonObj = wptJsonDoc.object();

    // qCInfo(FourDUtilitiesLog) << wptByteArray;
    qCInfo(FourDUtilitiesLog) << "keys = " << wptJsonObj.keys();

    QJsonArray wptTimes = wptJsonObj.value("time").toArray();

    QJsonArray wptPn = wptJsonObj.value("pn").toArray();
    QJsonArray wptPe = wptJsonObj.value("pe").toArray();
    QJsonArray wptPd = wptJsonObj.value("pd").toArray();

    QJsonArray wptVn = wptJsonObj.value("vn").toArray();
    QJsonArray wptVe = wptJsonObj.value("ve").toArray();
    QJsonArray wptVd = wptJsonObj.value("vd").toArray();

    QJsonArray wptAn = wptJsonObj.value("an").toArray();
    QJsonArray wptAe = wptJsonObj.value("ae").toArray();
    QJsonArray wptAd = wptJsonObj.value("ad").toArray();

    qCInfo(FourDUtilitiesLog) << "lengths = " << wptTimes.size() 
                                              << " " << wptPn.size() << " " << wptPe.size() << " " << wptPd.size()
                                              << " " << wptVn.size() << " " << wptVe.size() << " " << wptVd.size()
                                              << " " << wptAn.size() << " " << wptAe.size() << " " << wptAd.size();

    _formatModel.clear();
    for (int i = 0; i < wptTimes.size(); i++)
    {

        valHold.push_back(wptPn[i].toDouble()); 
        valHold.push_back(wptPe[i].toDouble()); 
        valHold.push_back(wptPd[i].toDouble()); 
        valHold.push_back(wptVn[i].toDouble()); 
        valHold.push_back(wptVe[i].toDouble()); 
        valHold.push_back(wptVd[i].toDouble()); 
        valHold.push_back(wptAn[i].toDouble()); 
        valHold.push_back(wptAe[i].toDouble()); 
        valHold.push_back(wptAd[i].toDouble()); 
        valHold.push_back(wptTimes[i].toDouble());

        _formatModel.push_back( valHold );

        valHold.clear();
    }

    _numberOfWayPoints = _formatModel.size();
    _messageNumber = 0;
    _numberOfMessages = std::ceil( ((float)_numberOfWayPoints) / 5.0);

    qCInfo(FourDUtilitiesLog) << "#wpts, #messages = " << _numberOfWayPoints << " " << _numberOfMessages;
    qCInfo(FourDUtilitiesLog) << "Send 4D WayPoints over MavLink";

    if (_numberOfMessages > 0)
    {
        QObject::connect(_timer, &QTimer::timeout, this, &FourDUtilities::_write4DWayPoints);
        _timer->start(100);
    }

    return;
}

void FourDUtilities::getChangeStatus(void)
{
    return;
}

void FourDUtilities::_write4DWayPoints(void)
{
    float flight_segment[50];

    WeakLinkInterfacePtr weakLink = _vehicle->vehicleLinkManager()->primaryLink();
    if (!weakLink.expired()) 
    {
        mavlink_message_t       message;
        SharedLinkInterfacePtr  sharedLink = weakLink.lock();

        qCInfo(FourDUtilitiesLog) << "\tsending message number " << _messageNumber << " of " << _numberOfMessages;

        for (int i = 0; i < 5; i++)
        {
            for (int j = 0; j < 10; j++)
            {
                if ( (_messageNumber * 5 + i) < _formatModel.size() )
                {
                    flight_segment[i*10 + j] = _formatModel[_messageNumber * 5 + i][j];
                }
                else
                {
                    flight_segment[i*10 + j] = 0.0;
                }
            }
        }

        mavlink_msg_four_d_model_pack_chan(qgcApp()->toolbox()->mavlinkProtocol()->getSystemId(),
                                            qgcApp()->toolbox()->mavlinkProtocol()->getComponentId(),
                                            sharedLink->mavlinkChannel(),
                                            &message,
                                            _vehicle->id(),
                                            _numberOfWayPoints,
                                            _messageNumber,
                                            flight_segment);

        _vehicle->sendMessageOnLinkThreadSafe(sharedLink.get(), message);

        _messageNumber++;

        if (_messageNumber >= _numberOfMessages)
        {
            _timer->stop();
        }
    }
}