import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import "../backend"
import "../ubuntu-ui-extras"

Page {
    id: page
    
    title: project.name

    property alias docId: project.docId

    actions: [
        Action {
            id: configAction
            text: i18n.tr("Edit")
            iconSource: getIcon("edit")
            onTriggered:pageStack.push(Qt.resolvedUrl("ConfigPage.qml"), {project: project})
        }

    ]

    Project {
        id: project
        docId: modelData
    }

    ListView {
        anchors.fill: parent
        model: project.plugins
        spacing: units.gu(2)
        header: Item {
            width: parent.width
            height: units.gu(2)
        }

        footer: Item {
            width: parent.width
            height: units.gu(2)
        }

        delegate: UbuntuShape {
            anchors {
                left: parent.left
                right: parent.right
                margins: units.gu(2)
            }
            color: Qt.rgba(0,0,0,0.2)
            height: units.gu(15)
            radius: "medium"

            Label {
                anchors.centerIn: parent
                text: child.get("name")
            }

            Document {
                id: child
                parent: project.document
                docId: modelData
            }
        }
    }

    tools: ToolbarItems {
        ToolbarButton {
            action: configAction
        }
    }
}
