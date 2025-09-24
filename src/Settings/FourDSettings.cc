/****************************************************************************
 *
 * (c) 2009-2024 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#include "FourDSettings.h"

#include <QtQml/QQmlEngine>

DECLARE_SETTINGGROUP(FourD, "FourD")
{
    qmlRegisterUncreatableType<FourDSettings>("QGroundControl.SettingsManager", 1, 0, "FourDSettings", "Reference only"); \
}

DECLARE_SETTINGSFACT(FourDSettings, customerID)
