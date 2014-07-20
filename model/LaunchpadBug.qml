import QtQuick 2.0
import "../qml-extras/dateutils.js" as DateUtils

Ticket {
    id: issue
    _type: "LaunchpadBug"

    typeRegular: issue.isPullRequest ? "merge request" : "bug"
    typeCap: issue.isPullRequest ? "Merge request" : "Bug"
    typeTitle: issue.isPullRequest ? "Merge Request" : "Bug"
    commentCount: info.message_count - 1

    number: info.id

    open: true// info.state === 1
    assignee: info.task.assignee_link ? parent.getUser(info.task.assignee_link) : undefined

    assignedToMe: assignee !== undefined && assignee.login == 'mdspencer'

    state: info.task.status === 'Fix Committed' ? 'Test' : info.task.status === 'Fix Released' ? 'Fixed' : info.task.status

    //milestone: parent.getMilestone(info.milestone_id)
    title: info.title
    tags: []//info.tags
    author: parent.getUser(info.task.owner_link)
    created_at: info.task.date_created
    body: info.description
}
