import QtQuick 2.0
import "internal" as Internal

Internal.Service {

    property string description
    property bool enabled

    property string authenticationStatus

    property Component accountItem

    function authenticate() {}
    function revoke() {}

    function createProject() {}
}
