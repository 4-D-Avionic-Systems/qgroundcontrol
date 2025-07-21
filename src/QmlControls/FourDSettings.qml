import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.ScreenTools
import QGroundControl.Vehicle
import QGroundControl.Controls
import QGroundControl.FactControls
import QGroundControl.Palette
import QGroundControl.SettingsManager
import QGroundControl.Controllers

// Editor for Mission Settings
Rectangle {
    id:                 valuesRect
    width:              availableWidth
    height:             valuesColumn.height + (_margin * 2)
    color:              qgcPal.windowShadeDark
    visible:            missionItem.isCurrentItem
    radius:             _radius

    property var    _masterControler:               masterController
    property var    _missionController:             _masterControler.missionController
    property var    _controllerVehicle:             _masterControler.controllerVehicle
    property bool   _vehicleHasHomePosition:        _controllerVehicle.homePosition.isValid
    property bool   _showCruiseSpeed:               !_controllerVehicle.multiRotor
    property bool   _showHoverSpeed:                _controllerVehicle.multiRotor || _controllerVehicle.vtol
    property bool   _multipleFirmware:              !QGroundControl.singleFirmwareSupport
    property bool   _multipleVehicleTypes:          !QGroundControl.singleVehicleSupport
    property real   _fieldWidth:                    ScreenTools.defaultFontPixelWidth * 16
    property bool   _mobile:                        ScreenTools.isMobile
    property var    _savePath:                      QGroundControl.settingsManager.appSettings.missionSavePath
    property var    _fileExtension:                 QGroundControl.settingsManager.appSettings.missionFileExtension
    property var    _appSettings:                   QGroundControl.settingsManager.appSettings
    property bool   _waypointsOnlyMode:             QGroundControl.corePlugin.options.missionWaypointsOnly
    property bool   _showCameraSection:             (_waypointsOnlyMode || QGroundControl.corePlugin.showAdvancedUI) && !_controllerVehicle.apmFirmware
    property bool   _simpleMissionStart:            QGroundControl.corePlugin.options.showSimpleMissionStart
    property bool   _showFlightSpeed:               !_controllerVehicle.vtol && !_simpleMissionStart && !_controllerVehicle.apmFirmware
    property bool   _allowFWVehicleTypeSelection:   _noMissionItemsAdded && !globals.activeVehicle

    readonly property string _firmwareLabel:    qsTr("Firmware")
    readonly property string _vehicleLabel:     qsTr("Vehicle")
    readonly property real  _margin:            ScreenTools.defaultFontPixelWidth / 2

    QGCPalette { id: qgcPal }
    QGCFileDialogController { id: fileController }
    Component { id: altModeDialogComponent; AltModeDialog { } }

    Connections {
        target: _controllerVehicle
        function onSupportsTerrainFrameChanged() {
            if (!_controllerVehicle.supportsTerrainFrame && _missionController.globalAltitudeMode === QGroundControl.AltitudeModeTerrainFrame) {
                _missionController.globalAltitudeMode = QGroundControl.AltitudeModeCalcAboveTerrain
            }
        }
    }

    ColumnLayout {
        id:                 valuesColumn
        anchors.margins:    _margin
        anchors.left:       parent.left
        anchors.right:      parent.right
        anchors.top:        parent.top
        spacing:            _margin
        }

        QGCLabel {
            text:           qsTr("Drone Nickname")
            font.pointSize: ScreenTools.smallFontPointSize
        }
        FactTextField {
            Layout.fillWidth:   true
        }

        QGCLabel {
            text:           qsTr("Faa Registration Number")
            font.pointSize: ScreenTools.smallFontPointSize
        }
        FactTextField {
            Layout.fillWidth:   true
        }

        QGCLabel {
            text:           qsTr("UTC Start Time")
            font.pointSize: ScreenTools.smallFontPointSize
        }
        FactTextField {
            Layout.fillWidth:   true
        }

QGCLabel {
    text: qsTr("Start Date and Time")
    font.pointSize: ScreenTools.smallFontPointSize
}

function updateDayModel() {
    var month = monthCombo.currentIndex
    var year = 2024
    var daysInMonth = 31

    if (month === 1) { // February
        daysInMonth = ((year % 4 === 0 && year % 100 !== 0) || (year % 400 === 0)) ? 29 : 28
    } else if ([3, 5, 8, 10].includes(month)) { // April, June, September, November
        daysInMonth = 30
    }

    let currentDay = dayCombo.currentIndex + 1
    dayCombo.model = Array.from({ length: daysInMonth }, (_, i) => i + 1)

    if (currentDay <= daysInMonth) {
        dayCombo.currentIndex = currentDay - 1
    } else {
        dayCombo.currentIndex = daysInMonth - 1
    }
}

RowLayout {
    Layout.fillWidth: true

    ComboBox {
        id: monthCombo
        model: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        currentIndex: 0
        onCurrentIndexChanged: updateDayModel()
    }

    ComboBox {
        id: dayCombo
        model: 31
        currentIndex : 1
        delegate: ItemDelegate {
            text: index
            width: parent.width
        }
    }

    Component.onCompleted: updateDayModel()
} // RowLayout


QGCLabel {
    text: qsTr("Hour:Minute")
    font.pointSize: ScreenTools.smallFontPointSize
}

RowLayout {
    Layout.fillWidth: true

    ComboBox {
        id: hourCombo
        model: 24
        currentIndex: 0
        delegate: ItemDelegate {
            text: index
            width: parent.width
        }
    }

    QGCLabel {
        text: qsTr(":")
        font.pointSize: ScreenTools.smallFontPointSize
    }

    ComboBox {
        id: minuteCombo
        model: 60
        currentIndex: 0
        delegate: ItemDelegate {
            text: index
            width: parent.width
        }
    }
} // RowLayout

        QGCCheckBox {
                id:         lidarAvailableBox
                text:       qsTr("Lidar Available?")
        }

        

} // Rectangle
