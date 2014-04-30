import QtQuick 2.0

import "diff_match_patch.js" as DiffMatchPatch

QtObject {
    property var dmp: new DiffMatchPatch.diff_match_patch()

    property var changes: []
    property var cache: { return {} }

    function addObject(parent, object) {
        var guid = createGuid()
        var change = {
            action:     "create",
            timestamp:  new Date(),
            id:         guid,
            parent:     parent,
            object:     JSON.parse(JSON.stringify(object))
        }
        print(JSON.stringify(change))
        changes.push(change)
        return guid
    }

    function deleteObject(guid) {
        var change = {
            action:     "delete",
            timestamp:  new Date(),
            id:         guid
        }
        print(JSON.stringify(change))
        changes.push(change)
    }

    function setProperty(guid, prop, value) {
        value = JSON.stringify(value)
        var patch

        if (cache[guid] && cache[guid][prop]) {
            var old = cache[guid][prop]
            patch = createPatch(value, old)
        } else {
            patch = createPatch(value, "")
        }

        var change = {
            action:     "update",
            timestamp:  new Date(),
            id:         guid,
            property:   prop,
            patch:       patch
        }
        print(JSON.stringify(change))
        changes.push(change)

        if (!cache[guid])
            cache[guid] = {}
        cache[guid][prop] = value
    }

    function createPatch(now, old) {
        return dmp.patch_make(old, now)
    }

    function createGuid() {
        var guid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
            var r = Math.random()*16|0, v = c == 'x' ? r : (r&0x3|0x8);
            return v.toString(16);
        });

        return guid
    }
}
