import QtQuick
import QtQuick.Controls
// Removed QtQuick.Layouts since we're using Column and anchors
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

// The outermost element is a Rectangle, consistent with your reference
Rectangle {
    id:                 root // Naming this 'root' is fine as per your reference
    // The height will be dynamically set to encapsulate its content
    height:             valuesRect.height // This is how the geoFence example handles root height
    clip:               true // Same as reference
    color:              qgcPal.missionItemEditor // Same as reference

    // Define properties similar to your reference
    // Ensure these properties are defined before use if they affect initial layout
    property real _margin: ScreenTools.defaultFontPixelWidth / 2
    property real _radius : ScreenTools.defaultFontPixelWidth / 2

    // This is equivalent to geoFenceEditorRect in your reference
    Rectangle {
        id:                 valuesRect
        // Anchor to the parent of 'root' if 'root' is not fullscreen.
        // If 'root' is intended to fill its parent, then valuesRect would typically
        // also fill root, or be centered. For now, matching the reference's left/right.
        anchors.left:   parent.left
        anchors.right:  parent.right
        // Height calculated based on its content, similar to geoFenceEditorRect
        height:             fourDLabel.height + fourDControlItems.height + (_margin * 3) // Adjusted based on your elements
        color:              qgcPal.missionItemEditor // Background color for this main section
        radius:             _radius

        // This is the title label, equivalent to geoFenceLabel
        QGCLabel {
            id:                 fourDLabel
            anchors.margins:    _margin
            anchors.left:       parent.left
            anchors.top:        parent.top // Anchored to the top of valuesRect
            text:               qsTr("4D Avionic Systems Tools")
            anchors.leftMargin: ScreenTools.defaultFontPixelWidth
        }

        // This is the shaded background rectangle for your input controls,
        // equivalent to geoFenceItems in your reference.
        Rectangle {
            id: fourDControlItems
            anchors.margins:    _margin
            anchors.left:       parent.left
            anchors.right:      parent.right
            anchors.top:        fourDLabel.bottom // Crucial: Anchored below the title label
            color:              qgcPal.windowShadeDark // Shaded background
            radius:             _radius
            // Height calculated based on its internal Column
            height:             valuesColumn.height + (_margin * 2) // Account for Column's content + margins

            // This is the main Column that stacks all your labels and text fields vertically,
            // equivalent to fenceColumn in your reference.
            Column { // Using Column, not ColumnLayout
                id:                 valuesColumn
                anchors.margins:    _margin // Margins around the content inside this Column
                anchors.top:        parent.top // Anchored to the top of fourDControlItems
                anchors.left:       parent.left
                anchors.right:      parent.right
                spacing:            _margin // Spacing between items within this Column

                // --- Drone Nickname ---
                QGCLabel {
                    text:           qsTr("Drone Nickname")
                    font.pointSize: ScreenTools.smallFontPointSize
                    // In a Column, you might explicitly anchor left/right or rely on implicit sizing
                    anchors.left:   parent.left
                    anchors.right:  parent.right
                }
                FactTextField {
                    // No Layout.fillWidth here, as we are not using Layouts for this Column
                    // You might need to set an explicit width or anchor right
                    anchors.left:   parent.left // Or anchors.right: parent.right, width: someWidth
                    anchors.right:  parent.right // This makes it fill the parent width
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

                // --- Start Date and Time (from your original, was missing in some previous versions) ---
                QGCLabel {
                    text: qsTr("Start Date and Time")
                    font.pointSize: ScreenTools.smallFontPointSize
                    anchors.left:   parent.left
                    anchors.right:  parent.right
                }
                // If this is just a label, you might have a FactTextField for it, or another control
                // Based on previous snippets, it seems like it might be a missing input field.
                // Assuming you'd add a FactTextField here:
                // FactTextField {
                //     anchors.left: parent.left
                //     anchors.right: parent.right
                // }

                // --- Lidar Available CheckBox ---
                QGCCheckBox {
                    id:         lidarAvailableBox
                    text:       qsTr("Lidar Available?")
                    anchors.left: parent.left // Align left within the column
                }
            } // End valuesColumn (Column)
        } // End fourDControlItems (Rectangle)
    } // End valuesRect (Rectangle)
} // End root (Rectangle)