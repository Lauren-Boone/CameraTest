import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo/photo.dart';
import 'package:photo_manager/photo_manager.dart';
import 'preview.dart';
import 'icon_text_button.dart';
import 'picked_example.dart';
import 'package:oktoast/oktoast.dart';
  
import 'package:flutter/cupertino.dart';

void main() => runApp(MyApp());


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: MaterialApp(
        title: 'Pick Image Demo',
        theme: ThemeData(
          primarySwatch: Colors.lime,
        ),
        home: MyHome(title: 'Pick Image Demo'),
      ),
    );
  }
}

//class MyApp extends StatefulWidget {
// @override
//  _MyHome createState() => _MyHome();
//}

class MyHome extends StatelessWidget {
  MyHome({Key key, this.title}) : super(key: key);
  final String title;
  String  photobutton = "Camera";
  //String googeVI = "Test Photo";
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          Flexible(
            flex: 1,
            child: Container(
              color: Colors.greenAccent,
              child: Center(
                child: RaisedButton(
                    child: Text(photobutton),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => _CameraPage()),
                      );
                    }),
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: Container(
              color: Colors.greenAccent,
              child: Center(
                child: RaisedButton(
                    child: Text('Select Photos'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ViewPhotos(title: "Mytitle")),
                      );
                    }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



class ViewPhotos extends StatefulWidget {
  ViewPhotos({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<ViewPhotos> with LoadingDelegate {
  String currentSelected;

  @override
  Widget buildBigImageLoading(
      BuildContext context, AssetEntity entity, Color themeColor) {
    return Center(
      child: Container(
        width: 50.0,
        height: 50.0,
        child: CupertinoActivityIndicator(
          radius: 25.0,
        ),
      ),
    );
  }

  @override
  Widget buildPreviewLoading(
      BuildContext context, AssetEntity entity, Color themeColor) {
    return Center(
      child: Container(
        width: 50.0,
        height: 50.0,
        child: CupertinoActivityIndicator(
          radius: 25.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          FlatButton(
            child: Icon(Icons.image),
            onPressed: _testPhotoListParams,
          ),
        ],
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              IconTextButton(
                icon: Icons.photo,
                text: "photo",
                onTap: () => _pickAsset(PickType.onlyImage),
              ),
              IconTextButton(
                icon: Icons.videocam,
                text: "video",
                onTap: () => _pickAsset(PickType.onlyVideo),
              ),
              IconTextButton(
                icon: Icons.album,
                text: "all",
                onTap: () => _pickAsset(PickType.all),
              ),
              IconTextButton(
                icon: CupertinoIcons.reply_all,
                text: "Picked asset example.",
                onTap: () => routePage(PickedExample()),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pickAsset(PickType.all),
        tooltip: 'pickImage',
        child: Icon(Icons.add),
      ),
    );
  }

  void _testPhotoListParams() async {
    var assetPathList =
        await PhotoManager.getAssetPathList(type: RequestType.image);
    _pickAsset(PickType.all, pathList: assetPathList);
  }

  void _pickAsset(PickType type, {List<AssetPathEntity> pathList}) async {
    /// context is required, other params is optional.
    /// context is required, other params is optional.
    /// context is required, other params is optional.
    List<AssetEntity> imgList = await PhotoPicker.pickAsset(
      // BuildContext required
      context: context,

      /// The following are optional parameters.
      themeColor: Colors.green,
      // the title color and bottom color

      textColor: Colors.white,
      // text color
      padding: 1.0,
      // item padding
      dividerColor: Colors.grey,
      // divider color
      disableColor: Colors.grey.shade300,
      // the check box disable color
      itemRadio: 0.88,
      // the content item radio
      maxSelected: 8,
      // max picker image count
      // provider: I18nProvider.english,
      provider: I18nProvider.english,
      // i18n provider ,default is chinese. , you can custom I18nProvider or use ENProvider()
      rowCount: 3,
      // item row count

      thumbSize: 150,
      // preview thumb size , default is 64
      sortDelegate: SortDelegate.common,
      // default is common ,or you make custom delegate to sort your gallery
      checkBoxBuilderDelegate: DefaultCheckBoxBuilderDelegate(
        activeColor: Colors.white,
        unselectedColor: Colors.white,
        checkColor: Colors.green,
      ),
      // default is DefaultCheckBoxBuilderDelegate ,or you make custom delegate to create checkbox

      loadingDelegate: this,
      // if you want to build custom loading widget,extends LoadingDelegate, [see example/lib/main.dart]

      badgeDelegate: const DurationBadgeDelegate(),
      // badgeDelegate to show badge widget

      pickType: type,

      photoPathList: pathList,
    );

    if (imgList == null || imgList.isEmpty) {
      showToast("No pick item.");
      return;
    } else {
      List<String> r = [];
      for (var e in imgList) {
        var file = await e.file;
        r.add(file.absolute.path);
      }
      currentSelected = r.join("\n\n");

      List<AssetEntity> preview = [];
      preview.addAll(imgList);
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => PreviewPage(list: preview)));
    }
    setState(() {});
  }

  void routePage(Widget widget) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return widget;
        },
      ),
    );
  }
}

class _CameraPage extends StatelessWidget {
  String firstButtonText = 'Take photo';
  String secondButtonText = 'Record video';
  double textSize = 20;
  String albumName = 'Media';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Text('Back'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyHome()),
          );
        },
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Flexible(
              flex: 1,
              child: Container(
                child: SizedBox.expand(
                  child: RaisedButton(
                    color: Colors.blue,
                    onPressed: _takePhoto,
                    child: Text(firstButtonText,
                        style:
                            TextStyle(fontSize: textSize, color: Colors.white)),
                  ),
                ),
              ),
            ),
            Flexible(
              child: Container(
                  child: SizedBox.expand(
                child: RaisedButton(
                  color: Colors.white,
                  onPressed: _recordVideo,
                  child: Text(secondButtonText,
                      style: TextStyle(
                          fontSize: textSize, color: Colors.blueGrey)),
                ),
              )),
              flex: 1,
            )
          ],
        ),
      ),
    ));
  }

  void _takePhoto() async {
    ImagePicker.pickImage(source: ImageSource.camera)
        .then((File recordedImage) {
      if (recordedImage != null && recordedImage.path != null) {
        //setState(() {
        // firstButtonText = 'saving in progress...';
        //});
        GallerySaver.saveImage(recordedImage.path, albumName: albumName)
            .then((bool success) {
          // setState(() {
          // firstButtonText = 'image saved!';
          // });
        });
      }
    });
  }

  void _recordVideo() async {
    ImagePicker.pickVideo(source: ImageSource.camera)
        .then((File recordedVideo) {
      if (recordedVideo != null && recordedVideo.path != null) {
        // setState(() {
        // secondButtonText = 'saving in progress...';
        //});
        GallerySaver.saveVideo(recordedVideo.path, albumName: albumName)
            .then((bool success) {
          // setState(() {
          //  secondButtonText = 'video saved!';
          // });
        });
      }
    });
  }

  // ignore: unused_element
  void _saveNetworkVideo() async {
    String path =
        'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4';
    GallerySaver.saveVideo(path, albumName: albumName).then((bool success) {
      //setState(() {
      // print('Video is saved');
      //});
    });
  }

  // ignore: unused_element
  void _saveNetworkImage() async {
    String path =
        'https://image.shutterstock.com/image-photo/montreal-canada-july-11-2019-600w-1450023539.jpg';
    GallerySaver.saveImage(path, albumName: albumName).then((bool success) {
      //setState(() {
      // print('Image is saved');
      //});
    });
  }
}
