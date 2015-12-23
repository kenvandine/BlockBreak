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
        property bool gameBegun: false
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
        property var balls: []
        property var blocks: []
        property int nextScoreToGet: 30
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
        Rectangle
        {
            id: shadowOverlay
            anchors.fill: parent
            color: "black"
            opacity: 0.4
            visible: false
            z: 1
            Image
            {
                width: Screen.width * 50 / 320
                height: Screen.width * 50 / 320
                x: parent.width / 2 + 10
                y: parent.height / 2 - height / 2
                source: "ResumeButton.png"
                MouseArea
                {
                    anchors.fill: parent
                    onClicked: {
                        game.gameState = Bacon2D.Running;
                        shadowOverlay.visible = false;
                    }
                }
            }
            Image
            {
                width: Screen.width * 50 / 320
                height: Screen.width * 50 / 320
                x: parent.width / 2 - width - 10
                y: parent.height / 2 - height / 2
                source: "GoBackButton.png"
                MouseArea
                {
                    anchors.fill: parent
                    onClicked: {
                        shadowOverlay.visible = false;
                        gameScene.reset();
                        game.currentScene = menuScene;
                        game.gameState = Bacon2D.Running;
                        for (var j = 0; j < gameScene.balls.length; j++)
                        {
                            gameScene.balls[j].destroy();
                        }
                        gameScene.balls.splice(0, gameScene.balls.length);
                        gameScene.destroyBlocks();

                    }
                }
            }
        }
        function reset()
        {
            gameScene.score = 0;
            gameScene.nextScoreToGet = 30;
            gameOverLabel.visible = false;
            scoreLabel.visible = true;
            highScoreLabel.visible = true;
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
                    shadowOverlay.visible = true;
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
                    categories: Fixture.Category4
                    collidesWith: Fixture.Category2
                },
                Edge {
                    vertices: [
                        Qt.point(-500, height + 10),
                        Qt.point(2000, height + 10)
                    ]
                    categories: Fixture.Category4
                    collidesWith: Fixture.Category2
                    sensor: true
                    onBeginContact: {
                        var body = other.getBody();
                        gameScene.balls.splice(gameScene.balls.indexOf(body), 1);
                        body.target.destroy();
                        if (gameScene.balls.length <= 0)
                        {
                            if (gameScene.score > gameData.highscore)
                                gameData.highscore = gameScene.score;
                            gameScene.destroyBlocks();
                            gameOverLabel.visible = true;
                            scoreLabel.visible = false;
                            highScoreLabel.visible = false;
                        }
                    }
                },
                Edge {
                    vertices: [
                        Qt.point(width, height),
                        Qt.point(width, 0)
                    ]
                    categories: Fixture.Category4
                    collidesWith: Fixture.Category2
                },
                Edge {
                    vertices: [
                        Qt.point(width, 0),
                        Qt.point(0,0)
                    ]
                    categories: Fixture.Category4
                    collidesWith: Fixture.Category2
                }

            ]
        }

        Settings
        {
            id: gameData
            property int highscore: 0;
        }

        onPreSolve: {
            var targetA = contact.fixtureA.getBody().target;
            var targetB = contact.fixtureB.getBody().target;
            if (targetA.objectName === "block")
            {
                score++;
                var convert = targetA.specialFeature;
                var timer = Qt.createQmlObject("import QtQuick 2.3; Timer {}", main);
                timer.interval = 10;
                timer.repeat = false;
                timer.triggered.connect(function () {
                     reactToSpecialFeature(convert);
                });
                timer.start();
                gameScene.findAndRemoveBlock(targetA);
                targetA.destroy();

            }
            else if (targetB.objectName === "block")
            {
                score++;
                var convertB = targetA.specialFeature;
                var timerB = Qt.createQmlObject("import QtQuick 2.3; Timer {}", main);
                timerB.interval = 50;
                timerB.repeat = false;
                timerB.triggered.connect(function () {
                    reactToSpecialFeature(convertB);
                });
                timerB.start();
                gameScene.findAndRemoveBlock(targetB);
                targetB.destroy();
            }

            if (gameScene.score == gameScene.nextScoreToGet)
            {
                gameScene.nextScoreToGet += 30;
                var blockTimer = Qt.createQmlObject("import QtQuick 2.3; Timer {}", main);
                blockTimer.interval = 2000;
                blockTimer.repeat = false;
                blockTimer.triggered.connect(function () {

                        gameScene.createBlocks();
                        for (var i = 0; i < gameScene.balls.length; i++)
                        {
                            var currentX = gameScene.balls[i].linearVelocity.x;
                            var currentY = gameScene.balls[i].linearVelocity.y;
                            gameScene.balls[i].linearVelocity = Qt.point(currentX < 0 ? currentX - 3 : currentX + 3, currentY < 3 ? currentY - 3 : currentY + 3);
                        }
                })
                blockTimer.start();
            }
        }

        function reactToSpecialFeature(specialFeatureIndex)
        {
            switch(specialFeatureIndex)
            {
                case 2:
                    var aBall = ball.createObject(gameScene);
                    aBall.x = Math.floor(Math.random() * ((gameScene.width - aBall.width) - aBall.width)) + aBall.width;
                    aBall.y = gameScene.height / 2 - (aBall.height / 2);
                    gameScene.balls.push(aBall);
                    aBall.index = balls.length - 1;
                    break;
                case 3:
                    var extraBall = ball.createObject(gameScene);
                    extraBall.x = Math.floor(Math.random() * ((gameScene.width - extraBall.width) - extraBall.width)) + extraBall.width;
                    extraBall.y = gameScene.height / 2 - (extraBall.height / 2);
                    var extraBall2 = ball.createObject(gameScene);
                    extraBall2.x = Math.floor(Math.random() * ((gameScene.width - extraBall2.width) - extraBall2.width)) + extraBall2.width;
                    extraBall2.y = gameScene.height / 2 - (extraBall2.height / 2);
                    extraBall2.linearVelocity = Qt.point(-10, -10);
                    gameScene.balls.push(extraBall);
                    gameScene.balls.push(extraBall2);
                    extraBall.index = balls.length - 1;
                    break;
            }
        }

        MouseArea
        {
            onClicked: {
                if (!gameScene.gameBegun)
                {
                    var newBall = ball.createObject(gameScene);
                    newBall.x = Math.floor(Math.random() * ((gameScene.width - newBall.width) - newBall.width)) + newBall.width;
                    newBall.y = gameScene.height / 2 - (newBall.height / 2);
                    gameScene.balls.push(newBall);
                    gameScene.createBlocks();
                    gameScene.gameBegun = true;
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
           horizontalAlignment: Text.AlignHCenter
           font.pointSize: Screen.height * 75 / 568
       }

       Text
       {
           id: highScoreLabel
           text: "High: " + gameData.highscore
           anchors.top: scoreLabel.bottom
           x: parent.width / 2 - width / 2
           font.family: doodleFont.name
           verticalAlignment: Text.AlignVCenter
           font.pointSize: Screen.height * 25.0 / 568.0
       }

       Text
       {
           id: gameOverLabel
           text: "Game Over\n" + (gameScene.score >= 30 ? "You Rule" : "You Suck")
           font.family: doodleFont.name
           font.pointSize: Screen.width * 30 / 320
           width: 300
           anchors.centerIn: parent
           horizontalAlignment: Text.AlignHCenter
           verticalAlignment: Text.AlignVCenter
           visible: false

       }

       Image
       {
           id: replayButton
           source: "ReplayButton.png"
           width: Screen.height * 50 / 568
           height: Screen.height * 50 / 568
           x: parent.width / 2 - width / 2
           anchors.top: gameOverLabel.bottom
           visible: gameOverLabel.visible

           MouseArea
           {
               anchors.fill: parent
               onClicked: {
                   gameScene.destroyBlocks();
                   gameScene.reset();
                   gameScene.gameBegun = false;
               }
           }
       }

        function createBlocks()
        {
            var specialProperties = [];
            for (var k = 0; k < 30; k++)
            {
                var decider = Math.floor(Math.random() * (11 - 2) + 2);
                if (decider == 10)
                {
                    var secondDecider = Math.floor(Math.random() * (4 - 2) + 2);
                    specialProperties.push(secondDecider);
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
                    newBlock.colorIndex = i;
                    gameScene.blocks.push(newBlock);
                }
            }
        }
        function findAndRemoveBlock(blockToRemove)
        {
            for (var i = 0; i < gameScene.blocks.length; i++)
            {
                if (gameScene.blocks[i] === blockToRemove)
                {
                    gameScene.blocks.splice(i, 1);
                    break;
                }
            }
        }

        function destroyBlocks()
        {
            console.log("Destroying: " + gameScene.blocks.length);
            for (var i = 0; i < gameScene.blocks.length; i++)
            {
                gameScene.blocks[i].destroy();
                console.log(gameScene.blocks.length);
            }
            gameScene.blocks.splice(0, gameScene.blocks.length);
            console.log("Final: " + gameScene.blocks.length);
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
            text: "Block\nBreak"
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
                gameScene.gameBegun = false;
                game.currentScene = gameScene;
            }
        }


    }


}
}
