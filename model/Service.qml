import QtQuick 2.0
import "internal" as Internal

Internal.Service {

    property string type
    property string icon
    property string title
    property string description
    property bool enabled

    property string authenticationStatus

    property Component accountItem

    function authenticate() {}
    function revoke() {}

    function createProject() {}
}
