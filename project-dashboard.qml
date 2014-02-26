import QtQuick 2.0
import Ubuntu.Components 0.1
import "components"
import "ui"
import "backend"
import "ubuntu-ui-extras"

/*!
    \brief MainView with a Label and Button elements.
*/

MainView {
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "com.ubuntu.developer.mdspencer.project-dashboard"

    /*
     This property enables the application to change orientation
     when the device is rotated. The default is false.
    */
    automaticOrientation: true

    backgroundColor: Qt.rgba(0.3,0.3,0.3,1)

    width: units.gu(50)
    height: units.gu(75)

    property bool wideAspect: width > units.gu(80)
    property alias pageStack: pageStack

    PageStack {
        id: pageStack

        ProjectsPage {
            id: projectsPage
            visible: false
        }

        Component.onCompleted: pageStack.push(projectsPage)
    }

    Backend {
        id: backend
    }

    Database {
        id: db
        path: "project-dashboard.db"
    }

    function getIcon(name) {
        var root = "icons/"
        var ext = ".png"

        //return "image://theme/" + name

        if (name.indexOf(".") === -1)
            name = root + name + ext
        else
            name = root + name

        return Qt.resolvedUrl(name)
    }
}
