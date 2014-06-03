import QtQuick 2.0
import "internal" as Internal

Internal.Service {

    property string type
    property string icon
    property string title
    property bool enabled

    property string authenticationStatus

    function authenticate() {}
    function revoke() {}
}
