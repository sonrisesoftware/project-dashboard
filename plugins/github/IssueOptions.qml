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

Column {
    width: parent.width
    ListItem.Header {
        text: i18n.tr("Labels")
    }

    Repeater {
        model: issue.labels
        delegate: ListItem.Standard {
            Label {
                anchors {
                    left: parent.left
                    leftMargin: units.gu(2)
                    verticalCenter: parent.verticalCenter
                }

                text: modelData.name
                color: "#" + modelData.color
            }
        }
    }

    ListItem.Standard {
        enabled: false
        text: i18n.tr("None yet")
        visible: issue.labels.length === 0
    }

    ListItem.Header {
        text: i18n.tr("Milestone")
    }

    ListItem.Standard {
        text: issue.milestone && issue.milestone.hasOwnProperty("number") ? issue.milestone.title : i18n.tr("No milestone")
        visible: !repository.hasPushAccess
    }

    ListItem.ItemSelector {
        model: repository.milestones.concat(i18n.tr("No milestone"))
        visible: repository.hasPushAccess
        selectedIndex: {
            if (issue.milestone && issue.milestone.hasOwnProperty("number")) {
                for (var i = 0; i < model.length; i++) {
                    if (model[i].number === issue.milestone.number)
                        return i
                }
            } else {
                return model.length - 1
            }
        }

        delegate: OptionSelectorDelegate {
            text: modelData.title
        }

        onSelectedIndexChanged: {
            var number = undefined
            if (selectedIndex < model.length - 1) {
                number = model[selectedIndex].number

                busyDialog.title = i18n.tr("Setting milestone to <b>%1</b>").arg(model[selectedIndex].title)
            } else {
                busyDialog.title = i18n.tr("Removing milestone from Issue")
            }

            if (issue.milestone && issue.milestone.hasOwnProperty("number") && issue.milestone.number === number)
                return

            if (!(issue.milestone && issue.milestone.hasOwnProperty("number")) && number === undefined)
                return

            busyDialog.show()

            request = github.editIssue(repository.repo, issue.number, {"milestone": number}, function(response) {
                busyDialog.hide()
                if (response === -1) {
                    error(i18n.tr("Connection Error"), i18n.tr("Unable to change milestone. Check your connection and/or firewall settings."))
                } else {
                    issue = issue
                    repository.reload()
                }
            })
        }
    }

    ListItem.Header {
        text: i18n.tr("Assigned To")
    }

    ListItem.Standard {
        text: issue.assignee && issue.assignee.hasOwnProperty("login") ? issue.assignee.login : i18n.tr("No one assigned")
        visible: !repository.hasPushAccess
    }

    ListItem.ItemSelector {
        model: repository.availableAssignees.concat(i18n.tr("No one assigned"))
        visible: repository.hasPushAccess
        selectedIndex: {
            if (issue.assignee && issue.assignee.hasOwnProperty("login")) {
                for (var i = 0; i < model.length; i++) {
                    if (model[i].login === issue.assignee.login)
                        return i
                }
            } else {
                return model.length - 1
            }
        }

        delegate: OptionSelectorDelegate {
            text: modelData.login
        }

        onSelectedIndexChanged: {
            var login = undefined
            if (selectedIndex < model.length - 1) {
                login = model[selectedIndex].login

                busyDialog.title = i18n.tr("Setting assignee to <b>%1</b>").arg(model[selectedIndex].login)
            } else {
                busyDialog.title = i18n.tr("Removing assignee from Issue")
            }

            if (issue.assignee && issue.assignee.hasOwnProperty("login") && issue.assignee.login === login)
                return

            if (!(issue.assignee && issue.assignee.hasOwnProperty("login")) && login === undefined)
                return

            busyDialog.show()

            request = github.editIssue(repository.repo, issue.number, {"assignee": login}, function(response) {
                busyDialog.hide()
                if (response === -1) {
                    error(i18n.tr("Connection Error"), i18n.tr("Unable to change assignee. Check your connection and/or firewall settings."))
                } else {
                    issue = issue
                    repository.reload()
                }
            })
        }
    }
}
