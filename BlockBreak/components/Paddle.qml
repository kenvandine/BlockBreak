import QtQuick 2.0
import Bacon2D 1.0
import QtQuick.Window 2.0
import Ubuntu.Components 1.1

PhysicsEntity
{
    id: paddleEntity
    width: Screen.width * 60 / 320
    height: 30
    bodyType: Body.Static
    sleepingAllowed: false
    property bool isBlock: false
    fixtures: Box {
       x: 0
       y: 0
       width: target.width
       height: target.height
       categories: Fixture.Category3
       collidesWith: Fixture.Category2
    }

    Image {
        id: paddleImage
        anchors.fill: parent
        source: "../Paddle.png"
    }
}


