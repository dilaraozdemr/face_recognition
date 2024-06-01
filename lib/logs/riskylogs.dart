import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../controllers/logs_controller.dart';
import '../models/RiskLog.dart';
class RiskyLogs extends StatefulWidget {
  const RiskyLogs({Key? key}) : super(key: key);

  @override
  State<RiskyLogs> createState() => _RiskyLogsState();
}

class _RiskyLogsState extends State<RiskyLogs> {
  LogsController controller = Get.put(LogsController());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, List<RiskLog>>>(
      future: controller.fetchRiskLogsGroupedByDate(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No risk logs found'));
        } else {
          Map<String, List<RiskLog>> groupedRiskLogs = snapshot.data!;
          return Column(
            children: [
              ListView(
                shrinkWrap: true,
                children: groupedRiskLogs.entries.map((entry) {
                  String date = entry.key;
                  List<RiskLog> logs = entry.value;
                  return ExpansionTile(
                    title: Text(date),
                    leading: IconButton(onPressed: (){ _showDailyChartDialog(context, date, logs);}, icon: Icon(Icons.auto_graph)),
                    children: logs.map((log) {
                      return log.duration.inSeconds > 0 ? ListTile(
                        title: Text('Duration: ${log.duration.inSeconds} seconds, Avg Sound Level: ${log.avgSoundLevel.toStringAsFixed(2)}'),
                        subtitle: Text('Start: ${log.start}, End: ${log.end}'),
                      ) : Container();
                    }).toList(),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _showOverallChartDialog(context, groupedRiskLogs);
                  },
                  child: Text('Show Overall Chart'),
                ),
              ),
            ],
          );
        }
      },
    );
  }
  void _showDailyChartDialog(BuildContext context, String date, List<RiskLog> logs) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Risk Logs for $date'),
        content: Container(
          height: 300,
          child: SfCartesianChart(
            primaryXAxis: DateTimeAxis(),
            series: <CartesianSeries>[
              LineSeries<RiskLog, DateTime>(
                dataSource: logs,
                xValueMapper: (RiskLog log, _) => log.start,
                yValueMapper: (RiskLog log, _) => log.duration.inSeconds,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showOverallChartDialog(BuildContext context, Map<String, List<RiskLog>> groupedRiskLogs) {
    List<RiskLog> allLogs = groupedRiskLogs.values.expand((logs) => logs).toList();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Overall Risk Logs'),
        content: Container(
          height: 300,
          child: SfCartesianChart(
            primaryXAxis: DateTimeAxis(),
            series: <CartesianSeries>[
              LineSeries<RiskLog, DateTime>(
                dataSource: allLogs,
                xValueMapper: (RiskLog log, _) => log.start,
                yValueMapper: (RiskLog log, _) => log.duration.inSeconds,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
