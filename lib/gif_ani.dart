library gif_ani;

import 'package:flutter/animation.dart';
import 'package:flutter/scheduler.dart';
import 'package:meta/meta.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';

class GifController extends AnimationController{
  ///gif有多少个帧
  final int frameNum;
  GifController({
    @required this.frameNum,
    @required TickerProvider vsync,
    double value,
    Duration duration,
    String debugLabel,
    double lowerBound,
    double upperBound,
    AnimationBehavior animationBehavior
  }):super(
    value:value,
    duration:duration,
    debugLabel:debugLabel,
    lowerBound:lowerBound??0.0,
    upperBound:upperBound??1.0,
    animationBehavior:animationBehavior??AnimationBehavior.normal,
    vsync:vsync);

  void runAni(){
    this.forward(from: 0.0);
  }

  void setFrame([int index = 0]){
    double target = index/this.frameNum;
    this.animateTo(target,duration: new Duration());
  }
}

class GifAnimation extends StatefulWidget{
  GifAnimation({
    @required this.image,
    @required this.animationCtrl,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.width,
    this.height,
    this.color,
    this.colorBlendMode,
    this.fit,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.centerSlice,
    this.matchTextDirection = false,
    this.gaplessPlayback = false,
  });
  final GifController animationCtrl;
  final ImageProvider image;
  final double width;
  final double height;
  final Color color;
  final BlendMode colorBlendMode;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final ImageRepeat repeat;
  final Rect centerSlice;
  final bool matchTextDirection;
  final bool gaplessPlayback;
  final String semanticLabel;
  final bool excludeFromSemantics;
  @override
  State<StatefulWidget> createState() {
    return new _AnimatedImageState();
  }
}

class _AnimatedImageState extends State<GifAnimation>{
  Tween<double> _tween;
  List<ImageInfo> _infos;
  int _curIndex = 0;
  ImageInfo get _imageInfo => _infos==null?null:_infos[_curIndex];

  @override
  void initState() {
    super.initState();
    _tween = new Tween<double>(begin: 0.0,end: (widget.animationCtrl.frameNum-1)*1.0);
    widget.animationCtrl.addListener(_listener);
  }

  @override
  void dispose() {
    super.dispose();
    widget.animationCtrl.removeListener(_listener);
  }

  @override
  void didUpdateWidget(GifAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animationCtrl != oldWidget.animationCtrl) {
      oldWidget.animationCtrl.removeListener(_listener);
      widget.animationCtrl.addListener(_listener);
    }
  }

  void _listener(){
    int xxx = _tween.evaluate(widget.animationCtrl)~/1;
    if(_curIndex!=xxx){
      setState(() {
        _curIndex = xxx;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if(_infos==null){
      preloadImage(
        provider: widget.image,
        context: context,
        frameNum: widget.animationCtrl.frameNum
      ).then((_list){
        _infos = _list;
        if(mounted){
          setState(() {});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final RawImage image = new RawImage(
      image: _imageInfo?.image,
      width: widget.width,
      height: widget.height,
      scale: _imageInfo?.scale ?? 1.0,
      color: widget.color,
      colorBlendMode: widget.colorBlendMode,
      fit: widget.fit,
      alignment: widget.alignment,
      repeat: widget.repeat,
      centerSlice: widget.centerSlice,
      matchTextDirection: widget.matchTextDirection,
    );
    if (widget.excludeFromSemantics)
      return image;
    return new Semantics(
      container: widget.semanticLabel != null,
      image: true,
      label: widget.semanticLabel == null ? '' : widget.semanticLabel,
      child: image,
    );
  }
}

Future<List<ImageInfo>> preloadImage({
  @required ImageProvider provider,
  @required BuildContext context,
  int frameNum:1,
  Size size,
  ImageErrorListener onError,
}) {
  final ImageConfiguration config = createLocalImageConfiguration(context, size: size);
  final Completer<List<ImageInfo>> completer = new Completer<List<ImageInfo>>();
  final ImageStream stream = provider.resolve(config);
  List<ImageInfo> ret = [];
  void listener(ImageInfo image, bool sync) {
    ret.add(image);
    if(ret.length==frameNum){
      completer.complete(ret);
    }
  }
  void errorListener(dynamic exception, StackTrace stackTrace) {
    try{
      completer.complete();
    }catch(e){}
    if (onError != null) {
      onError(exception, stackTrace);
    } else {
      FlutterError.reportError(new FlutterErrorDetails(
        context: 'image failed to precache',
        library: 'image resource service',
        exception: exception,
        stack: stackTrace,
        silent: true,
      ));
    }
  }
  stream.addListener(listener, onError: errorListener);
  completer.future.then((List<ImageInfo> _) { stream.removeListener(listener); });
  return completer.future;
}

