import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import "../backend"

Page {
    id: page
    
    title: i18n.tr("Project Configuration")

    property Project project

    Column {
        anchors.fill: parent

        ListItem.Standard {
            text: i18n.tr("Name")
            control: TextField {
                text: project.name
                onTextChanged: project.name = text
            }
        }

        ListItem.Header {
            text: i18n.tr("Local Plugins")
        }

        ListItem.Standard {
            text: i18n.tr("Notes")
            control: Switch {}
        }

        ListItem.Standard {
            text: i18n.tr("To Do")
            control: Switch {}
        }

        ListItem.Standard {
            text: i18n.tr("Drawings")
            control: Switch {}
        }

        ListItem.Header {
            text: i18n.tr("Services")
        }

        ListItem.Standard {
            text: i18n.tr("GitHub")
            control: Switch {}
        }

        ListItem.Standard {
            text: i18n.tr("Launchpad")
            control: Switch {}
        }
    }
}
