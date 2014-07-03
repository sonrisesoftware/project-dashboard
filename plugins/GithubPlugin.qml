import QtQuick 2.0
import "../model"

PluginView {

    type: "GitHub"
    title: i18n.tr("GitHub")
    icon: "github"

    service: GitHub {
        _db: storage
    }
}
