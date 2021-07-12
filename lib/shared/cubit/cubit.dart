import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/archived_tasks_screen.dart';
import 'package:todo_app/done_tasks_screen.dart';
import 'package:todo_app/new_tasks_screen.dart';
import 'package:todo_app/shared/cubit/states.dart';



class AppCubit extends Cubit<AppStates>
{
  AppCubit():super(AppInitialStates());

  static AppCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;

  List<Widget> screens = [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen(),
  ];
  List<String> title = [
    'New Task',
    'Done Task',
    'Archived Task'

  ];

  void changeIndex(int index){
    currentIndex = index;
    emit(AppChangeBottomNavBarState());
  }

  Database database;
  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];

  void createDatabase()
  {
    openDatabase(
      'todo.db',
      version: 1,
      onCreate: (database,version)
      {
        print('database created');
        database.execute(
            'CREATE TABLE tasks (id INTEGER PRIMARY KEY,title TEXT, date TEXT, time TEXT, status TEXT)')
            .then((value)
        {
          print('table created');
        }).catchError((error)
        {
          print('Error When Creating Table ${error.toString()}');
        });
      },
      onOpen:(database)
      {
        getDataFromDataBase(database);
      },
    ).then((value) {
      database = value;
      emit(AppCreateDataBaseState());
    });
  }

   insertToDatabase({
    @required String title ,
    @required String time ,
    @required String date ,
  }) async
  {
     await database.transaction((txn)
    {
      txn.rawInsert(
        'INSERT INTO tasks(title,date,time,status) VALUES("$title","$date","$time","new")',
      ).then((value)
      {
        print('${value} inserted successfully');
        emit(AppInsertDataBaseState());

        getDataFromDataBase(database);
      }).catchError((error)
      {
        print('Error When Inserting VNew Record ${error.toString()}');
      });
      return null;
    });
  }

  void getDataFromDataBase(database)
  {
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];
    emit(AppGetDataBaseLoadingState());
   database.rawQuery('SELECT * FROM tasks').then((value)
   {
     value.forEach((element) {
     if(element['status']== 'new')
       newTasks.add(element);

    else if(element['status']== 'done')
      doneTasks.add(element);

     else archivedTasks.add(element);


     });

     emit(AppGetDataBaseState());
   });

  }

  void updateData({
  @required String status,
  @required int id,
}) async
  {
    database.rawUpdate(
        'UPDATE tasks SET status = ? WHERE id = ?',
        ['$status', id],
    ).then((value)
    {
      getDataFromDataBase(database);
      emit(AppUpdateDataBaseState());
    });

  }

  void deleteData({
    @required int id,
  }) async
  {
    database.rawDelete(
      'DELETE FROM tasks WHERE id = ?', [id],
    ).then((value)
    {
      getDataFromDataBase(database);
      emit(AppDeleteDataBaseState());
    });

  }

  bool isBottomSheetShown = false;
  IconData fabIcon = Icons.edit;

  void changeBottomSheetState({
  @required bool isShow,
  @required IconData icon,
})
  {
    isBottomSheetShown = isShow;
    fabIcon=icon;
    emit(AppChangeBottomSheetState());
  }


}