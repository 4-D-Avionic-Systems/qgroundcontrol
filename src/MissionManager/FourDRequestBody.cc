#include "FourDRequestBody.h"

FourDRequestBody::FourDRequestBody(QObject* parent,
                                   FourDRequestItems* requestItems,
                                   QJsonDocument params,
                                   QJsonDocument missionItems)
    : QObject(parent)
    , _requestItems(requestItems)
    , _params(params)
    , _missionItems(missionItems)
{
}

FourDRequestBody::FourDRequestBody(QObject* parent,
                                   QJsonDocument params,
                                   QJsonDocument missionItems) 
                                   : QObject(parent)
{
    _requestItems = new FourDRequestItems(this);
    _params = params;
    _missionItems = missionItems;
}

FourDRequestBody::~FourDRequestBody()
{
    delete _requestItems;
    _requestItems = nullptr;
}

QString FourDRequestBody::toJson()
{
    QString jsonString = "{" + _requestItems->toJson() + ", \"params\": " + _params.toJson() + ", \"missionItems\": "  + _missionItems.toJson() + "}";
    return jsonString;
}