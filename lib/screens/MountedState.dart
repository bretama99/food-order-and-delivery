import 'package:flutter/cupertino.dart';

class MountedState<T extends StatefulWidget> extends State<T> {
  @override
  Widget build(BuildContext context) {
    return Text("");
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
}