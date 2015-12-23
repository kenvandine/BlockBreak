import QtQuick 2.3
import Bacon2D 1.0

Item
{
   width: 30
   height: 30

   Rectangle
   {
       id: left
       width: 13
       height: 30
       color: "black"
       x:0
       y:0
   }
   Rectangle
   {
       id: right
       width: 13
       height: 30
       color: "black"
       x: parent.width - width
       y: 0
   }

}
