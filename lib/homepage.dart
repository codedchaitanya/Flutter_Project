import 'package:flutter/material.dart';
//import 'package:todoapp/pages/todolist.dart';
import 'pages/todolist.dart';
import 'pages/dialogbox.dart' ;
import 'pages/mybuttons.dart' ;

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
// text controller 
 final _controller = TextEditingController();

List toDoList = [
  ["make an app ", false ],
  ["study for midsem", true ],
];

// delete a task 
 void deleteTask(int index){
        setState(() {
          toDoList.removeAt(index);
        });
      }


// checkbox was clicked 
void checkBoxChanged(bool? value , int index ){
  setState ( (){
   toDoList[index] [1] = !toDoList [index][1];
  }
  );
}

// save a new task 
void saveNewTask(){
  setState((){
   toDoList.add([_controller.text , false]) ;
   _controller.clear();
  }
  );
}

// create a new task 
void createNewTask (){
showDialog(
  context: context, 
  builder: (context){
    return Dialogbox( 
      controller :_controller  ,
      onSave : saveNewTask,// for this one we need to create a new method 
      onCancel: ()=> Navigator.of(context).pop(),
      //this closes the dialogbox
    );
  },
  ) ; 
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Colors.cyan,
       appBar : AppBar(
        backgroundColor: Colors.red,
       ),
      // creates a plus signed icon 
      floatingActionButton: FloatingActionButton(
         onPressed: createNewTask ,
         child : Icon(Icons.add),
         ),

      //delete task
       body : ListView.builder(
         itemCount : toDoList.length ,
        itemBuilder : (context , index ){
          return ToDoList(
          taskName: toDoList [index][0] , 
          whetherTaskCompleted:toDoList [index][1],
          onChanged : (value) => checkBoxChanged (value , index ),
          deleteFunction : (context) => deleteTask(index),
          );
        }
         
       ), 
    );
  }
}
