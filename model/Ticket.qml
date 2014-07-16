import QtQuick 2.0
import "internal" as Internal

Internal.Ticket {
    id: issue

    property int number
    property string title
    property bool open
    property string state // One of "New", "In Progress", "Test", "Invalid" or "Fixed"
    property var assignee
    property var milestone
    property var tags
    property var author
    property var created_at
    property string body
    property bool isPullRequest: false
    property string component: parent.getComponent(issue)

    property string summary: {
        var text = i18n.tr("%1 opened this issue %2").arg(issue.author.login).arg(DateUtils.friendlyTime(issue.created_at))
        return text
    }

    property string type: typeRegular
    property string typeRegular: issue.isPullRequest ? "pull request" : "issue"
    property string typeCap: issue.isPullRequest ? "Pull request" : "Issue"
    property string typeTitle: issue.isPullRequest ? "Pull Request" : "Issue"

    property bool ready

    property bool assignedToMe: {
        var result = issue.assignee && issue.assignee.login && issue.assignee.login === issue.parent.pluginView.service.user.login
        if (result === undefined)
            return false
        else
            return result
    }

    property bool hasAssignee: {
        var result = issue.assignee && issue.assignee.login
        if (result === undefined)
            return false
        else
            return result
    }

    property bool hasMilestone: {
        var result = issue.milestone && issue.milestone.title
        if (result === undefined)
            return false
        else
            return result
    }

    function renderBody() {
        return renderMarkdown(body)
    }

    property var allEvents: []

    onLoaded: {
        refresh()
        parent.nextNumber = Math.max(parent.nextNumber, issue.number + 1)
    }

    onCreated: {
        refresh()
        parent.nextNumber = Math.max(parent.nextNumber, issue.number + 1)
    }

    function refresh() {
    }

    function load() {
        ready = true
    }

    function matches(filter) {
        for (var prop in filter) {
            var value = get(prop)
            var item = filter[prop]
            var matches = false
            print('Testing', prop, value, '??', item, typeof(value), typeof(item))

            if (typeof(value) == 'boolean') {
                matches = value ? item == "true" : item == "false"
                print(value, '==', item, matches)
            } else if (typeof(item) == 'string') {
                matches = value !== undefined && value.match(new RegExp(item, "i"))
                print(value, '==', item, matches)
            } else if (item instanceof Array) {
                item.forEach(function (subItem) {
                    matches = matches || (value !== undefined && value.match(new RegExp(subItem, "i")))
                    print(value, '==', item, matches)
                })
            }

            if (!matches) return false
        }

        return true
    }

    function get(prop) {
        if (prop.indexOf('.') === -1) {
            return issue[prop]
        } else {
            var items = prop.split('.')
            var obj = issue
            for (var i = 0; i < items.length; i++) {
                obj = obj[items[i]]
                if (obj === undefined)
                    return obj
            }

            return obj
        }
    }
}
