#pragma once

#include <QObject>
#include <QJsonDocument>
#include <QString>
#include "FourDRequestItems.h"

class FourDRequestBody : public QObject
{
    Q_OBJECT

public:
    explicit FourDRequestBody(QObject* parent,
                              FourDRequestItems* requestItems,
                              QJsonDocument params,
                              QJsonDocument missionItems);
    ~FourDRequestBody();

    QString toJson();

private:
    FourDRequestItems* _requestItems = nullptr;
    QJsonDocument _params;
    QJsonDocument _missionItems;
};