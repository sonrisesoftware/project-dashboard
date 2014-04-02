/*
 * Project Dashboard - Manage everything about your projects in one app
 * Copyright (C) 2014 Michael Spencer
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import "../ubuntu-ui-extras"
import "../ubuntu-ui-extras/dateutils.js" as DateUtils

ListItem.Empty {

    id: root

    property alias done: doneCheckBox.checked
    property alias text: titleLabel.text
    property alias subText: subLabel.text

    height: opacity === 0 ? 0 : implicitHeight

    Behavior on height {
        UbuntuNumberAnimation {}
    }

    opacity: show ? 1 : 0

    Behavior on opacity {
        UbuntuNumberAnimation {}
    }

    property bool show: !doc.get("done", false)

    clip: true

    CheckBox {
        id: doneCheckBox

        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: (parent.height - doneCheckBox.height)/2
        }

        style: SuruCheckBoxStyle {}
    }

    Column {
        id: labels

        spacing: units.gu(0.1)

        anchors {
            verticalCenter: parent.verticalCenter
            left: doneCheckBox.visible ? doneCheckBox.right : parent.left
            leftMargin: doneCheckBox.visible ? units.gu(1) : units.gu(2)
            rightMargin: units.gu(1)
            right: parent.right
        }

        Label {
            id: titleLabel

            width: parent.width
            elide: Text.ElideRight

            //font.bold: task.priority !== "low"
            color: selected ? UbuntuColors.orange : /*task.priority === "low" ? */Theme.palette.selected.backgroundText/* : priorityColor(task.priority)*/
            fontSize: "medium"
        }

        Label {
            id: subLabel
            width: parent.width

            height: visible ? implicitHeight: 0
            color:  Theme.palette.normal.backgroundText
            fontSize: "small"
            //font.italic: true
            visible: text !== ""
            elide: Text.ElideRight
        }
    }

    onClicked: PopupUtils.open(editPopover, root)

    Component {
        id: editPopover

        Popover {
            id: popover
            contentHeight: textField.height + units.gu(2)

            Component.onCompleted: textField.forceActiveFocus()

            Item {
                height: textField.height + units.gu(2)
                width: parent.width
                Button {
                    id: button
                    text: i18n.tr("Done")
                    onTriggered: {
                        PopupUtils.close(popover)
                        doc.set("title", textField.text)
                    }

                    anchors {
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                        margins: units.gu(1)
                    }
                }

                TextField {
                    id: textField
                    text: doc.get("title", "")
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        right: button.left
                        margins: units.gu(1)
                    }
                    onAccepted: button.trigger()
                }
            }
        }
    }

    function formatText(text) {
        var regex = /(\d\d?:\d\d\s*(PM|AM|pm|am))/gi
        text = text.replace(regex, "<font color=\"" + colors["green"] + "\">$1</font>")
        return text
    }
}
