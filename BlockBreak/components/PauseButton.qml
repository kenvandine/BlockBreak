import QtQuick 2.3
import Bacon2D 1.0
import Ubuntu.Components 1.1

Item
{
   width: units.gu(8)
   height: width

   Rectangle
   {
       id: left
       width: parent.width * 0.45
       height: parent.height
       color: "black"
       x:0
       y:0
   }
   Rectangle
   {
       id: right
       width: parent.width * 0.45
       height: parent.height
       color: "black"
       x: parent.width - width
       y: 0
   }

}
