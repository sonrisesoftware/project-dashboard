import QtQuick 2.0
import Ubuntu.Components 1.0
import Ubuntu.Components.ListItems 1.0 as ListItem
import Ubuntu.Components.Popups 1.0

import "../../ubuntu-ui-extras"

PageView {

    title: plugin.title

    default property alias contents: _contents.children

    property bool hasSettings: false

    Rectangle {
        anchors.fill: _title
        color: Qt.rgba(0,0,0,0.1)
    }

    ListItem.Standard {
        id: _title

        Label {
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                leftMargin: units.gu(2)
            }
            fontSize: "large"
            text: title
        }

        Row {
            anchors {
                right: parent.right
                rightMargin: units.gu(2)
                verticalCenter: parent.verticalCenter
            }

            spacing: units.gu(1)

            Button {
                text: "Remove"
                color: colors["red"]

                onClicked: PopupUtils.open(confirmDeleteDialog)
            }
        }
    }

    Item {
        id: _contents

        anchors {
            left: parent.left
            right: parent.right
            top: _title.bottom
            bottom: parent.bottom
        }

        Label {
            anchors.centerIn: parent
            fontSize: "large"
            opacity: 0.5

            text: "No configuration settings"
            visible: !hasSettings
        }
    }

    property Component confirmDeleteDialog: ConfirmDialog {
        title: i18n.tr("Remove Plugin")
        text: i18n.tr("Are you sure you want to remove the %1 plugin from your project?<br><br><b>WARNING: Doing so will delete ALL data stored by the plugin!</b>").arg(plugin.title)

        acceptText: i18n.tr("Remove")
        acceptColor: colors["red"]

        onAccepted: {
            project.removePlugin(plugin.type)
        }
    }
}
