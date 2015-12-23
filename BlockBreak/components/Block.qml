import QtQuick 2.0
import Bacon2D 1.0
import QtQuick.Window 2.0
import Ubuntu.Components 1.3

Component
{
    id: blockComponent
    PhysicsEntity {
        id: collisionEntity
        width: (Screen.width / 6) - 5
        height: units.gu(8)
        bodyType: Body.Static
        objectName: "block"
        property int specialFeature: 0
        function startAnim() {
            this.destroy();
        }

        property int colorIndex: 0
        fixtures: Box {
            x: 0
            y: 0
            width: target.width
            height: target.height
            categories: Fixture.Category1
            collidesWith: Fixture.Category2
       }

       property var colors: [
            Qt.rgba(202/255, 1, 1),
            Qt.rgba(99/255, 185/255, 1),
            Qt.rgba(224/255, 102/255, 1),
            Qt.rgba(178/255, 58/255, 238/255),
            Qt.rgba(75/255, 0, 130/255)
        ]

        Rectangle {
            id: visiblePart
            anchors.fill: parent
            color: colors[colorIndex]

            Behavior on width {
                NumberAnimation {
                    duration: 400
                }
            }
        }
    }
}

