


 import 'package:flutter/material.dart';
import 'package:todoapp/pages/mybuttons.dart';

class Dialogbox  extends StatelessWidget {
  final controller ;

VoidCallback onSave;
VoidCallback onCancel;


   Dialogbox (
    {super.key,
   required this.controller ,
   required this.onSave,
   required this.onCancel,

   });

  @override
  Widget build(BuildContext context) {
    return AlertDialog (
    backgroundColor : Colors.yellow [300] ,
      content : Container (
        height : 120 ,
        child : Column(children : [
          TextField(

            controller: controller  ,
            decoration : InputDecoration (border : OutlineInputBorder(),
            hintText: "add a new item to the list  ",
            )
          ), 

          // buttons 
          Row( children :[
            // save a new item button 
          MyButton(text:"save new item", onPressed: onSave),


            //diappear box button  
          MyButton(text: "dissapear box", onPressed:onCancel ),


          ] )
        ])
      ) 
    
    );
  }
} 