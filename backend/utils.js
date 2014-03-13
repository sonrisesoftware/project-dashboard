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
