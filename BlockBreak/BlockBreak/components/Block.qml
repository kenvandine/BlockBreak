import QtQuick 2.0
import Bacon2D 1.0
import QtQuick.Window 2.0

Component
{
    id: blockComponent
    PhysicsEntity
    {
        id: collisionEntity
        width: (Screen.width / 6) - 5
        height: 25 + 8
        bodyType: Body.Static
        objectName: "block"
        property int specialFeature: 0
        function startAnim()
        {
            this.destroy();
        }

        property int colorIndex: 0
        fixtures: Box{
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

        Rectangle
        {
            id: visiblePart
            anchors.fill: parent
            color: colors[colorIndex]

            Behavior on width
            {
                NumberAnimation
                {
                    duration: 400
                }
            }
        }

        /*Canvas
        {
             id: canvas
             anchors.fill: parent
             onPaint:
             {
                 var ctx = canvas.getContext("2d");
                 ctx.lineWidth = 2;
                 ctx.strokeStyle="black";
                 ctx.beginPath();
                 ctx.moveTo(0,0);
                 ctx.lineTo(0, parent.height);
                 ctx.lineTo(parent.width, parent.height);
                 ctx.lineTo(parent.width, 0);
                 ctx.lineTo(0,0);

                 ctx.stroke();
                 ctx.fillStyle = colors[colorIndex];
                 ctx.fill();
                 ctx.closePath();
             }
        }*/




    }
}

