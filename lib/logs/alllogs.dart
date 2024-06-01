import 'package:face_recognition/controllers/logs_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/LogsResponseModel.dart';
class AllLogs extends StatefulWidget {
  const AllLogs({Key? key}) : super(key: key);

  @override
  State<AllLogs> createState() => _AllLogsState();
}

class _AllLogsState extends State<AllLogs> {
  LogsController controller = Get.put(LogsController());
  @override
  Widget build(BuildContext context) {
    return  FutureBuilder<Map<String, List<StatusLog>>>(
      future: controller.fetchStatusLogs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No logs found'));
        } else {
          Map<String, List<StatusLog>> groupedLogs = snapshot.data!;
          return ListView(
            children: groupedLogs.entries.map((entry) {
              String date = entry.key;
              List<StatusLog> logs = entry.value;
              return ExpansionTile(
                title: Text(date),
                children: logs.map((log) {
                  return Column(
                    children: [
                      SizedBox(height: 20,),
                      Container(
                        decoration: BoxDecoration(color: Colors.white),
                        child: ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Sleep Status: ${log.sleepStatus}'),
                              Text('Snoozing Status: ${log.snoozingStatus}'),
                              Text('Sound Level: ${log.soundLevel}'),
                            ],
                          ),
                          subtitle: Text('Timestamp: ${log.timestamp}'),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              );
            }).toList(),
          );
        }
      },
    );
  }
}
