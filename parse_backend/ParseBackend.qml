import QtQuick 2.0
import "../qml-air"
import "../parse"
import "../backend"
import "../api_keys.js" as ApiKeys

Object {
    id: parseBackend

    property string sessionToken
    property string userId

    property Account account: Account {
        id: account
    }

    function toJSON() {
        return {
            "signedIn": account.signedIn,
            "sessionToken": sessionToken,
            "userId": userId,
            "fullname": account.name,
            "email": account.email
        }
    }

    function fromJSON(json) {
        print(JSON.stringify(json))
        sessionToken = json.sessionToken
        account.signedIn = true
        account.name = json.fullname
        account.email = json.email
        userId = json.userId
    }

    Parse {
        id: parse

        appId: ApiKeys.appId
        apiKey: ApiKeys.apiKey
    }

    function logIn(userId, password) {
        parse.login(userId, password, function(has_error, status, response) {
            if (status === 200) {
                login.close()
                login.loggingIn = false

                var json = JSON.parse(response)
                sessionToken = json.sessionToken
                account.signedIn = true
                account.name = json.fullname
                account.email = json.email
                userId = json.username
                notification.show("Login successful")
            } else {
                login.loggingIn = false
                login.error = true
            }
        })
    }

    function logout() {
        account.signedIn = false
    }

    function showLoginDialog() {
        login.open()
    }

    LoginDialog {
        id: login

        title: "Project Dashboard"

        onLogin: {
            login.loggingIn = true
            logIn(userId, password)
        }
    }
}
