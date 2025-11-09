import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ToDoList extends StatelessWidget {
  final String taskName ;
  final bool whetherTaskCompleted ;
  Function(bool?)? onChanged ;
  Function(BuildContext)? deleteFunction ;
   ToDoList({
    super.key,
   required this.taskName, 
   required this. whetherTaskCompleted,
    required this.onChanged,
    required this.deleteFunction ,
    }
    );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Slidable(
        endActionPane: ActionPane(
      motion : StretchMotion(),
      children :[
       SlidableAction(onPressed : deleteFunction,
       icon : Icons.delete)
      ],
        ),
        child: Container(
          padding : EdgeInsets.all(20),
          child : Row(
            children: [
        // chackbox
            Checkbox( value: whetherTaskCompleted, onChanged: onChanged ),
        // task name 
        Text(
           taskName,
        style : TextStyle(
          decoration :whetherTaskCompleted 
         ?TextDecoration.lineThrough
         :TextDecoration.none 
          ),
        ),
            ],
          ),
          decoration : BoxDecoration(
            color : Colors.yellow,
            ),
        ),
      ),
    );
  }
}

 