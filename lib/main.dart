import 'package:flutter/material.dart';
import 'package:leave_management/screens/leave_screen.dart';

void main() {
  runApp(const LeaveApp());
}

class LeaveApp extends StatelessWidget {
  const LeaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Leave Management',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LeavePage(),
    );
  }
}
