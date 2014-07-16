import QtQuick 2.0
import "../../udata"
import ".."

// Automatically generated from a uData model
Plugin {
    id: object

    _type: "CodePlugin"

    property var milestones: []
    onMilestonesChanged: _set("milestones", milestones)

    property string componentFunction
    onComponentFunctionChanged: _set("componentFunction", componentFunction)

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
        _set("componentFunction", componentFunction)
        _set("name", name)
        _set("usersInfo", usersInfo)
        _set("availableAssignees", availableAssignees)
        _set("showClosedTickets", showClosedTickets)
        _loaded = true
        _created = true
    }

    onLoaded: {
        milestones = _get("milestones", [])
        componentFunction = _get("componentFunction", "")
        name = _get("name", "")
        usersInfo = _get("usersInfo", {})
        availableAssignees = _get("availableAssignees", [])
        showClosedTickets = _get("showClosedTickets", false)
        issues.load()
    }

    _properties: ["_type", "_version", "milestones", "componentFunction", "name", "usersInfo", "availableAssignees", "showClosedTickets", "issues"]
}
