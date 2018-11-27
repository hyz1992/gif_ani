library gif_ani;

import 'package:flutter/animation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';

class GifController extends AnimationController{
  ///gif有多少个帧
  final int frameCount;
  GifController({
    @required this.frameCount,
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
    if(index<0){
      index = 0;
    }else if(index>frameCount-1){
      index = index-1;
    }
    double target = index/this.frameCount;

    this.animateTo(target,duration: new Duration());
  }
}

class GifAnimation extends StatefulWidget{
  GifAnimation({
    @required this.image,
    @required this.controller,
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
  final GifController controller;
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
    _tween = new Tween<double>(begin: 0.0,end: (widget.controller.frameCount-1)*1.0);
    widget.controller.addListener(_listener);
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.removeListener(_listener);
  }

  @override
  void didUpdateWidget(GifAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_listener);
      widget.controller.addListener(_listener);
    }
  }

  void _listener(){
    int _idx = _tween.evaluate(widget.controller)~/1;
    print("idx:$_idx");
    if(_idx>=widget.controller.frameCount){
      _idx = widget.controller.frameCount-1;
    }
    if(_curIndex!=_idx){
      setState(() {
        _curIndex = _idx;
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
        frameCount: widget.controller.frameCount
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
  int frameCount:1,
  Size size,
  ImageErrorListener onError,
}) {
  final ImageConfiguration config = createLocalImageConfiguration(context, size: size);
  final Completer<List<ImageInfo>> completer = new Completer<List<ImageInfo>>();
  final ImageStream stream = provider.resolve(config);
  List<ImageInfo> ret = [];
  void listener(ImageInfo image, bool sync) {
    ret.add(image);
    if(ret.length==frameCount){
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

