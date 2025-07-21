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
    color:              qgcPal.fourDBlue

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
        if(droneNickname.text.lenght > 50){
            showMessageDialog(qsTr("Error"),
                    qsTr("Drone Nickname must be 50 characters or less."),
                    Dialog.Ok);
            return;
        }
        if (faaRegistrationNumber.text.length != 10){
            showMessageDialog(qsTr("Error"),
                    qsTr("FAA Registration Number must be 10 characters long."),
                    Dialog.Ok);
            return;
        }
        
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
        color:              qgcPal.fourDBlue
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
                        text: "drone1"
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
                        text: "FAXXXXXXXX"
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
                        text: "60"
                        validator: IntValidator {
                            bottom: 0
                            top: 9999
                            //I wanted this to be 3600, but the validator really only works to number of digits
                            //not the number given, so I set it to 9999 to avoid confusion.
                        }
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