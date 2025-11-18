import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtPositioning

import QGroundControl
import QGroundControl.ScreenTools
import QGroundControl.Controls
import QGroundControl.FactSystem
import QGroundControl.FactControls

QGCFlickable {
    id:             root
    contentHeight:  geoFenceEditorRect.height
    clip:           true

    property var    myGeoFenceController
    property var    flightMap
    property var    planMasterController

    readonly property real  _editFieldWidth:    Math.min(width - _margin * 2, ScreenTools.defaultFontPixelWidth * 15)
    readonly property real  _margin:            ScreenTools.defaultFontPixelWidth / 2
    readonly property real  _radius:            ScreenTools.defaultFontPixelWidth / 2

    //4DAS Changes ------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function addGeoFences() {
        showMessageDialog(qsTr("Warning"),
                        qsTr("Warning: GeoFences only work with exclusion zones at this point"),
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
                        qsTr("Warning: GeoFences only work with exclusion zones at this point"),
                        Dialog.Ok,
                        function() {
                            showMessageDialog(qsTr("Are You Sure?"),
                                                qsTr("Are you sure? This will delete all the saved GeoFences for the currently selected customer in the database."),
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
    showMessageDialog(qsTr("Would you like to clear existing GeoFences?"),
                        qsTr("Click Yes to clear the existing GeoFences before loading. \nClick No to add the loaded GeoFences to the existing obstacles."),
                        Dialog.Yes | Dialog.No,
                    function () {
                        planMasterController.loadGeoFences(true)
                    },
                    function () {
                        planMasterController.loadGeoFences(false)
                    })
    }

    function deleteGeoFences() {
    showMessageDialog(qsTr("Are you Sure?"),
                        qsTr("This will delete all GeoFence obstacles from the database for the currently selected customer"),
                        Dialog.Yes | Dialog.No,
                    function () {
                        let msg = planMasterController.deleteGeoFences()
                        showMessageDialog(qsTr("Delete GeoFences Status"),
                            msg,
                            Dialog.Ok)
                    })
    }

    function deconflictAllGeoFences() {
        let msg = planMasterController.deconflictAllGeoFences()
        showMessageDialog(qsTr("Deconfliction Status"),
            msg,
            Dialog.Ok)
        undoResolutionGeoFenceButton.enabled = true
    }

    function deconflictSingleGeoFenceCircle(index) {
        let intIndex = parseInt(index)
        let msg = planMasterController.deconflictSingleGeoFenceCircle(intIndex)
        showMessageDialog(qsTr("Deconfliction Status"),
            msg,
            Dialog.Ok)
        undoResolutionGeoFenceButton.enabled = true
    }

    function deconflictSingleGeoFencePolygon(index) {
        let intIndex = parseInt(index)
        let msg = planMasterController.deconflictSingleGeoFencePolygon(intIndex)
        showMessageDialog(qsTr("Deconfliction Status"),
            msg,
            Dialog.Ok)
        undoResolutionGeoFenceButton.enabled = true
    }

    function undoResolution() {
        planMasterController.undoResolution()
        undoResolutionGeoFenceButton.enabled = false
    }
    //--------------------------------------------------------------------------------------------------------------------------------------------------------------------

    Rectangle {
        id:     geoFenceEditorRect
        anchors.left:   parent.left
        anchors.right:  parent.right
        height: geoFenceItems.y + geoFenceItems.height + (_margin * 2)
        radius: _radius
        color:  qgcPal.missionItemEditor

        QGCLabel {
            id:                 geoFenceLabel
            anchors.margins:    _margin
            anchors.left:       parent.left
            anchors.top:        parent.top
            text:               qsTr("GeoFence")
            anchors.leftMargin: ScreenTools.defaultFontPixelWidth
        }

        Rectangle {
            id:                 geoFenceItems
            anchors.margins:    _margin
            anchors.left:       parent.left
            anchors.right:      parent.right
            anchors.top:        geoFenceLabel.bottom
            height:             fenceColumn.y + fenceColumn.height + (_margin * 2)
            color:              qgcPal.windowShadeDark
            radius:             _radius

            Column {
                id:                 fenceColumn
                anchors.margins:    _margin
                anchors.top:        parent.top
                anchors.left:       parent.left
                anchors.right:      parent.right
                spacing:            _margin

                QGCLabel {
                    anchors.left:       parent.left
                    anchors.right:      parent.right
                    wrapMode:           Text.WordWrap
                    font.pointSize:     myGeoFenceController.supported ? ScreenTools.smallFontPointSize : ScreenTools.defaultFontPointSize
                    text:               myGeoFenceController.supported ?
                                            qsTr("GeoFencing allows you to set a virtual fence around the area you want to fly in.") :
                                            qsTr("This vehicle does not support GeoFence.")
                }

                Column {
                    anchors.left:       parent.left
                    anchors.right:      parent.right
                    spacing:            _margin
                    visible:            myGeoFenceController.supported

                    Repeater {
                        model: myGeoFenceController.params

                        Item {
                            width:  fenceColumn.width
                            height: textField.height

                            property bool showCombo: modelData.enumStrings.length > 0

                            QGCLabel {
                                id:                 textFieldLabel
                                anchors.baseline:   textField.baseline
                                text:               myGeoFenceController.paramLabels[index]
                            }

                            FactTextField {
                                id:             textField
                                anchors.right:  parent.right
                                width:          _editFieldWidth
                                showUnits:      true
                                fact:           modelData
                                visible:        !parent.showCombo
                            }

                            FactComboBox {
                                id:             comboField
                                anchors.right:  parent.right
                                width:          _editFieldWidth
                                indexModel:     false
                                fact:           showCombo ? modelData : _nullFact
                                visible:        parent.showCombo

                                property var _nullFact: Fact { }
                            }
                        }
                    }

                //4DAVSYS Changes ------------------------------------------------------------------------------------------------------------------------------------------------------------------
                SectionHeader {
                id:                 geoFenceManagementSection
                anchors.left:       parent.left
                anchors.right:      parent.right
                text:               qsTr("Database Management")
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
                        width: addBreachReturnPointButton.width
                    }

                    QGCButton {
                        id:          overwriteGeoFenceButton
                        text:        qsTr("Overwrite GeoFences")
                        enabled:     true
                        onClicked:   root.overwriteGeoFences()
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: _margin // <-- Add margin
                        width: addBreachReturnPointButton.width
                    }

                    QGCButton {
                        id:          loadGeoFenceButton
                        text:        qsTr("Load GeoFences")
                        enabled:     true
                        onClicked:   root.loadGeoFences()
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: _margin // <-- Add margin
                        width: addBreachReturnPointButton.width
                    }

                    QGCButton {
                        id:          deleteGeoFenceButton
                        text:        qsTr("Clear Customer GeoFences")
                        enabled:     true
                        onClicked:   root.deleteGeoFences()
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: _margin // <-- Add margin
                        width: addBreachReturnPointButton.width
                    }
                }

                SectionHeader {
                id:                 deconflictionSection
                anchors.left:       parent.left
                anchors.right:      parent.right
                text:               qsTr("Deconfliction")
                checked:            true
                }

                Column {
                    id:                 deconflictionContent
                    anchors.left:       parent.left
                    anchors.right:      parent.right
                    spacing:            _margin
                    visible:            deconflictionSection.checked
                    height:             visible ? implicitHeight : 0

                    QGCButton {
                        id:          deconflictGeoFencesButton
                        text:        qsTr("Deconflict All GeoFences")
                        enabled:     true
                        onClicked:   root.deconflictAllGeoFences()
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: _margin // <-- Add margin
                        width: addBreachReturnPointButton.width
                    }

                    QGCButton {
                        id:          resolveGeoFenceButton
                        text:        qsTr("Resolve Conflicts")
                        enabled:     false
                        onClicked:   root.resolveGeoFences()
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: _margin // <-- Add margin
                        width: addBreachReturnPointButton.width
                    }

                    QGCButton {
                        id:          undoResolutionGeoFenceButton
                        text:        qsTr("Undo Resolution")
                        enabled:     false
                        onClicked:   root.undoResolution()
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: _margin // <-- Add margin
                        width: addBreachReturnPointButton.width
                    }
                }
                //----------------------------------------------------------------------------------------------------------

                    SectionHeader {
                        id:             insertSection
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                        text:           qsTr("Insert GeoFence")
                    }

                    QGCButton {
                        Layout.fillWidth:   true
                        text:               qsTr("Polygon Fence")

                        onClicked: {
                            var rect = Qt.rect(flightMap.centerViewport.x, flightMap.centerViewport.y, flightMap.centerViewport.width, flightMap.centerViewport.height)
                            var topLeftCoord = flightMap.toCoordinate(Qt.point(rect.x, rect.y), false /* clipToViewPort */)
                            var bottomRightCoord = flightMap.toCoordinate(Qt.point(rect.x + rect.width, rect.y + rect.height), false /* clipToViewPort */)
                            myGeoFenceController.addExclusionPolygon(topLeftCoord, bottomRightCoord)
                        }
                    }

                    QGCButton {
                        Layout.fillWidth:   true
                        text:               qsTr("Circular Fence")

                        onClicked: {
                            var rect = Qt.rect(flightMap.centerViewport.x, flightMap.centerViewport.y, flightMap.centerViewport.width, flightMap.centerViewport.height)
                            var topLeftCoord = flightMap.toCoordinate(Qt.point(rect.x, rect.y), false /* clipToViewPort */)
                            var bottomRightCoord = flightMap.toCoordinate(Qt.point(rect.x + rect.width, rect.y + rect.height), false /* clipToViewPort */)
                            myGeoFenceController.addExclusionCircle(topLeftCoord, bottomRightCoord)
                        }
                    }

                    SectionHeader {
                        id:             polygonSection
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                        text:           qsTr("Polygon Fences")
                    }

                    QGCLabel {
                        text:       qsTr("None")
                        visible:    polygonSection.checked && myGeoFenceController.polygons.count === 0
                    }

                    GridLayout {
                        Layout.fillWidth:   true
                        columns:            4
                        flow:               GridLayout.TopToBottom
                        visible:            polygonSection.checked && myGeoFenceController.polygons.count > 0

                        QGCLabel {
                            text:               qsTr("On")
                            Layout.column:      0
                            Layout.alignment:   Qt.AlignHCenter
                        }

                        Repeater {
                            model: myGeoFenceController.polygons

                            QGCCheckBox {
                                checked:            !object.inclusion
                                onClicked:          object.inclusion = !checked
                                Layout.alignment:   Qt.AlignHCenter
                            }
                        }

                        QGCLabel {
                            text:               qsTr("Edit")
                            Layout.column:      1
                            Layout.alignment:   Qt.AlignHCenter
                        }

                        Repeater {
                            model: myGeoFenceController.polygons

                            QGCRadioButton {
                                checked:            _interactive
                                Layout.alignment:   Qt.AlignHCenter

                                property bool _interactive: object.interactive

                                on_InteractiveChanged: checked = _interactive

                                onClicked: {
                                    myGeoFenceController.clearAllInteractive()
                                    object.interactive = checked
                                }
                            }
                        }

                        QGCLabel {
                            text:               qsTr("Delete")
                            Layout.column:      2
                            Layout.alignment:   Qt.AlignHCenter
                        }

                        Repeater {
                            model: myGeoFenceController.polygons

                            QGCButton {
                                text:               qsTr("Del")
                                Layout.alignment:   Qt.AlignHCenter
                                onClicked:          myGeoFenceController.deletePolygon(index)
                            }
                        }

                        // 4DAVSYS Changes ------------------------------------------------------------------------------------------------------------------------------------------------------------------

                        QGCLabel {
                            text:               qsTr("Conflicts")
                            Layout.column:      3
                            Layout.alignment:   Qt.AlignHCenter
                        }

                        Repeater {
                            model: myGeoFenceController.polygons

                            QGCButton {
                                text:               qsTr("Resolve")
                                Layout.alignment:   Qt.AlignHCenter
                                onClicked:          deconflictSingleGeoFencePolygon(index)
                            }
                        }
                        //--------------------------------------------------------------------------------------------------------------------------------------------------------------------
                    
                    } // GridLayout

                    SectionHeader {
                        id:             circleSection
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                        text:           qsTr("Circular Fences")
                    }

                    QGCLabel {
                        text:       qsTr("None")
                        visible:    circleSection.checked && myGeoFenceController.circles.count === 0
                    }

                    GridLayout {
                        anchors.left:       parent.left
                        anchors.right:      parent.right
                        columns:            5
                        flow:               GridLayout.TopToBottom
                        visible:            polygonSection.checked && myGeoFenceController.circles.count > 0

                        QGCLabel {
                            text:               qsTr("On")
                            Layout.column:      0
                            Layout.alignment:   Qt.AlignHCenter
                        }

                        Repeater {
                            model: myGeoFenceController.circles

                            QGCCheckBox {
                                checked:            !(object.inclusion)
                                onClicked:          object.inclusion = !(checked)
                                Layout.alignment:   Qt.AlignHCenter
                                
                            }
                        }

                        QGCLabel {
                            text:               qsTr("Edit")
                            Layout.column:      1
                            Layout.alignment:   Qt.AlignHCenter
                        }

                        Repeater {
                            model: myGeoFenceController.circles

                            QGCRadioButton {
                                checked:            _interactive
                                Layout.alignment:   Qt.AlignHCenter

                                property bool _interactive: object.interactive

                                on_InteractiveChanged: checked = _interactive

                                onClicked: {
                                    myGeoFenceController.clearAllInteractive()
                                    object.interactive = checked
                                }
                            }
                        }

                        QGCLabel {
                            text:               qsTr("Radius")
                            Layout.column:      2
                            Layout.alignment:   Qt.AlignHCenter
                        }

                        Repeater {
                            model: myGeoFenceController.circles

                            FactTextField {
                                fact:               object.radius
                                Layout.fillWidth:   true
                                Layout.alignment:   Qt.AlignHCenter
                            }
                        }

                        QGCLabel {
                            text:               qsTr("Delete")
                            Layout.column:      3
                            Layout.alignment:   Qt.AlignHCenter
                        }

                        Repeater {
                            model: myGeoFenceController.circles

                            QGCButton {
                                text:               qsTr("Del")
                                Layout.alignment:   Qt.AlignHCenter
                                onClicked:          myGeoFenceController.deleteCircle(index)
                            }
                        }
                        // 4DAVSYS Changes ------------------------------------------------------------------------------------------------------------------------------------------------------------------

                        QGCLabel {
                            text:              qsTr("Conflicts")
                            Layout.column:      4
                            Layout.alignment:   Qt.AlignHCenter
                        }

                        Repeater {
                            model: myGeoFenceController.circles

                            QGCButton {
                                text:               qsTr("Resolve")
                                Layout.alignment:   Qt.AlignHCenter
                                onClicked:          root.deconflictSingleGeoFenceCircle(index)
                            }
                        }
                        //--------------------------------------------------------------------------------------------------------------------------------------------------------------------
                    } // GridLayout

                    SectionHeader {
                        id:             breachReturnSection
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                        text:           qsTr("Breach Return Point")
                    }

                    QGCButton {
                        id:                 addBreachReturnPointButton
                        text:               qsTr("Add Breach Return Point")
                        visible:            breachReturnSection.visible && !myGeoFenceController.breachReturnPoint.isValid
                        anchors.left:       parent.left
                        anchors.right:      parent.right

                        onClicked: myGeoFenceController.breachReturnPoint = flightMap.center
                    }

                    QGCButton {
                        text:               qsTr("Remove Breach Return Point")
                        visible:            breachReturnSection.visible && myGeoFenceController.breachReturnPoint.isValid
                        anchors.left:       parent.left
                        anchors.right:      parent.right

                        onClicked: myGeoFenceController.breachReturnPoint = QtPositioning.coordinate()
                    }

                    ColumnLayout {
                        anchors.left:       parent.left
                        anchors.right:      parent.right
                        spacing:            _margin
                        visible:            breachReturnSection.visible && myGeoFenceController.breachReturnPoint.isValid

                        QGCLabel {
                            text: qsTr("Altitude")
                        }

                        FactTextField {
                            fact: myGeoFenceController.breachReturnAltitude
                        }
                    }

                }
            }
        }
    } // Rectangle
}
