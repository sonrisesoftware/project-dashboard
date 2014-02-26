import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import "../ubuntu-ui-extras"

Object {
    id: project

    property int docId: -1

    property string name: doc.get("name", "")
    onNameChanged: name = doc.sync("name", name)

    property alias plugins: doc.children

    property alias document: doc

    Document {
        id: doc
        docId: project.docId
        parent: backend.document
    }

    function newPlugin() {doc.newDoc({"name": "TEst"})}
}
