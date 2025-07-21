import QtQuick
import QtQuick.Controls
import QtPositioning

import QGroundControl
import QGroundControl.ScreenTools
import QGroundControl.Vehicle
import QGroundControl.Controls
import QGroundControl.FactSystem
import QGroundControl.FactControls
import QGroundControl.Palette
import QGroundControl.SettingsManager
import QGroundControl.Controllers


Rectangle {
    id:                 root
    height:             valuesRect.height
    clip:               true
    color:              "#007dbc"

    property real _margin: ScreenTools.defaultFontPixelWidth / 2
    property real _radius : ScreenTools.defaultFontPixelWidth / 2

    property var    planMasterController

    function detectConflicts(){
        let additionalDataObject = {
            "droneNickname": droneNickname.text,
            "faaRegistrationNumber": faaRegistrationNumber.text,
            "secondsToMissionStart": parseInt(secondsToMissionStart.text, 10),
            "lidarAvailable": lidarAvailableBox.checked,
            "customerId": 1
        };

        for (let key in additionalDataObject) {
            let value = additionalDataObject[key];
            if (typeof value === 'string' && value.trim() === '') {
                delete additionalDataObject[key];
            } else if (typeof value === 'number' && isNaN(value)) {
                delete additionalDataObject[key];
            } else if (value === null) {
                delete additionalDataObject[key];
            }
        }

        let partialJSONToSend = JSON.stringify(additionalDataObject);
        partialJSONToSend = partialJSONToSend.replace("{", "").replace("}", "");

        let msg = planMasterController.detectConflicts(partialJSONToSend);

        if(msg !== ""){
            showMessageDialog(qsTr("Error"),
                    msg,
                    Dialog.Ok);
        }

    }

    function addGeoFences() {
        showMessageDialog(qsTr("Warning"),
                        qsTr("Warning: GeoFences only work with exclusion zones and circles at this point"),
                        Dialog.Ok,
                        function() {planMasterController.addGeoFences()})
    }

    function overwriteGeoFences() {
        showMessageDialog(qsTr("Warning"),
                        qsTr("Warning: GeoFences only work with exclusion zones and circles at this point"),
                        Dialog.Ok,
                        function() {
                            showMessageDialog(qsTr("Are You Sure?"),
                                                qsTr("Are you sure? This will delete all the saved GeoFences in the database."),
                                                Dialog.Yes | Dialog.No,
                                                function() {
                                                    planMasterController.overwriteGeoFences()

                                                })
                        })
    }

    function loadGeoFences() {
    showMessageDialog(qsTr("Would you like to clear existing circles?"),
                        qsTr("Click Yes to clear the existing circles before loading. \nClick No to add the loaded circles to the existing circles."),
                        Dialog.Yes | Dialog.No,
                    function () {
                        planMasterController.loadGeoFences(true)
                    })
    }

    function deleteGeoFences() {
    showMessageDialog(qsTr("Are you Sure?)"),
                        qsTr("This will delete all existing circles"),
                        Dialog.Yes | Dialog.No,
                    function () {
                        planMasterController.deleteGeoFences()
                    })
    }

    function undoResolution() {
        planMasterController.undoResolution()
    }


    Rectangle {
        id:                 valuesRect
        anchors.left:   parent.left
        anchors.right:  parent.right
        height:             fourDLabel.height + fourDControlItems.height + (_margin * 3)
        color:              "#007dbc"
        radius:             _radius

        QGCLabel {
            id:                 fourDLabel
            anchors.margins:    _margin
            anchors.left:       parent.left
            anchors.top:        parent.top
            text:               qsTr("4D Avionic Systems Tools")
            anchors.leftMargin: ScreenTools.defaultFontPixelWidth
        }

        Rectangle {
            id: fourDControlItems
            anchors.margins:    _margin
            anchors.left:       parent.left
            anchors.right:      parent.right
            anchors.top:        fourDLabel.bottom
            color:              qgcPal.windowShadeDark
            radius:             _radius
            height:             mainContentColumn.height + (_margin * 2)

            Column {
                id:                 mainContentColumn
                anchors.margins:    _margin
                anchors.top:        parent.top
                anchors.left:       parent.left
                anchors.right:      parent.right
                spacing:            _margin

                SectionHeader {
                    id:                 droneDetailsSection
                    anchors.left:       parent.left
                    anchors.right:      parent.right
                    text:               qsTr("Flight Plan Details")
                    checked:            true
                }

                Column {
                    id:                 droneDetailsContent
                    anchors.left:       parent.left
                    anchors.right:      parent.right
                    spacing:            _margin
                    visible:            droneDetailsSection.checked
                    height:             visible ? implicitHeight : 0

                    QGCLabel {
                        text:           qsTr("Drone Nickname")
                        font.pointSize: ScreenTools.smallFontPointSize
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                    }
                    FactTextField {
                        id: droneNickname
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                    }

                    QGCLabel {
                        text:           qsTr("Faa Registration Number")
                        font.pointSize: ScreenTools.smallFontPointSize
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                    }
                    FactTextField {
                        id: faaRegistrationNumber
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                    }

                    QGCLabel {
                        text: qsTr("Time From Now to Start Mission (Seconds)")
                        font.pointSize: ScreenTools.smallFontPointSize
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                    }

                    FactTextField {
                        id: secondsToMissionStart
                        anchors.left: parent.left
                        anchors.right: parent.right
                    }
                    QGCCheckBox {
                        id:         lidarAvailableBox
                        text:       qsTr("Lidar Available?")
                        anchors.left: parent.left
                    }
                }

                SectionHeader {
                    id:                 conflictResolutionSection
                    anchors.left:       parent.left
                    anchors.right:      parent.right
                    text:               qsTr("Conflict Resolution")
                    checked:            true
                }

                Column {
                    id:                 conflictResolutionContent
                    anchors.left:       parent.left
                    anchors.right:      parent.right
                    spacing:            _margin
                    visible:            conflictResolutionSection.checked
                    height:             visible ? implicitHeight : 0

                    QGCButton {
                        id:          detectConflictButton
                        text:        qsTr("Detect & Resolve Conflicts")
                        enabled:     true
                        onClicked:   root.detectConflicts()
                        width:       conflictResolutionSection.width
                    }

                    QGCButton {
                        id:          undoResolutionButton
                        text:        qsTr("Undo Resolution")
                        enabled:     true
                        onClicked:   root.undoResolution()
                        width: detectConflictButton.width
                    }
                }

                SectionHeader {
                    id:                 geoFenceManagementSection
                    anchors.left:       parent.left
                    anchors.right:      parent.right
                    text:               qsTr("GeoFence Management")
                    checked:            false
                }

                Column {
                    id:                 geoFenceManagementContent
                    anchors.left:       parent.left
                    anchors.right:      parent.right
                    spacing:            _margin
                    visible:            geoFenceManagementSection.checked
                    height:             visible ? implicitHeight : 0

                    QGCButton {
                        id:          addGeoFenceButton
                        text:        qsTr("Add GeoFences")
                        enabled:     true
                        onClicked:   root.addGeoFences()
                        width: detectConflictButton.width
                    }

                    QGCButton {
                        id:          overwriteGeoFenceButton
                        text:        qsTr("Overwrite GeoFences")
                        enabled:     true
                        onClicked:   root.overwriteGeoFences()
                        width: detectConflictButton.width
                    }

                    QGCButton {
                        id:          loadGeoFenceButton
                        text:        qsTr("Load GeoFences")
                        enabled:     true
                        onClicked:   root.loadGeoFences()
                        width: detectConflictButton.width
                    }

                    QGCButton {
                        id:          deleteGeoFenceButton
                        text:        qsTr("Clear GeoFence DB")
                        enabled:     true
                        onClicked:   root.deleteGeoFences()
                        width: detectConflictButton.width
                    }
                }

            }
        }
    }
}