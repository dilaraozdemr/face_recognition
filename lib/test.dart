import 'package:flutter/material.dart';
class BaseWidget extends StatefulWidget {
  const BaseWidget({Key? key}) : super(key: key);

  @override
  State<BaseWidget> createState() => _BaseWidgetState();
}
var textController = TextEditingController();
class _BaseWidgetState extends State<BaseWidget> {
  @override
  Widget build(BuildContext context) {
    return  InnerWidget(onTap: (onTapText){
      print(onTapText);
    });
  }
}


class InnerWidget extends StatefulWidget {
  final Function(String onTapText) onTap;
  const InnerWidget({Key? key, required this.onTap}) : super(key: key);

  @override
  State<InnerWidget> createState() => _InnerWidgetState();
}

class _InnerWidgetState extends State<InnerWidget> {
  @override
  Widget build(BuildContext context) {
    return  GestureDetector(onTap: (){
      widget.onTap.call("tıkladım");
    },);
  }
}

