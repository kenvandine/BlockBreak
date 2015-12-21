import QtQuick 2.3
import QtQuick.Window 2.0
import Bacon2D 1.0
import Ubuntu.Components 1.1
import "components"

MainView
{
    id: main
    width: Screen.width
    height: Screen.height
    useDeprecatedToolbar: false
Game
{
    id: game
    anchors.fill: parent
    anchors.centerIn: parent
    gameName: "com.ubuntu.developer.xcub.breakout" //Reverse DNS formate, not mandatory

    currentScene: menuScene

    Image
    {
        anchors.fill: parent
        source: "grid.png"
        fillMode: Image.Tile
    }

    FontLoader
    {
        id: doodleFont
        source: "PIJAMAS_.ttf"
    }

    Scene
    {
        id: gameScene
        anchors.fill: parent
        y: -gameScene.height
        property bool gameBegun: true
        enterAnimation: NumberAnimation {
            target: gameScene
            property: "opacity"
            from: 0
            to: 1
            duration: 500
        }
        exitAnimation: NumberAnimation {
            target: gameScene
            property: "opacity"
            from: 1
            to: 0
        }
        physics: true
        gravity: Qt.point(0,0) //disable gravity by applying zero force in both the x and y directions
        property int score: 0
        Paddle //An element from another file
        {
            id: paddle
            x: (parent.width / 2) - (width / 2) // intially placed at center
            y: parent.height - height // placed just above the end of the screen
        }
        Ball //An element from another file
        {
            id: ball
        }
        Block
        {
            id: block
        }
        PauseButton
        {
            id: pauseButton
            x: parent.width - (width + 5)
            y: 5
            z: 1
            MouseArea
            {
                anchors.fill: parent
                onClicked: {
                    game.gameState = Bacon2D.Paused;
                }
            }
        }

        PhysicsEntity
        {
            id: border
            width: parent.width
            height: parent.height
            bodyType: Body.Static
            fixtures: [
                Edge {
                    vertices: [
                        Qt.point(0,0),
                        Qt.point(0, height)
                    ]
                },
                Edge {
                    vertices: [
                        Qt.point(-500, height),
                        Qt.point(2000, height)
                    ]
                    sensor: true
                    onBeginContact: {
                        var body = other.getBody();
                        body.target.destroy();
                        gameOverLabel.visible = true;
                        scoreLabel.visible = false;
                    }
                },
                Edge {
                    vertices: [
                        Qt.point(width, height),
                        Qt.point(width, 0)
                    ]
                },
                Edge {
                    vertices: [
                        Qt.point(width, 0),
                        Qt.point(0,0)
                    ]
                }

            ]
        }

        onPreSolve: {
            var targetA = contact.fixtureA.getBody().target;
            var targetB = contact.fixtureB.getBody().target;
            var block;
            if (targetA.objectName === "block")
            {
                score++;
                gameScene.reactToSpecialFeature(targetA.specialFeature)
                targetA.startAnim();

            }
            else if (targetB.objectName === "block")
            {
                score++;
                gameScene.reactToSpecialFeature(targetB.specialFeature);
                targetB.startAnim();
            }
        }

        function reactToSpecialFeature(featureIndex)
        {
            switch(featureIndex)
            {
                case 2:
                    if (ball.status == Component.Ready)
                    {
                        console.log("LOL");
                        var aBall = ball.createObject(gameScene);
                        aBall.x = Math.floor(Math.random() * ((gameScene.width - aBall.width) - aBall.width)) + aBall.width;
                        aBall.y = gameScene.height / 2 - (aBall.height / 2);
                    }
                    break;
                case 3:
                    if (ball.status == Component.Ready)
                    {
                        console.log("LOL");
                        var extraBall = ball.createObject(gameScene);
                        extraBall.x = Math.floor(Math.random() * ((gameScene.width - extraBall.width) - extraBall.width)) + extraBall.width;
                        extraBall.y = gameScene.height / 2 - (extraBall.height / 2);
                        var extraBall2 = ball.createObject(gameScene);
                        extraBall2.x = Math.floor(Math.random() * ((gameScene.width - extraBall2.width) - extraBall2.width)) + extraBall2.width;
                        extraBall2.y = gameScene.height / 2 - (extraBall2.height / 2);
                        extraBall2.linearVelocity = Qt.point(-10, -10);
                        console.log("FFF");
                    }
                    break;
                default:
                    console.log("four");
            }
        }

        MouseArea
        {
            onClicked: {
                if (gameScene.gameBegun)
                {
                    var newBall = ball.createObject(gameScene);
                    newBall.x = Math.floor(Math.random() * ((gameScene.width - newBall.width) - newBall.width)) + newBall.width;
                    newBall.y = gameScene.height / 2 - (newBall.height / 2);
                    gameScene.createBlocks();
                    gameScene.gameBegun = false;
                }
            }
            anchors.fill: parent
            drag.axis: Drag.XAxis
            drag.minimumX: 0
            drag.maximumX: parent.width - paddle.width
            drag.target: paddle
        }

       Text
       {
           id: scoreLabel
           text: gameScene.score
           anchors.centerIn: parent
           font.family: doodleFont.name
           verticalAlignment: Text.AlignVCenter
           style: Text.Raised
           horizontalAlignment: Text.AlignHCenter
           font.pointSize: 75
       }

       Text
       {
           id: gameOverLabel
           text: "Game Over\n" + (gameScene.score === 30 ? "You Rule" : "You Suck")
           font.family: doodleFont.name
           font.pointSize: Screen.width * 30 / 320
           width: 300
           anchors.centerIn: parent
           horizontalAlignment: Text.AlignHCenter
           verticalAlignment: Text.AlignVCenter
           visible: false

       }

        function createBlocks()
        {
            var specialProperties = [];
            for (var k = 0; k < 30; k++)
            {
                var decider = Math.floor(Math.random() * (10 - 2) + 2);
                console.log("decider: " + decider);
                if (decider >= 9)
                {
                    var secondDecider = Math.floor(Math.random() * (4 - 2) + 2);
                    specialProperties.push(secondDecider);
                    console.log("second: " + secondDecider);
                }
                else
                    specialProperties.push(0);
            }

            for (var i = 0; i < 5; i++)
            {
                for (var j = 0; j < 6; j++)
                {
                    var newBlock = block.createObject(gameScene);
                    newBlock.x = (newBlock.width * j) + (1 * j);
                    newBlock.y = (newBlock.height * i) + (1 * i);
                    newBlock.specialFeature = specialProperties[((j + 1) * (i + 1)) - 1];
                    console.log(newBlock.specialFeature);
                    newBlock.colorIndex = i;
                }
            }
        }
    }

    Scene
    {
        id: menuScene
        anchors.fill: parent
        physics: false
        exitAnimation: NumberAnimation {
            target: menuScene
            property: "opacity"
            from: 1
            to: 0
            duration: 500
        }
        enterAnimation: NumberAnimation {
            target: menuScene
            property: "opacity"
            from: 0
            to: 1
            duration: 500
        }

        Text
        {
            id: title
            text: "Block\nBreaker"
            font.family: doodleFont.name
            font.italic: true
            color: "grey"
            style: Text.Raised
            font.pointSize: Screen.width * 60 / 320
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            x: parent.width / 2 - width / 2
            y: parent.height * 2/5 - height / 2

        }

        Entity
        {
            id: playMessage
            x: parent.width / 2 - width
            y: title.y + title.height + 10
            updateInterval: 300
            behavior: ScriptBehavior {
                script: {
                    visibleMessage.visible = !visibleMessage.visible
                }
            }

            Text
            {
                id: visibleMessage
                anchors.fill: parent
                text: "Tap Anywhere to Start"
                font.pointSize: Screen.width * 10 / 320
                font.family: doodleFont.name
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: "cyan"
            }
        }

        MouseArea
        {
            anchors.fill: parent
            onClicked: {
                game.currentScene = gameScene;
            }
        }


    }


}
}
