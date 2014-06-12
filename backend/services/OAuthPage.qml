import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.Extras.Browser 0.2

Page {
    id: webPage

    title: i18n.tr("GitHub Access")

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

//        zoomTo:

        property string client_id: "f910590f581ce189054e"
        property string scope: "user,repo,notifications,gist"
        property string client_secret: "7fc73d198c946e7b36fab045efa4b191d1f2c28d"
        // the redirect_uri can be any site
        property string redirect_uri: "https://api.github.com/zen"
        property string access_token_url: "https://github.com/login/oauth/access_token" +
                                      "?client_secret=" + client_secret +
                                      "&client_id=" + client_id

        url: "https://github.com/login/oauth/authorize" +
                               "?client_id=" + client_id +
                               "&scope=" + scope +
                               "&redirect_uri=" + encodeURIComponent(redirect_uri)
        onUrlChanged: {
            if (url.toString().substring(0, 32) === redirect_uri + "?code=") {
                var code = url.toString().substring(32);

                var xhr = new XMLHttpRequest;
                var requesting = access_token_url + "&code=" + code;
                xhr.open("POST", requesting);
                xhr.onreadystatechange = function() {
                    if (xhr.readyState === XMLHttpRequest.DONE) {
                        webPage.token = xhr.responseText.substring(13, 53)
                        console.log("Oauth token is now : " + webPage.token)

                        github.oauthToken = xhr.responseText.substring(13, 53)
                        pageStack.pop()
                    }
                }
                xhr.send();
            }
        }

        onLoadingChanged: {
            if (webView.lastLoadFailed) {
                error(i18n.tr("Connection Error"), i18n.tr("Unable to authenticate to GitHub. Check your connection and/or firewall settings."), pageStack.pop)
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
