import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import "../ubuntu-ui-extras"

Object {
    id: root

    property alias projects: doc.children

    property alias document: doc

    Document {
        id: doc
        docId: 0
        parent: db.document
        name: "backend storage"
    }

    function newProject(name) {
        doc.newDoc({"name": name})
    }
}
