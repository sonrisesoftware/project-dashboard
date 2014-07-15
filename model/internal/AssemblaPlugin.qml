import QtQuick 2.0
import "../../udata"
import ".."

// Automatically generated from a uData model
Plugin {
    id: object

    _type: "AssemblaPlugin"

    property var milestones: []
    onMilestonesChanged: _set("milestones", milestones)

    property string name
    onNameChanged: _set("name", name)

    property var usersInfo: {}
    onUsersInfoChanged: _set("usersInfo", usersInfo)

    property var availableAssignees: []
    onAvailableAssigneesChanged: _set("availableAssignees", availableAssignees)

    property bool showClosedTickets: false
    onShowClosedTicketsChanged: _set("showClosedTickets", showClosedTickets)

    property DocumentListModel issues: DocumentListModel {
        type: "issues"
    }

    onCreated: {
        _set("milestones", milestones)
        _set("name", name)
        _set("usersInfo", usersInfo)
        _set("availableAssignees", availableAssignees)
        _set("showClosedTickets", showClosedTickets)
        _loaded = true
        _created = true
    }

    onLoaded: {
        milestones = _get("milestones", [])
        name = _get("name", "")
        usersInfo = _get("usersInfo", {})
        availableAssignees = _get("availableAssignees", [])
        showClosedTickets = _get("showClosedTickets", false)
        issues.load()
    }

    _properties: ["_type", "_version", "milestones", "name", "usersInfo", "availableAssignees", "showClosedTickets", "issues"]
}
