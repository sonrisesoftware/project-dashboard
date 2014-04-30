import QtQuick 2.0

Item {
    id: root

    Simperium {
        id: backend
    }

    Component.onCompleted: {
        var obj = newObject("")
        print(obj)
        obj.prop = "Value"

        print(backend.changes)
    }

    function newObject(guid) {
        var obj = component.createObject(root)
        obj.guid = backend.addObject(guid, obj.toJSON())
        return obj
    }

    Component {
        id: component

        QtObject {
            property string guid
            property string prop

            onPropChanged: {
                backend.setProperty(guid, "prop", prop)
            }

            function toJSON() {
                return { "prop": prop }
            }
        }
    }
}
