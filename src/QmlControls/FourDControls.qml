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
    color:              qgcPal.missionItemEditor

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
        height:             fourDLabel.height + fourDControlItems.height + (_margin * 3)
        color:              qgcPal.missionItemEditor
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
            height:             valuesColumn.height + (_margin * 2)

            Column {
                id:                 valuesColumn
                anchors.margins:    _margin
                anchors.top:        parent.top
                anchors.left:       parent.left
                anchors.right:      parent.right
                spacing:            _margin

                // --- Drone Nickname ---
                QGCLabel {
                    text:           qsTr("Drone Nickname")
                    font.pointSize: ScreenTools.smallFontPointSize
                    anchors.left:   parent.left
                    anchors.right:  parent.right
                }
                FactTextField {
                    anchors.left:   parent.left
                    anchors.right:  parent.right
                }

                // --- Faa Registration Number ---
                QGCLabel {
                    text:           qsTr("Faa Registration Number")
                    font.pointSize: ScreenTools.smallFontPointSize
                    anchors.left:   parent.left
                    anchors.right:  parent.right
                }
                FactTextField {
                    anchors.left:   parent.left
                    anchors.right:  parent.right
                }

                // --- UTC Start Time ---
                QGCLabel {
                    text:           qsTr("UTC Start Time")
                    font.pointSize: ScreenTools.smallFontPointSize
                    anchors.left:   parent.left
                    anchors.right:  parent.right
                }
                FactTextField {
                    anchors.left:   parent.left
                    anchors.right:  parent.right
                }

                QGCLabel {
                    text: qsTr("Start Date and Time")
                    font.pointSize: ScreenTools.smallFontPointSize
                    anchors.left:   parent.left
                    anchors.right:  parent.right
                }

                 FactTextField {
                     anchors.left: parent.left
                     anchors.right: parent.right
                 }
                QGCCheckBox {
                    id:         lidarAvailableBox
                    text:       qsTr("Lidar Available?")
                    anchors.left: parent.left
                }

                QGCButton {
                    id:          detectConflictButton
                    text:        qsTr("Detect & Resolve Conflicts")
                    enabled:     true
                    onClicked:   root.detectConflicts() // Corrected: Call function on 'root'
                }

                QGCButton {
                    id:          undoResolutionButton
                    text:        qsTr("Undo Resolution")
                    enabled:     true
                    onClicked:   root.undoResolution() // Corrected: Call function on 'root'
                }

                QGCButton {
                    id:          addGeoFenceButton
                    text:        qsTr("Add GeoFences")
                    enabled:     true
                    onClicked:   root.addGeoFences() // Corrected: Call function on 'root'
                }

                QGCButton {
                    id:          overwriteGeoFenceButton
                    text:        qsTr("Overwrite GeoFences")
                    enabled:     true
                    onClicked:   root.overwriteGeoFences() // Corrected: Call function on 'root'
                }

                QGCButton {
                    id:          loadGeoFenceButton
                    text:        qsTr("Load GeoFences")
                    enabled:     true
                    onClicked:   root.loadGeoFences() // Corrected: Call function on 'root'
                }

                QGCButton {
                    id:          deleteGeoFenceButton
                    text:        qsTr("Clear GeoFence DB")
                    enabled:     true
                    onClicked:   root.deleteGeoFences() // Corrected: Call function on 'root'
                }


            } // End valuesColumn (Column)
        } // End fourDControlItems (Rectangle)
    } // End valuesRect (Rectangle)
} // End root (Rectangle)