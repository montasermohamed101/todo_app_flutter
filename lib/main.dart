import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/counter/counter_screen.dart';
import 'layout/home_layout.dart';
import 'shared/bloc_observer.dart';


void main() {
  Bloc.observer = MyBlocObserver();
  runApp(MyApp());


}


class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context)
  {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeLayout(),
    );
  }
}


