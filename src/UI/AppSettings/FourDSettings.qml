import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

import QGroundControl
import QGroundControl.FactSystem
import QGroundControl.FactControls
import QGroundControl.Controls
import QGroundControl.ScreenTools
import QGroundControl.MultiVehicleManager
import QGroundControl.Palette
import QGroundControl.Controllers

SettingsPage {
    property var    _settingsManager:                      QGroundControl.settingsManager
    property var    _fourDSettings:                        _settingsManager.fourDSettings
    property Fact   _customerID:                           _fourDSettings.customerID
    SettingsGroupLayout {
        Layout.fillWidth:   true
        heading:            qsTr("General")

        LabelledFactTextField {
            Layout.fillWidth:   true
            label:              qsTr("Customer ID")
            fact:               _customerID
            visible:            true
            property Fact _customerID: _settingsManager.fourDSettings.customerID
        }
    }
}