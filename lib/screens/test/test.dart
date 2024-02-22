import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../MountedState.dart';
class PyWidgetTestPage extends StatefulWidget {
  PyWidgetTestPage({required Key key, routerArguments}) : super(key: key);
  @override
  _PyWidgetTestPageState createState() => _PyWidgetTestPageState();
}

class _PyWidgetTestPageState extends MountedState<PyWidgetTestPage> with TickerProviderStateMixin {
  late TabController controller; //= TabController(length: 14, vsync: this);
  late AnimationController anicontroller;
  late Animation animation;
  late Animation<int> intAnim;
  late Animation<Color> colorAni;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = TabController(length: 14, vsync: this);
    ;
    // ColorTween(
    // //   begin: Colors.black26,
    // //   end: new Color(0xff622F74),
    // // ).animate(_conrtoller)
    // //   ..addListener(() {
    // //     print("set stats");
    // //     setState(() {});
    // //   });
    // // _conrtoller.forward();
    // anicontroller = AnimationController(duration: const Duration(milliseconds: 10000), vsync: this);
    // anicontroller.addListener(() {
    //   print("controller=====${anicontroller.value}");
    // });
    // anicontroller.addStatusListener((status) {
    //   print("status====$status");
    // });
    // intAnim = IntTween(begin: 0, end: 200).animate(anicontroller)
    //   ..addListener(() {
    //     setState(() {});
    //   })
    //   ..addStatusListener((status) {});
    // // colorAni = ColorTween(begin: Colors.purpleAccent, end: Colors.orange).animate(anicontroller)
    // //   ..addListener(() {
    // //     setState(() {});
    // //   })
    // //   ..addStatusListener((status) {});
    // anicontroller.forward();
  }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   appBar: new AppBar(
    //     backgroundColor: colorAni?.value ?? Colors.purple,
    //     title: new Text("adfadf"),
    //   ),
    //   body: Column(children: [
    //     Text("${intAnim?.value ?? "ssss"}"),
    //   ]),
    // );
    return TabAnimation();
  }
}

class TabAnimation extends StatefulWidget {
  @override
  _TabAnimationState createState() => _TabAnimationState();
}

class _TabAnimationState extends MountedState<TabAnimation> with TickerProviderStateMixin {
  late TabController _tabController;
  GlobalKey<__TabState> keyA = GlobalKey();
  GlobalKey<__TabState> keyB = GlobalKey();
  GlobalKey<__TabState> keyC = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
    _tabController.addListener(() {
      print("-------");
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.lightBlue,
        //accentColor: Colors.orange,
      ),
      home: DefaultTabController(
        length: 3,
        child: new Scaffold(
          appBar: new AppBar(
            title: new Text("${Icons.animation}"),
            bottom: new PreferredSize(
              preferredSize: const Size(double.infinity, 48.0),
              child: new Container(
                color: Colors.white,
                child: new TabBar(
                  onTap: (int value) {
                    print("adfadf $value");
                    keyA.currentState?.setAnimation(value == 0); //调用子控件方法
                    keyB.currentState?.setAnimation(value == 1); //调用子控件方法
                    keyC.currentState?.setAnimation(value == 2); //调用子控件方法
                  },
                  labelColor: Colors.black87,
                  unselectedLabelColor: Colors.grey,
                  controller: _tabController,
                  tabs: <Widget>[
                    Tab(
                        child: new _Tab(
                          0,
                          "Tab1",
                          _tabController,
                          key: keyA,
                        )),
                    Tab(
                        child: new _Tab(
                          1,
                          "Tab2",
                          _tabController,
                          key: keyB,
                        )),
                    Tab(
                        child: new _Tab(
                          2,
                          "Tab3",
                          _tabController,
                          key: keyC,
                        )),
                  ],
                ),
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: <Widget>[
              new Container(child: Center(child: new Text("1"))),
              new Container(child: Center(child: new Text("2"))),
              new Container(child: Center(child: new Text("3"))),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatefulWidget {
  final int tabindex;
  final String tabname;
  final TabController tabcontroller;

  _Tab(this.tabindex, this.tabname, this.tabcontroller, {required Key key}) : super(key: key);

  @override
  __TabState createState() => __TabState();
}

class __TabState extends MountedState<_Tab> with TickerProviderStateMixin {
  late int count;
  late bool isSelected;
  late Animation<Color> animation;
  late AnimationController _conrtoller; // = AnimationController(duration: Duration(milliseconds: 300), vsync: this);
  @override
  void initState() {
    super.initState();
    _conrtoller = AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    ;
    isSelected = widget.tabindex == 0;
    setAnimation(widget.tabindex == 0);
  }

  setAnimation(bool selected) {
    if (isSelected == selected) {
      return;
    }
    isSelected = selected;
    print("widget index ${widget.tabindex} selectedc: $selected");
    _conrtoller?.dispose();
    _conrtoller = AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    // animation = ColorTween(
    //   begin: selected ? Colors.black26 : new Color(0xff622F74),
    //   end: selected ? new Color(0xff622F74) : Colors.black26,
    // ).animate(_conrtoller)
    //   ..addListener(() {
    //     setState(() {});
    //   });
    _conrtoller.forward();
  }

  @override
  Widget build(BuildContext context) {
    print("build${widget.tabindex}");
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Text(widget.tabname),
        new Container(
          alignment: AlignmentDirectional.center,
          constraints: BoxConstraints(minHeight: 22.0, minWidth: 22.0),
          margin: EdgeInsets.only(left: 5.0),
          child: new Text(
            widget.tabindex.toString(),
            style: TextStyle(color: Colors.white70, fontSize: 10.0),
          ),
          decoration: new BoxDecoration(
              shape: BoxShape.circle,
              color: animation == null ? Colors.black26 : animation.value,
              border: new Border.all(
                width: 0.8,
                color: Colors.white,
              ),
              boxShadow: [
                new BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 5.0,
                ),
              ]),
        )
      ],
    );
  }
}