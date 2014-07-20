import QtQuick 2.0
import "../model"

import "github"

PluginView {
    id: launchpadPlugin

    type: "Launchpad"
    title: i18n.tr("Launchpad")
    icon: "empire"
    genericIcon: "code"
    genericTitle: i18n.tr("Code")

    property var user: service.user

    service: Launchpad {
        _db: storage
    }

    items: [
        PluginItem {
            id: issuesItem

            title: i18n.tr("Bugs")
            icon: "bug"

            pulseItem: IssuesPulseItem {
                title: i18n.tr("Assigned Bugs")
                type: "bugs"
            }

            page: PlannerView {}
        }
    ]
}
