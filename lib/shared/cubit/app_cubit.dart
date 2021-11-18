import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:to_do_app2/modules/screens/archived_tasks.dart';
import 'package:to_do_app2/modules/screens/done_tasks.dart';
import 'package:to_do_app2/modules/screens/new_tasks.dart';
import 'package:to_do_app2/shared/cubit/app_states.dart';

class AppCubit extends Cubit<AppStates>{
  AppCubit() : super(AppInitialState());
  List<Widget>screens=[NewTasks(),DoneTasks(),ArchivedTasks()];
  List<String>titles=['New Tasks','Done Tasks','Archived Tasks'];
  int currentIndex=0;
  IconData fabIcon=Icons.edit;
  bool isBottomSheetShown=false;
  Database database;
  List<Map>tasks=[];

  //////////////////////////////////////////////////////////////////////////////////////


  static AppCubit getCubit(context)=>BlocProvider.of(context);
  void changeIndex(int index){
    currentIndex=index;
    emit(AppChangeBottomIndexState());
  }
  void closeBottomSheet(bool isShow,IconData iconData){
    isBottomSheetShown=isShow;
    fabIcon=iconData;
    emit(AppCloseBottomSheetState());
  }
  void openBottomSheet(bool isShow,IconData iconData){
    isBottomSheetShown=isShow;
    fabIcon=iconData;
    emit(AppOpenBottomSheetState());
  }
  void createDatabase(){
     openDatabase('to_do.db',version:1,
    onCreate: (database,version){
        database
            .execute('CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, time TEXT, date TEXT, status TEXT)')
            .then((value) {
          print('table created');

        }).catchError(onError);
    },
    onOpen: (database){
      getAllDatabase(database);
      print('database opened');
    }
    ).then((value) {
      database=value;


      emit(AppCreateDatabaseState());
    });
  }
  Future insertDatabase({@required String title, @required String time, @required String date,}) async {
     await database.transaction((txn){
      txn.rawInsert('INSERT INTO tasks(title,time,date, status) VALUES("$title", "$time", "$date", "new")'
      ).then((value) => (){
        getAllDatabase(database);
        print(value);
        emit(AppInsertDatabaseState());
      });
      return null;
    });
  }

  void getAllDatabase(database){
     database.rawQuery('SELECT * FROM tasks').then((value){
       tasks=value;
       print(tasks);
       emit(AppGetDatabaseState());
     });
  }
}