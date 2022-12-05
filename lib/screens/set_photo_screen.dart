import 'dart:io';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:custom_image_crop/custom_image_crop.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import '../widgets/common_buttons.dart';
import '../constants.dart';
import 'package:image/image.dart';
import 'select_photo_options_screen.dart';

// ignore: must_be_immutable
class SetPhotoScreen extends StatefulWidget {
  SetPhotoScreen({super.key});

  static const id = 'set_photo_screen';
  final _controller = CropController();

  @override
  State<SetPhotoScreen> createState() => _SetPhotoScreenState();
}

class _SetPhotoScreenState extends State<SetPhotoScreen> {
  File? _image;

  Future _pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      File? img = File(image.path);
      img = await _cropImage(imageFile: img);
      setState(() {
        _image = img;
        Navigator.of(context).pop();
      });
    } on PlatformException catch (e) {
      print(e);
      Navigator.of(context).pop();
    }
  }

  CustomImageCropController controller = CustomImageCropController();

//how to get the last image from gallery in flutter?
  // List<AssetEntity> assets = [];
  _fetchAssets() async {
    background();
    final albums = await PhotoManager.getAssetPathList(type: RequestType.all);
    final recentAlbum = albums.first;
    Future<MemoryImage?> image;
    final recentAssets = await recentAlbum.getAssetListRange(
      start: 0, // start at index 0
      end: 1, // end at a very big index (to get all the assets)
    );
    CustomImageCrop(
      image: AssetImage(recentAssets[0].toString()),
      cropController: controller,
    );
    image = controller.onCropImage();
    GallerySaver.saveImage(image.toString());
    // .then((value) => {
    //       print(value),
    //       for (int i = 0; i < value.length; i++)
    //         {
    //           CustomImageCrop(
    //             image: AssetImage(value[i].toString()),
    //             cropController: controller,
    //           ),
    //           image = controller.onCropImage(),
    //           GallerySaver.saveImage(image.toString()),
    //         }
    //     });

    // print(recentAssets);

    // final image = await controller.onCropImage();
    // if (image != null) {
    //   File('my_images').writeAsBytes(image.bytes);
    // }
    // //setState(() => assets = recentAssets);
  }

  //how to crop images automatically into fixed size in flutter ?

  Future<File?> _cropImage({required File imageFile}) async {
    AssetEntity data = await _fetchAssets();
    // print(data);
    CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: data.file.toString(),
      maxWidth: 1080,
      maxHeight: 1080,
      aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
      cropStyle: (CropStyle.rectangle),
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            hideBottomControls: true,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: true),
        IOSUiSettings(
          title: 'Cropper',
        ),
      ],
    );
    print(croppedImage);
    //     );
    if (croppedImage == null) return null;
    GallerySaver.saveImage(croppedImage.path);
    return File(croppedImage.path);
  }

  background() async {
    try {
      final androidConfig = FlutterBackgroundAndroidConfig(
        notificationTitle: "flutter_background example app",
        notificationText:
            "Background notification for keeping the example app running in the background",
        notificationImportance: AndroidNotificationImportance.Default,
        notificationIcon: AndroidResource(
            name: 'background_icon',
            defType: 'drawable'), // Default is ic_launcher from folder mipmap
      );
      bool success =
          await FlutterBackground.initialize(androidConfig: androidConfig);
      if (success) {
        FlutterBackground.enableBackgroundExecution();
      }
    } catch (e) {
      print(e);
    }
  }

  void initState() {
    super.initState();
    controller = CustomImageCropController();
  }

  void _showSelectPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.28,
          maxChildSize: 0.4,
          minChildSize: 0.28,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: SelectPhotoOptionsScreen(
                onTap: _pickImage,
              ),
            );
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.only(left: 20, right: 20, bottom: 30, top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Column(
              //   children: [
              //     Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: const [
              //         SizedBox(
              //           height: 30,
              //         ),
              //         Text(
              //           'Set a photo of yourself',
              //           style: kHeadTextStyle,
              //         ),
              //         SizedBox(
              //           height: 8,
              //         ),
              //         Text(
              //           'Photos make your profile more engaging',
              //           style: kHeadSubtitleTextStyle,
              //         ),
              //       ],
              //     ),
              //   ],
              // ),
              const SizedBox(
                height: 8,
              ),
              Padding(
                padding: const EdgeInsets.all(28.0),
                child: Center(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      _showSelectPhotoOptions(context);
                    },
                    child: Center(
                      child: Container(
                          height: 200.0,
                          width: 200.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade200,
                          ),
                          child: Center(
                            child: _image == null
                                ? const Text(
                                    '',
                                    style: TextStyle(fontSize: 20),
                                  )
                                : CircleAvatar(
                                    backgroundImage: FileImage(_image!),
                                    radius: 200.0,
                                  ),
                          )),
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  CommonButtons(
                    onTap: () => _fetchAssets(),
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    textLabel: 'Click to start',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
