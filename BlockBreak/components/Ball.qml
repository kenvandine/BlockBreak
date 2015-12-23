import QtQuick 2.0
import Bacon2D 1.0
import QtQuick.Window 2.0

Component {
    PhysicsEntity {
        id: ballEntity
        width: units.gu(5)
        height: width
        sleepingAllowed: false
        bodyType: Body.Dynamic

        linearVelocity: Qt.point(10, 10)
        fixtures: Circle {
            radius: target.width / 2
            density: 1
            friction: 0.0
            restitution: 1.0
            categories: Fixture.Category2
            collidesWith: Fixture.Category1 | Fixture.Category3 | Fixture.Category4
        }

        Rectangle {
            id: visible
            radius: parent.width / 2
            anchors.fill: parent
            color: "red"
        }
    }
}
