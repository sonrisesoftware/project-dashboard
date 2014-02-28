import QtQuick 2.0
import Ubuntu.Components 0.1
import QtWebKit 3.0

Page {
    id: webPage

    title: i18n.tr("GitHub Access")

    property string token: ""
    property string firstGet: "?access_token=" + token
    property string otherGet: "&access_token=" + token


    WebView {
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

        url: webPage.visible ? "https://github.com/login/oauth/authorize" +
                               "?client_id=" + client_id +
                               "&scope=" + scope +
                               "&redirect_uri=" + encodeURIComponent(redirect_uri) : ""
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

                        settings.set("githubToken", xhr.responseText.substring(13, 53))
                        pageStack.pop()
                    }
                }
                xhr.send();
            }
        }

        onLoadingChanged: {
            if (loadRequest.status === WebView.LoadFailedStatus) {
                error(i18n.tr("Connection Error"), i18n.tr("Unable to authenticate to GitHub. Check your connection and/or firewall settings."), pageStack.pop)
            }
        }

    }

    Column {
        id: column
        anchors.centerIn: parent
        visible: webView.loading
        spacing: units.gu(1)

        ActivityIndicator {
            running: column.visible
            implicitHeight: units.gu(5)
            implicitWidth: implicitHeight
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            fontSize: "large"
            text: i18n.tr("Loading (%1%)").arg(webView.loadProgress)
        }
    }

    tools: ToolbarItems {
        opened: wideAspect
        locked: wideAspect

        onLockedChanged: opened = locked
    }
}
