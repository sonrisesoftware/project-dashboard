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
import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 1.0
import Ubuntu.Components.ListItems 1.0 as ListItem
import "../ubuntu-ui-extras"
import "../components"

Walkthough {
    id: walkthrough
    appName: "Project Dashboard"
    onFinished: {
        settings.set("existingInstallation", true)
    }

    // Needs custom property to show up in autopilot tests
    property bool test: true

    model: [
         Component {
            Item {
                Image {
                    anchors {
                        bottom: welcomeColumn.top
                        bottomMargin: units.gu(4)
                        horizontalCenter: parent.horizontalCenter
                    }
                    fillMode: Image.PreserveAspectFit
                    width: units.gu(11)
                    source: Qt.resolvedUrl("../project-dashboard-shadowed.png")
                }

                Column {
                    id: welcomeColumn
                    anchors {
                        centerIn: parent
                    }

                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        fontSize: "large"
                        text: i18n.tr("Welcome to")
                    }

                    Label {
                        fontSize: "x-large"
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: i18n.tr("Project Dashboard")
                    }
                }

                Label {
                    anchors {
                        bottom: parent.bottom
                        horizontalCenter: parent.horizontalCenter
                    }
                    text: i18n.tr("Swipe left to continue")
                }
            }
        },

        Component {
           Item {
               Label {
                   id: headerLabel
                   anchors.horizontalCenter: parent.horizontalCenter
                   fontSize: "x-large"
                   text: i18n.tr("Project Dashboard")
               }

               Label {
                   id: contentsLabel
                   anchors {
                       top: headerLabel.bottom
                       topMargin: units.gu(2)
                   }

                   width: parent.width
                   font.pixelSize: units.dp(17)
                   wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                   horizontalAlignment: Text.AlignHCenter
                   text: i18n.tr("Project Dashboard helps you manage everything about your projects in one convienent app.  " +
                                 "Add plugins to track upcoming dates, keep notes, track time, manage to dos, and much more.")
               }

               Image {
                   fillMode: Image.PreserveAspectFit
                   width: parent.width
                   source: Qt.resolvedUrl("../walkthrough-plugins.png")
                   smooth: true
                   antialiasing: true


                   anchors {
                       top: contentsLabel.bottom
                       bottom: parent.bottom
                       topMargin: units.gu(2)
                   }
               }
           }
       },

       Component {
            Item {
                Label {
                    id: headerLabel
                    anchors.horizontalCenter: parent.horizontalCenter
                    fontSize: "x-large"
                    text: i18n.tr("Use Cases")
                }

                Label {
                    id: contentsLabel
                    anchors {
                        top: headerLabel.bottom
                        topMargin: units.gu(2)
                    }

                    width: parent.width
                    font.pixelSize: units.dp(17)
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    horizontalAlignment: Text.AlignHCenter
                    text: i18n.tr("There are many uses for Project Dashboard. Here are a few ideas to help you get started:")
                }

                Label {
                    id: list
                    anchors {
                        top: contentsLabel.bottom
                        topMargin: units.gu(2)
                        left: parent.left
                        right: parent.right
                        leftMargin: units.gu(-1.5)
                    }

                    font.pixelSize: units.dp(17)
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: i18n.tr("<ul>" +
                                  "<li>Managing a software project hosted on GitHub</li>" +
                                  "<li>Working as a hourly contractor</li>" +
                                  "<li>Planning an upcoming family reunion, wedding or other event</li>" +
                                  "<li>Keeping track of a class or project</li>" +
                                  "<li>And lots more...</li>" +
                                  "</ul>")
                    textFormat: Text.RichText
                }

//                        Label {
//                            anchors {
//                                top: list.bottom
//                                topMargin: units.gu(2)
//                            }

//                            width: parent.width
//                            //font.pixelSize: units.dp(17)
//                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
//                            horizontalAlignment: Text.AlignHCenter
//                            text: i18n.tr("To decide if Project Dashboard is right for managing your project, just ask yourself the question \"Would I rather go to different apps to manage my project or would I rather have everything in one place?\"")
//                        }
            }
       },

       Component {
           Item {
               Label {
                   id: headerLabel
                   anchors.horizontalCenter: parent.horizontalCenter
                   fontSize: "x-large"
                   text: i18n.tr("Inbox")
               }

               Label {
                   id: contentsLabel
                   anchors {
                       top: headerLabel.bottom
                       topMargin: units.gu(2)
                   }

                   width: parent.width
                   font.pixelSize: units.dp(17)
                   wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                   horizontalAlignment: Text.AlignHCenter
                   text: i18n.tr("If you have projects that are connected to online services, such as GitHub, " +
                                 "new notifications will show up in your project's inbox and also the global inbox.")
               }

               Item {
                   anchors {
                       top: contentsLabel.bottom
                       bottom: parent.bottom
                       topMargin: units.gu(2)
                   }

                   width: parent.width


                   AwesomeIcon {
                       color: "#d9534f"
                       name: "bell"
                       size: units.gu(9)
                       anchors.centerIn: parent
                   }
               }
           }
        },

        Component {
            Item {
                Label {
                    id: headerLabel
                    anchors.horizontalCenter: parent.horizontalCenter
                    fontSize: "x-large"
                    text: i18n.tr("Pulse")
                }

                Label {
                    id: contentsLabel
                    anchors {
                        top: headerLabel.bottom
                        topMargin: units.gu(2)
                    }

                    width: parent.width
                    font.pixelSize: units.dp(17)
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    horizontalAlignment: Text.AlignHCenter
                    text: i18n.tr("The Pulse tab shows you relevent content from your project's plugins, such as issues or bugs assigned to you, the current time you've tracked today, your next event, or upcoming to dos.")
                }

                Item {
                    anchors {
                        top: contentsLabel.bottom
                        bottom: parent.bottom
                        topMargin: units.gu(2)
                    }

                    width: parent.width


                    AwesomeIcon {
                        name: "dashboard"
                        size: units.gu(9)
                        anchors.centerIn: parent
                    }
                }
            }
        },

        Component {
            Item {
                Column {
                    width: parent.width

                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Enjoy!"
                        fontSize: "x-large"
                    }
                }

                Column {
                    id: welcomeColumn
                    width: parent.width
                    anchors {
                        centerIn: parent
                    }
                    spacing: units.gu(1)

                    AwesomeIcon {
                        anchors {
                            //bottom: welcomeColumn.top
                            //bottomMargin: units.gu(2)
                            horizontalCenter: parent.horizontalCenter
                        }
                        size: units.gu(17)
                        name: "smile-o"
                    }

                    Item {
                        width: parent.width
                        height: units.gu(1)
                    }

                    Label {
                        fontSize: "large"
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                        text: colorLinks(i18n.tr("If you have questions or found a problem, please visit our project on <a href=\"https://github.com/iBeliever/project-dashboard/issues\">GitHub</a>."))
                    }
                }

                Button {
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        bottom: parent.bottom
                    }

                    height: units.gu(5)
                    width: units.gu(30)

                    text: i18n.tr("Start using Project Dashboard!")
                    color: colors["green"]
                    onTriggered: walkthrough.finished()
                }
            }
        }
    ]
}
