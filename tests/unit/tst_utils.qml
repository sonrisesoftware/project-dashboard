import QtQuick 2.0
import QtTest 1.0
import Ubuntu.Components 1.1
import "../../backend/utils.js" as Utils
import "../../ubuntu-ui-extras/listutils.js" as List

// See more details @ http://qt-project.org/doc/qt-5.0/qtquick/qml-testcase.html

// Execute tests with:
//   qmltestrunner

Item {
    id: root

    TestCase {
        name: "Utilities"

        function init() {
            console.debug(">> init");
            console.debug("<< init");
        }

        function cleanup() {
            console.debug(">> cleanup");
            console.debug("<< cleanup");
        }

        function initTestCase() {
            console.debug(">> initTestCase");
            console.debug("<< initTestCase");
        }

        function cleanupTestCase() {
            console.debug(">> cleanupTestCase");
            console.debug("<< cleanupTestCase");
        }

        function test_mergeObjects() {
            var obj1 = { "a": "value1", "b": "value2" }
            var obj2 = { "c": "value3" }
            var expected = { "a": "value1", "b": "value2", "c": "value3" }

            var obj = Utils.mergeObject(obj1, obj2)

            compare(List.objectKeys(obj).length, 3, "Not all the properties got merged")
            compare(JSON.stringify(obj), JSON.stringify(expected), "Objects don't match")
        }

        function test_findObject() {
            var list = [
                        {
                            "prop": "item1",
                            "value": "Item 1"
                        },

                        {
                            "prop": "2",
                            "value": "Second Item"
                        }
                    ]

            var index = Utils.findObject(list, "prop", "2")
            compare(index, 1, "Unable to find the right object")

            index = Utils.findObject(list, "", "a")
            compare(index, -1, "Shouldn't find the object because the property didn't exist")

            index = Utils.findObject(list, "prop", "lbdsfajsd")
            compare(index, -1, "Shouldn't find the object because the property value didn't exist")
        }

        function test_mergeList() {
            var expected = "This should be here!"

            var list1 = [
                        {
                            "prop": "item1",
                            "value": "Item 1"
                        },

                        {
                            "prop": "2",
                            "value": "Second Item"
                        }
                    ]

            var list2 = [
                        {
                            "prop": "item1",
                            "added": expected
                        }
                    ]

            var list = Utils.mergeLists(list1, list2, "prop")

            compare(list.length, 2, "List isn't the right length")
            compare(List.objectKeys(list[0]).length, 3, "Properties didn't get merged correctly")
            compare(List.objectKeys(list[1]).length, 2, "Properties didn't get merged correctly")
            compare(list[0].hasOwnProperty("added"), true, "Added property doesn't show up")
            compare(list[0]["added"], expected, "Added property doesn't have the right value")
        }

        function test_mergeListRemove() {
            var expected = "This should be here!"

            var list1 = [
                        {
                            "prop": "item1",
                            "value": "Item 1"
                        },

                        {
                            "prop": "2",
                            "value": "Second Item"
                        }
                    ]

            var list2 = [
                        {
                            "prop": "item1",
                            "added": expected
                        }
                    ]

            var list = Utils.mergeLists(list1, list2, "prop", true)

            compare(list.length, 1, "List isn't the right length")
            compare(List.objectKeys(list[0]).length, 3, "Properties didn't get merged correctly")
            compare(list[0].hasOwnProperty("added"), true, "Added property doesn't show up")
            compare(list[0]["added"], expected, "Added property doesn't have the right value")
        }
    }
}
