import QtQuick 2.0
import "../../udata"
import ".."

// Automatically generated from a uData model
Struct {
    id: object

    _type: "Issue"

    property var info
    onInfoChanged: _set("info", info)

    property var pull
    onPullChanged: _set("pull", pull)

    property var commits
    onCommitsChanged: _set("commits", commits)

    property var comments
    onCommentsChanged: _set("comments", comments)

    property var statusDescription
    onStatusDescriptionChanged: _set("statusDescription", statusDescription)

    property var status
    onStatusChanged: _set("status", status)

    property var events
    onEventsChanged: _set("events", events)

    onCreated: {
        _set("info", info)
        _set("pull", pull)
        _set("commits", commits)
        _set("comments", comments)
        _set("statusDescription", statusDescription)
        _set("status", status)
        _set("events", events)
        _loaded = true
        _created = true
    }

    onLoaded: {
        info = _get("info", undefined)
        pull = _get("pull", undefined)
        commits = _get("commits", undefined)
        comments = _get("comments", undefined)
        statusDescription = _get("statusDescription", undefined)
        status = _get("status", undefined)
        events = _get("events", undefined)
    }

    _properties: ["_type", "_version", "info", "pull", "commits", "comments", "statusDescription", "status", "events"]
}
