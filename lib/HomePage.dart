import 'package:animated_countdown/animated_countdown.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:lottie/lottie.dart';
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Lottie.asset("assets/lottie/lottie_sleep.json",frameRate: FrameRate.max),
              Text("Sleep Apnea Recognition",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,color: Colors.white),),
              SizedBox(height: 40,),
              ElevatedButton.icon(onPressed: (){
                Get.defaultDialog(
                    title: "",
                    content:Container(
                      height: 150,
                      width : 150,
                      child: Center(
                        child: CountDownWidget(
                                        textStyle: const TextStyle(color: Colors.black,fontSize: 50),
                                        totalDuration: 3,
                                        maxTextSize: 100,
                                        minTextSize: 10,
                                        onEnd: () {
                                        Navigator.pop(context);
                                        Get.toNamed("/camera");
                                      } ),
                      ),
                    ));
              }, icon: Icon(Icons.camera_alt), label: Text("Start Recognition")),
              SizedBox(height: 20,),
              ElevatedButton.icon(onPressed: (){
                Get.toNamed("/logs");

              }, icon: Icon(Icons.graphic_eq), label: Text("Analysis"))
            ],
          ),
        ),
      ),
    );
  }
}
