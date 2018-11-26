import 'package:flutter/material.dart';
import 'package:gif_ani/gif_ani.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin{
  GifController _animationCtrl;
  @override
  void initState() {
    super.initState();
    _animationCtrl = new GifController(vsync: this,duration: new Duration(milliseconds: 1200),frameNum: 32);
  }
  @override
  void dispose() {
    _animationCtrl.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new RaisedButton.icon(
              icon: new Icon(Icons.satellite),
              label: new Text("开始动画"),
              onPressed: (){
                _animationCtrl.runAni();
              },
            ),
            new RaisedButton.icon(
              icon: new Icon(Icons.satellite),
              label: new Text("指定帧"),
              onPressed: (){
                _animationCtrl.setFrame(10);
              },
            ),
            new RaisedButton.icon(
              icon: new Icon(Icons.satellite),
              label: new Text("循环动画"),
              onPressed: (){
                _animationCtrl.repeat();
              },
            ),
            _buildGif(),
          ],
        ),
      ),
    );
  }

  Widget _buildGif(){
    Widget ret = new GifAnimation(
      image: new AssetImage("like_anim.gif"),
      animationCtrl: _animationCtrl,
    );
    return ret;
  }
}
