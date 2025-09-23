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
    contentHeight:      mainContentColumn.height + fourDLabel.height + (_margin * 3)
    clip:               true
    height:             Math.min(contentHeight + _margin * 2, ScreenTools.availableHeight * 0.75)

    property real _margin: ScreenTools.defaultFontPixelWidth / 2
    property real _radius : ScreenTools.defaultFontPixelWidth / 2

    property var    planMasterController

    function getJSONRequest(){
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
        return partialJSONToSend;
    }

    function detectConflicts(){

        let partialJSONToSend = getJSONRequest();

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
        
        let partialJSONToSend = getJSONRequest();

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

    function seed() {
        let seedIndex = seedTypeComboBox.currentIndex;
        let msg = planMasterController.changeSeed(seedIndex);
        showMessageDialog(qsTr("Seeding Status"),
                        msg)
    }

    function undoResolution() {
        planMasterController.undoResolution()
        undoResolutionButton.enabled = false
    }

    // Main content
    Rectangle {
        id:                 valuesRect
        anchors.left:       parent.left
        anchors.right:      parent.right
        anchors.top:        parent.top 
        anchors.bottom:     parent.bottom
        color:              qgcPal.fourDBlue 
        radius:             _radius
        //height: fourDControlItems.height + fourDLabel.height + (_margin * 3)

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
            anchors.bottom:     parent.bottom
            anchors.margins: _margin
            color:              qgcPal.windowShadeDark
            radius:             _radius
            //height: Math.max(mainContentColumn.implicitHeight, parent.height - fourDLabel.height - (_margin * 3))

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

                    QGCButton {
                        id:          debugDetectConflictsButton
                        text:        qsTr("Debug")
                        enabled:     true
                        onClicked:   root.debugDetectConflicts()
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
                    anchors.margins: _margin
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
                        anchors.bottomMargin: _margin * 2
                        width: detectConflictButton.width
                    }
                }
                

            }
        }
    }
}