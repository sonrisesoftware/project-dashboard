import QtQuick 2.0
import "../qml-air"
import "../qml-air/ListItems" as ListItem

Popover {
    id: userPopover

    contentHeight: parseBackend.account.signedIn ? userColumn.height : noUserColumn.height
    width: units.gu(30)

    Gravatar {
        id: gravatar
        email: parseBackend.account.email
        size: gravatarIcon.size
    }

    Column {
        id: noUserColumn
        width: parent.width
        visible: !parseBackend.account.signedIn

        Item {
            width: parent.width
            height: units.gu(20)

            Column {
                anchors.centerIn: parent
                width: parent.width
                spacing: units.gu(1)

                Icon {
                    id: icon
                    size: units.gu(5)
                    name: "user"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Label {
                    text: "Not signed in"
                    fontSize: "large"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: theme.secondaryColor
                    font.italic: true
                    font.pixelSize: units.gu(1.5)
                    text: "Create a Pro account to get cloud syncronization and more plugins"
                    width: parent.width - units.gu(4)
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        ListItem.ThinDivider {

        }

        ListItem.Standard {
            text: "Create a Pro account..."
            height: units.gu(4)
        }

        ListItem.Standard {
            text: "Sign in.."
            height: units.gu(4)
            onClicked: {
                userPopover.close()
                parseBackend.showLoginDialog()
            }
        }

        ListItem.Standard {
            text: "Learn more..."
            height: units.gu(4)
        }
    }

    Column {
        id: userColumn
        width: parent.width
        visible: parseBackend.account.signedIn

        Item {
            width: parent.width
            height: units.gu(16)

            Column {
                anchors.centerIn: parent
                width: parent.width
                spacing: units.gu(1)

                Icon {
                    size: icon.size
                    name: "user"
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: gravatarIcon.status !== Image.Ready
                }

                CircleImage {
                    id: gravatarIcon

                    property int size: units.gu(6)

                    source: gravatar.url
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: gravatarIcon.status === Image.Ready

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -1
                        radius: height/2
                        color: "transparent"
                        border.color: "white"
                        border.width: 3
                    }

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -1
                        radius: height/2
                        color: "transparent"
                        border.color: theme.textColor
                    }
                }

                Label {
                    text: parseBackend.account.name
                    fontSize: "large"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Label {
                    text: "Basic Account"
                    font.italic: true
                    color: theme.secondaryColor
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }

        ListItem.ThinDivider {

        }

        ListItem.Standard {
            text: "Sign out.."
            height: units.gu(4)
            onClicked: {
                userPopover.close()
                parseBackend.logout()
            }
        }

        ListItem.Standard {
            text: "View account..."
            height: units.gu(4)
            onClicked: {
                userPopover.close()
                accountSheet.open()
            }
        }
    }
}
