import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Extras.Browser 0.1

Page {
    id: webPage

    title: i18n.tr("Assembla Access")

    property string token: ""
    property string firstGet: "?access_token=" + token
    property string otherGet: "&access_token=" + token


    UbuntuWebView {
        id: webView
        //the webview is bugged, anchors.fill: parent doesn't work
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: parent.height

        property string appId: "dcsqOS5hyr44kZacwqjQXA"
        property string appSecret: "0661da1c5ffe98abcabab0644f24fd47"

        property string access_token_url: "https://" + appId + ":" + appSecret +"@api.assembla.com/token?client_id=" + appId + "&grant_type=authorization_code"

        property string redirect_uri: "http://sonrisesoftware.com/redirect"

        url: webPage.visible ? "https://api.assembla.com/authorization?client_id=" + appId + "&response_type=code" : ""
        onUrlChanged: {
            print(url)
            if (url.toString().indexOf(redirect_uri + "?code=") == 0) {
                var code = url.toString().substring(redirect_uri.length + 6);

                var xhr = new XMLHttpRequest;
                var requesting = access_token_url + "&code=" + code;
                print(requesting)
                xhr.open("POST", requesting);
                xhr.onreadystatechange = function() {
                    if (xhr.readyState === XMLHttpRequest.DONE) {
                        print(xhr.responseText)
                        var json = JSON.parse(xhr.responseText)
                        webPage.token = json.access_token
                        console.log("Oauth token is now : " + webPage.token)

                        settings.set("assemblaToken", webPage.token)
                        pageStack.pop()
                    }
                }
                xhr.send();
            }
        }

        onLoadingChanged: {
            if (loadRequest.status === WebView.LoadFailedStatus) {
                error(i18n.tr("Connection Error"), i18n.tr("Unable to authenticate to Assembla. Check your connection and/or firewall settings."), pageStack.pop)
            }
        }

    }

    UbuntuShape {
        anchors.centerIn: parent
        width: column.width + units.gu(4)
        height: column.height + units.gu(4)
        color: Qt.rgba(0.2,0.2,0.2,0.8)

        opacity: webView.loading ? 1 : 0

        Behavior on opacity {
            UbuntuNumberAnimation {
                duration: UbuntuAnimation.SlowDuration
            }
        }

        Column {
            id: column
            anchors.centerIn: parent
            spacing: units.gu(1)

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                fontSize: "large"
                text: webView.loading ? i18n.tr("Loading web page...")
                                      : i18n.tr("Success!")
            }

            ProgressBar {
                anchors.horizontalCenter: parent.horizontalCenter

                width: units.gu(30)
                maximumValue: 100
                minimumValue: 0
                value: webView.loadProgress
            }
        }
    }

    tools: ToolbarItems {
        opened: wideAspect
        locked: wideAspect

        onLockedChanged: opened = locked
    }
}
