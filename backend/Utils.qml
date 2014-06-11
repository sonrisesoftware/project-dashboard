import QtQuick 2.0

QtObject {
    function getIcon(name) {
        var mainView = "icons/"
        var ext = ".png"

        //return "image://theme/" + name

        if (name.indexOf(".") === -1)
            name = mainView + name + ext
        else
            name = mainView + name

        return Qt.resolvedUrl(name)
    }

    function colorLinks(text) {
        return text.replace(/<a(.*?)>(.*?)</g, "<a $1><font color=\"" + colors["blue"] + "\">$2</font><")
    }

    function newObject(type, args, parent) {
        if (!args)
            args = {}
        if (!parent)
            parent = mainView

        var component = Qt.createComponent(type);
        if (component.status == Component.Error) {
            // Error Handling
            console.log("Error loading component:", component.errorString());
        }

        return component.createObject(parent, args);
    }
}
