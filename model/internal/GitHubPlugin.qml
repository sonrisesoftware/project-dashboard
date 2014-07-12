import QtQuick 2.0
import "../../udata"
import ".."

// Automatically generated from a uData model
Plugin {
    id: object

    _type: "GitHubPlugin"

    property var repo
    onRepoChanged: _set("repo", repo)

    property var milestones: []
    onMilestonesChanged: _set("milestones", milestones)

    property string name
    onNameChanged: _set("name", name)

    property var availableAssignees: []
    onAvailableAssigneesChanged: _set("availableAssignees", availableAssignees)

    property bool showClosedTickets: false
    onShowClosedTicketsChanged: _set("showClosedTickets", showClosedTickets)

    property DocumentListModel issues: DocumentListModel {
        type: "issues"
    }

    property var cacheInfo: {}
    onCacheInfoChanged: _set("cacheInfo", cacheInfo)

    onCreated: {
        _set("repo", repo)
        _set("milestones", milestones)
        _set("name", name)
        _set("availableAssignees", availableAssignees)
        _set("showClosedTickets", showClosedTickets)
        _set("cacheInfo", cacheInfo)
        _loaded = true
        _created = true
    }

    onLoaded: {
        repo = _get("repo", undefined)
        milestones = _get("milestones", [])
        name = _get("name", "")
        availableAssignees = _get("availableAssignees", [])
        showClosedTickets = _get("showClosedTickets", false)
        issues.load()
        cacheInfo = _get("cacheInfo", {})
    }

    _properties: ["_type", "_version", "repo", "milestones", "name", "availableAssignees", "showClosedTickets", "issues", "cacheInfo"]
}
