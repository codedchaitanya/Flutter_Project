


 import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text ;
  VoidCallback  onPressed ;
  MyButton ({
    super.key,
    required this.text ,
    required this.onPressed ,
    
    
    });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: MaterialButton (
        onPressed : onPressed , 
       color: Colors. red [500] ,
        child : Text(text),
      
      ),
    );
  }
}





