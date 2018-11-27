# gif_ani
a flutter plugin to control gif animation

![The example screen shot](https://github.com/hyz1992/gif_ani/gif/screenshot.gif?raw=true)

## Usage
GifController is subclass of AnimationController.
GifAnimation is just used like Image.
```Dart
import 'package:gif_ani/gif_ani.dart';
GifController _animationCtrl = new GifController(vsync: this,duration: new Duration(milliseconds: 1200),frameNum: 32);
Widget ret = new GifAnimation(
    image: new AssetImage("like_anim.gif"),
    animationCtrl: _animationCtrl,
);
```
then you can control the gif animation by _animationCtrl:
```Dart
///run the anim from start
_animationCtrl.runAni();

///set the Image with specified frame
_animationCtrl.setFrame(10);

///or you can use other action as a AnimationController
_animationCtrl.repeat();
_animationCtrl.reverse();
_animationCtrl.reset();
```