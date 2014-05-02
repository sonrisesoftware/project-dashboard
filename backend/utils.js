.pragma library



function mergeObject(obj1,obj2){
    var obj3 = {};
    for (var attrname in obj1) { obj3[attrname] = obj1[attrname]; }
    for (var attrname in obj2) { obj3[attrname] = obj2[attrname]; }
    return obj3;
}

function mergeLists(list1, list2, prop, remove) {
    var list = JSON.parse(JSON.stringify(list1))

    for (var i = 0; i < list2.length; i++) {
        var index = findObject(list, prop, list2[i][prop])

        if (index === -1) {
            list.push(list2[i])
        } else {
            var obj = mergeObject(list[index], list2[i])
            list[index] = obj
        }
    }

    if (remove === true) {
        var j = 0
        while (j < list.length) {
            var obj = list[j]

            if (findObject(list2, prop, obj[prop]) === -1) {
                list.splice(j, 1)
            } else {
                j++
            }
        }
    }

    return list
}

function findObject(list, prop, value) {
    for (var i = 0; i < list.length; i++) {
        if (list[i][prop] === value)
            return i
    }

    return -1
}

function friendlyTime(time) {
    var now = new Date()
    var seconds = (now - new Date(time))/1000;
    //print("Difference:", now, new Date(time), now - time)
    var minutes = Math.round(seconds/60);
    if (minutes < 1)
        return "just now"
    else if (minutes == 1)
        return "1 minute ago"
    else if (minutes < 60)
        return "%1 minutes ago".arg(minutes)
    var hours = Math.round(minutes/60);
    if (hours == 1)
        return "1 hour ago"
    else if (hours < 24)
        return "%1 hours ago".arg(hours)

    var days = Math.round(hours/24);
    if (days == 1)
        return "1 day ago"
    else if (days < 7)
        return "%1 days ago".arg(days)

    var weeks = Math.round(days/7);
    if (days == 1)
        return "1 week ago"
    else if (days < 24)
        return "%1 weeks ago".arg(days)

    var months = Math.round(weeks/4);
    if (months == 1)
        return "1 month ago"
    else
        return "%1 months ago".arg(months)
}
