import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(DmApp());

class DmApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: "Sans",
        primaryColor: Colors.black,
      ),
      debugShowCheckedModeBanner: false,
      home: FlutterIGStoryBuilder(),
    );
  }
}

class FlutterIGStoryBuilder extends StatefulWidget {
  @override
  _FlutterIGStoryBuilderState createState() => _FlutterIGStoryBuilderState();
}

class _FlutterIGStoryBuilderState extends State<FlutterIGStoryBuilder> {
  GlobalKey _globalKey = new GlobalKey();

  Future<Uint8List> _capturePng() async {
    try {
      print('inside');
      RenderRepaintBoundary boundary =
          _globalKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      var pngBytes = byteData.buffer.asUint8List();
      var bs64 = base64Encode(pngBytes);
      ImageGallerySaver.save(pngBytes);
      print(pngBytes);
      print(bs64);
      setState(() {});
      return pngBytes;
    } catch (e) {
      print(e);
      return null;
    }
  }

  void _requestPermissions() async {
    Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler().requestPermissions([PermissionGroup.storage]);
  }

  @override
  void initState() {
    _requestPermissions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Stack(
      children: <Widget>[
        RepaintBoundary(
          key: _globalKey,
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 60.0, vertical: 130.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  TitleRow.right(text: "Title here"),
                  AspectRatio(
                    aspectRatio: 4 / 5,
                    child: ImagePickerWidget(),
                  ),
                  TitleRow.left(text: "Date here"),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 30,
          right: 30,
          child: MaterialButton(
            onPressed: _capturePng,
            child: Text("Export"),
          ),
        ),
      ],
    );
  }
}

class TitleRow extends StatefulWidget {
  final String text;
  final bool leftAligned;

  TitleRow.right({this.text = "", this.leftAligned = false});

  TitleRow.left({this.text = "", this.leftAligned = true});

  @override
  _TitleRowState createState() => _TitleRowState();
}

class _TitleRowState extends State<TitleRow> {
  final TextStyle _titleStyle = TextStyle(
    fontWeight: FontWeight.w900,
  );

  String _text;

  TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    this._text = widget.text;
    this._controller = TextEditingController(text: widget.text);
  }

  void _changeText(String newText) {
    this.setState(() {
      this._text = newText;
    });
  }

  List<Widget> _buildItems() {
    return [
      Text(
        _text.toUpperCase(),
        style: _titleStyle,
      ),
      SizedBox(width: 12.0),
      Expanded(
        child: Container(
          height: 3,
          color: Colors.black,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => showDialog(
        context: context,
        builder: (ctx) => Dialog(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
                textCapitalization: TextCapitalization.characters,
                style: TextStyle(fontWeight: FontWeight.w900),
                decoration: InputDecoration.collapsed(
                  hintText: "",
                  border: InputBorder.none,
                ),
                controller: this._controller,
                onSubmitted: (val) {
                  this._changeText(val);
                  Navigator.pop(context);
                }),
          ),
        ),
      ),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: this.widget.leftAligned
              ? _buildItems()
              : _buildItems().reversed.toList()),
    );
  }
}

class ImagePickerWidget extends StatefulWidget {
  @override
  _ImagePickerWidgetState createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  File _image;

  Future _pickImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        child: this._image != null
            ? Image.file(this._image, fit: BoxFit.cover)
            : Stack(
                children: <Widget>[
                  Container(color: Colors.grey.shade300),
                  Center(child: Text("Tap here to load image...")),
                ],
              ),
      ),
    );
  }
}
