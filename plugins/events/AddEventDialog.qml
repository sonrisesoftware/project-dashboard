import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.Components.Pickers 1.0 as Picker
import "../../ubuntu-ui-extras"
import "../../model"

Dialog {
    id: dialog

    property EventsPlugin plugin

    title: i18n.tr("Add Event")
    text: i18n.tr("Enter title and date of your event:")

    TextField {
        id: titleField

        placeholderText: i18n.tr("Title")

        onAccepted: okButton.click()
        style: DialogTextFieldStyle {}
    }

    Picker.DatePicker {
        id: datePicker
        width: parent.width
        date: new Date()
        style: SuruDatePickerStyle {}
    }

    Item {
        width: parent.width
        height: childrenRect.height

        Button {
            objectName: "cancelButton"
            text: i18n.tr("Cancel")
            anchors {
                left: parent.left
                right: parent.horizontalCenter
                rightMargin: units.gu(1)
            }

            color: "gray"

            onClicked: {
                PopupUtils.close(dialog)
            }
        }

        Button {
            id: okButton
            objectName: "okButton"
            anchors {
                left: parent.horizontalCenter
                right: parent.right
                leftMargin: units.gu(1)
            }

            text: i18n.tr("Ok")
            enabled: titleField.text !== ""

            onClicked: {
                PopupUtils.close(dialog)
                plugin.addEvent(titleField.text, datePicker.date)
            }
        }
    }
}
