import QtQuick 2.0

Ticket {
    id: issue
    _type: "AssemblaTicket"

    typeRegular: issue.isPullRequest ? "merge request" : "bug"
    typeCap: issue.isPullRequest ? "Merge request" : "Bug"
    typeTitle: issue.isPullRequest ? "Merge Request" : "Bug"

    number: info.id

    open: true// info.state === 1
    assignee: info.task.assignee_link ? parent.getUser(info.task.assignee_link) : undefined

    assignedToMe: info.task.assignee_link = parent.pluginView.service.api + '/~mdspencer'

    summary: {
        var text = i18n.tr("%1 opened this issue %2").arg(issue.author.login).arg(DateUtils.friendlyTime(issue.created_at))

        return text
    }

    state: info.status === "Accepted" ? "In Progress" : info.status

    //milestone: parent.getMilestone(info.milestone_id)
    title: info.title
    tags: []//info.tags
    author: parent.getUser(info.task.owner)
    created_at: info.created_on
    body: info.description
}
