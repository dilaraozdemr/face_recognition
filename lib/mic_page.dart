import 'dart:async';

import 'package:flutter/material.dart';
import 'package:record/record.dart';

class MicPage extends StatefulWidget {
  const MicPage({Key? key}) : super(key: key);

  @override
  State<MicPage> createState() => _MicPageState();
}

class _MicPageState extends State<MicPage> {
  AudioRecorder myRecording = AudioRecorder();
  Timer? timer;

  double volume = 0.0;
  double minVolume = -45.0;

  startTimer() async{
    timer ??= Timer.periodic(Duration(milliseconds: 10), (timer)=> updateVolume());
  }
  updateVolume() async{
    Amplitude ampl = await myRecording.getAmplitude();
    if(ampl.current > minVolume){
      setState(() {
        volume = (ampl.current - minVolume) / minVolume;
      });
      print("Volume $volume");
    }
  }

  int volumeOto(int maxVolumeToDisplay){
    return (volume * maxVolumeToDisplay).round().abs();
  }

  Future<bool> startRecording() async{
    if(await myRecording.hasPermission()){
      if(!await myRecording.isRecording()){
        await myRecording.startStream(RecordConfig());
      }
      startTimer();
      return true;
    }else{
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: startRecording(), builder: (context, AsyncSnapshot<bool> snapshot){
      return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(snapshot.hasData ? volumeOto(100).toString() : "NO DATA"),
          ],
        ),
      );
    });
  }
}
