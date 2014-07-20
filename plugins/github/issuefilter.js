WorkerScript.onMessage = function(message) {
    var id = message.id
    var filter = message.filter
    var model = message.model

    var issues = {}
    var allIssues = []
    var everyonesIssues = 0
    var assignedIssues = 0

    for (var i = 0; i < model.count; i++) {
        print('Filtering', i)
        var issue = model.get(i).modelData
        var column = issue.get(filter.group)

        if (!column)
            column = filter['default']

        if (!issue.matches(filter.filter))
            continue

        if (issue.open && !issue.isPullRequest) {
            allIssues.push(issue)
            everyonesIssues++

            if (issue.assignedToMe)
                assignedIssues++
        }

        if (column) {
            if (!issues[column])
                issues[column] = []
            issues[column].push(issue)
        }
    }

    for (column in issues) {
        if (issues[column])
            issues[column].sort(function(a,b) { return b.number - a.number })
    }

    var list = List.objectKeys(issues)
    list.sort(function (b, a) {
        if (filter.columns.indexOf(a) !== -1 && filter.columns.indexOf(b) !== -1)
            return filter.columns.indexOf(b) - filter.columns.indexOf(a)
        else if (filter.columns.indexOf(a) !== -1)
            return 1
        else if (filter.columns.indexOf(b) !== -1)
            return -1
        else
            return 0
    })

    WorkerScript.sendMessage({
                                 id: id,
                                 columns: list,
                                 groupedIssues: issues
                             })
}
