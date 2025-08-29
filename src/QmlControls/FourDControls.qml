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


QGCFlickable {
    id:                 root
    contentHeight: mainContentColumn.height
    clip:               true

    property real _margin: ScreenTools.defaultFontPixelWidth / 2
    property real _radius : ScreenTools.defaultFontPixelWidth / 2

    property var    planMasterController

    function detectConflicts(){
        let additionalDataObject = {
            "droneNickname": droneNickname.text,
            "faaRegistrationNumber": faaRegistrationNumber.text,
            "horizontalLOSBound" : horizontalLOSBound.text,
            "verticalLOSBound" : verticalLOSBound.text,
            "secondsToMissionStart": (parseFloat(secondsToMissionStart.text, 10) + (parseFloat(takeoffDelay.text, 10)/1000)),
            "lidarAvailable": lidarAvailableBox.checked,
            "customerId": 1
        };
        if(droneNickname.text.length > 50){
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
        else{
            showMessageDialog(qsTr("Success"),
                    qsTr("Resolutions have been applied if any conflicts were detected."),
                    Dialog.Ok);
            undoResolutionButton.enabled = true
        }

    }

    function debugDetectConflicts(){

        let additionalDataObject = {
            "droneNickname": droneNickname.text,
            "faaRegistrationNumber": faaRegistrationNumber.text,
            "horizontalLOSBound" : horizontalLOSBound.text,
            "verticalLOSBound" : verticalLOSBound.text,
            "secondsToMissionStart": (parseFloat(secondsToMissionStart.text, 10) + (parseFloat(takeoffDelay.text, 10)/1000)),
            "lidarAvailable": lidarAvailableBox.checked,
            "customerId": 1
        };
        if(droneNickname.text.length > 50){
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

        let msg = planMasterController.debugDetectConflicts(partialJSONToSend);

        if(msg !== "Debug Route Returned Status 200"){
            showMessageDialog(qsTr("Debug Route Status"),
                    msg,
                    Dialog.Ok);
        }
        else{
            showMessageDialog("Debug Route Status",
                    qsTr("Debug Route Returned Status 200"),
                    Dialog.Ok);
        }

    }

    function addGeoFences() {
        showMessageDialog(qsTr("Warning"),
                        qsTr("Warning: GeoFences only work with exclusion zones and circles at this point"),
                        Dialog.Ok,
                        function() {
                            let msg = planMasterController.addGeoFences()
                            showMessageDialog(qsTr("Add GeoFences Status"),
                                msg,
                                Dialog.Ok)
                        })
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
                                                    let msg = planMasterController.overwriteGeoFences()
                                                    showMessageDialog(qsTr("Overwrite GeoFences Status"),
                                                        msg,
                                                        Dialog.Ok)
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
                        let msg = planMasterController.deleteGeoFences()
                        showMessageDialog(qsTr("Delete GeoFences Status"),
                            msg,
                            Dialog.Ok)
                    })
    }

    function undoResolution() {
        planMasterController.undoResolution()
        undoResolutionButton.enabled = false
    }

    function seed() {
        let seedIndex = seedTypeComboBox.currentIndex;
        let msg = planMasterController.changeSeed(seedIndex);
        showMessageDialog(qsTr("Seeding Status"),
                        msg)
    }


    // Background
    Rectangle {
        anchors.fill: parent
        color: qgcPal.fourDBlue
        z: -1
    }

    // Main content
    Rectangle {
        id:                 valuesRect
        anchors.left:       parent.left
        anchors.right:      parent.right
        anchors.top:        parent.top // Change this to anchors.top: parent.top if you want to control from PlanView
        anchors.bottom: parent.bottom
        color: qgcPal.fourDBlue // Make sure this matches your desired blue
        radius:             _radius

        QGCLabel {
            id:                 fourDLabel
            anchors.left:       parent.left
            anchors.right:      parent.right
            anchors.top:        parent.top
            anchors.margins:    _margin
            text:               qsTr("4D Avionic Systems Tools")
            anchors.leftMargin: ScreenTools.defaultFontPixelWidth
            width:              parent.width - (ScreenTools.defaultFontPixelWidth * 2)
        }

        Rectangle {
            id: fourDControlItems
            anchors.left:       parent.left
            anchors.right:      parent.right
            anchors.top:        fourDLabel.bottom
            anchors.bottom: parent.bottom
            anchors.margins: _margin // Only here!
            color:              qgcPal.windowShadeDark
            radius:             _radius

            Column {
                id:                 mainContentColumn
                width: parent.width
                spacing:            _margin

                SectionHeader {
                    id:                 droneDetailsSection
                    anchors.left:       parent.left
                    anchors.right:      parent.right
                    anchors.margins: _margin // <-- Add margin
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
                        anchors.margins: _margin // <-- Add margin
                    }
                    FactTextField {
                        id: droneNickname
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                        anchors.margins: _margin // <-- Add margin
                        text: "drone1"
                    }

                    QGCLabel {
                        text:           qsTr("Faa Registration Number")
                        font.pointSize: ScreenTools.smallFontPointSize
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                        anchors.margins: _margin // <-- Add margin
                    }
                    FactTextField {
                        id: faaRegistrationNumber
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                        anchors.margins: _margin // <-- Add margin
                        text: "FAXXXXXXXX"
                    }

                    QGCLabel {
                        text:           qsTr("Horizontal LOS Bound")
                        font.pointSize: ScreenTools.smallFontPointSize
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                        anchors.margins: _margin // <-- Add margin
                    }

                    FactTextField {
                        id: horizontalLOSBound
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: _margin // <-- Add margin
                        text: "10"
                        validator: IntValidator {
                            bottom: 1
                            top: 99
                        }
                    }

                    QGCLabel {
                        text:           qsTr("Vertical LOS Bound")
                        font.pointSize: ScreenTools.smallFontPointSize
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                        anchors.margins: _margin // <-- Add margin
                    }

                    FactTextField {
                        id: verticalLOSBound
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: _margin // <-- Add margin
                        text: "10"
                        validator: IntValidator {
                            bottom: 1
                            top: 99
                        }
                    }

                    QGCLabel {
                        text:           qsTr("Time From Now to Start Mission (Seconds)")
                        font.pointSize: ScreenTools.smallFontPointSize
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                        anchors.margins: _margin // <-- Add margin
                    }

                    FactTextField {
                        id: secondsToMissionStart
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: _margin // <-- Add margin
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
                        anchors.right: parent.right
                        anchors.margins: _margin // <-- Add margin
                    }
                }

                SectionHeader {
                    id:                 tuningSection
                    anchors.left:       parent.left
                    anchors.right:      parent.right
                    anchors.margins: _margin // <-- Add margin
                    text:               qsTr("Tuning")
                    checked:            true
                }
                Column {
                    id:                 tuningContent
                    anchors.left:       parent.left
                    anchors.right:      parent.right
                    spacing:            _margin
                    visible:            tuningSection.checked
                    height:             visible ? implicitHeight : 0

                    QGCLabel {
                        text: qsTr("Takeoff Delay (ms)")
                        font.pointSize: ScreenTools.smallFontPointSize
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                    }

                    FactTextField {
                        id: takeoffDelay
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: _margin
                        text: "1000"
                        validator: IntValidator {
                            bottom: 0
                            top: 999999
                        }
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
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: _margin // <-- Add margin
                        width:       conflictResolutionSection.width
                    }

                    QGCButton {
                        id:          undoResolutionButton
                        text:        qsTr("Undo Resolution")
                        enabled:     false
                        onClicked:   root.undoResolution()
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: _margin // <-- Add margin
                        width: detectConflictButton.width
                    }

                    /*QGCButton {
                        id:          debugDetectConflictsButton
                        text:        qsTr("Debug")
                        enabled:     true
                        onClicked:   root.debugDetectConflicts()
                        width:       conflictResolutionSection.width
                    }*/
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
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: _margin // <-- Add margin
                        width: detectConflictButton.width
                    }

                    QGCButton {
                        id:          overwriteGeoFenceButton
                        text:        qsTr("Overwrite GeoFences")
                        enabled:     true
                        onClicked:   root.overwriteGeoFences()
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: _margin // <-- Add margin
                        width: detectConflictButton.width
                    }

                    QGCButton {
                        id:          loadGeoFenceButton
                        text:        qsTr("Load GeoFences")
                        enabled:     true
                        onClicked:   root.loadGeoFences()
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: _margin // <-- Add margin
                        width: detectConflictButton.width
                    }

                    QGCButton {
                        id:          deleteGeoFenceButton
                        text:        qsTr("Clear GeoFence DB")
                        enabled:     true
                        onClicked:   root.deleteGeoFences()
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: _margin // <-- Add margin
                        width: detectConflictButton.width
                    }
                }

                SectionHeader {
                    id:                 seedManagementSection
                    anchors.left:       parent.left
                    anchors.right:      parent.right
                    text:               qsTr("Seeds")
                    checked:            false
                }

                Column {
                    id:                 seedManagementContent
                    anchors.left:       parent.left
                    anchors.right:      parent.right
                    spacing:            _margin
                    visible:            seedManagementSection.checked
                    height:             visible ? implicitHeight : 0

                    ComboBox {
                        id: seedTypeComboBox
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: _margin // <-- Add margin
                        model: [qsTr("Survey"), qsTr("Simple"), qsTr("Empty")]
                        currentIndex: 0
                    }

                    QGCButton {
                        id:          seedButton
                        text:        qsTr("Seed")
                        enabled:     true
                        onClicked:   root.seed()
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: _margin // <-- Add margin
                        width: detectConflictButton.width
                    }
                }
                

            }
        }
    }
}