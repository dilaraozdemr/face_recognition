import 'package:face_recognition/logs/alllogs.dart';
import 'package:face_recognition/logs/riskylogs.dart';
import 'package:flutter/material.dart';
class LogsPage extends StatefulWidget {
  const LogsPage({Key? key}) : super(key: key);

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    AllLogs(),
   RiskyLogs()
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.format_list_bulleted_rounded), text: 'All Logs'),
              Tab(icon: Icon(Icons.dangerous), text: 'Risky Logs'),
            ],
          ),
        ),
        body: TabBarView(
          children: _tabs,
        ),
      ),
    );
  }
}
