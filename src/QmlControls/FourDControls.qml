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
        let msg = planMasterController.detectConflicts() // Use planMasterController directly
        if(msg != ""){
            showMessageDialog(qsTr("Error"),
                    msg,
                    Dialog.Ok)
        }

    }

    function addGeoFences() {
        showMessageDialog(qsTr("Warning"),
                        qsTr("Warning: GeoFences only work with exclusion zones and circles at this point"),
                        Dialog.Ok,
                        function() {planMasterController.addGeoFences()}) // Use planMasterController directly
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
                                                    planMasterController.overwriteGeoFences() // Use planMasterController directly

                                                })
                        })
    }

    function loadGeoFences() {
    showMessageDialog(qsTr("Would you like to clear existing circles?"),
                        qsTr("Click Yes to clear the existing circles before loading. \nClick No to add the loaded circles to the existing circles."),
                        Dialog.Yes | Dialog.No,
                    function () {
                        planMasterController.loadGeoFences(true) // Use planMasterController directly
                    })
    }

    function deleteGeoFences() {
    showMessageDialog(qsTr("Are you Sure?)"),
                        qsTr("This will delete all existing circles"),
                        Dialog.Yes | Dialog.No,
                    function () {
                        planMasterController.deleteGeoFences() // Use planMasterController directly
                    })
    }

    function undoResolution() {
        planMasterController.undoResolution() // Use planMasterController directly
    }


    Rectangle {
        id:                 valuesRect
        anchors.left:   parent.left
        anchors.right:  parent.right
        // height property will need to adjust dynamically based on which sections are open.
        // For simplicity, we can let it grow implicitly, or set a max height with Flickable if needed.
        height:             fourDLabel.height + fourDControlItems.height + (_margin * 3) // This will now automatically adapt due to Column layout
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
            height:             mainContentColumn.height + (_margin * 2) // Height now depends on the new main column

            Column { // This Column will hold all the SectionHeaders and their content
                id:                 mainContentColumn
                anchors.margins:    _margin
                anchors.top:        parent.top
                anchors.left:       parent.left
                anchors.right:      parent.right
                spacing:            _margin

                // --- Section 1: Drone Details ---
                SectionHeader {
                    id:                 droneDetailsSection
                    anchors.left:       parent.left
                    anchors.right:      parent.right
                    text:               qsTr("Flight Plan Details")
                    checked:            true // Start open
                }

                Column {
                    id:                 droneDetailsContent
                    anchors.left:       parent.left
                    anchors.right:      parent.right
                    spacing:            _margin
                    visible:            droneDetailsSection.checked // Controlled by SectionHeader
                    height:             visible ? implicitHeight : 0 // Collapse height when not visible

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
                } // End droneDetailsContent Column

                // --- Section 2: Conflict Resolution ---
                SectionHeader {
                    id:                 conflictResolutionSection
                    anchors.left:       parent.left
                    anchors.right:      parent.right
                    text:               qsTr("Conflict Resolution")
                    checked:            true // Start open
                }

                Column {
                    id:                 conflictResolutionContent
                    anchors.left:       parent.left
                    anchors.right:      parent.right
                    spacing:            _margin
                    visible:            conflictResolutionSection.checked // Controlled by SectionHeader
                    height:             visible ? implicitHeight : 0 // Collapse height when not visible

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
                } // End conflictResolutionContent Column

                // --- Section 3: GeoFence Management ---
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
                    visible:            geoFenceManagementSection.checked // Controlled by SectionHeader
                    height:             visible ? implicitHeight : 0 // Collapse height when not visible

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
                } // End geoFenceManagementContent Column

            } // End mainContentColumn (Column)
        } // End fourDControlItems (Rectangle)
    } // End valuesRect (Rectangle)
} // End root (Rectangle)