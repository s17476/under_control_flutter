import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:under_control_flutter/helpers/size_config.dart';

//helper to pick images from camera and device storage
class UserImagePicker extends StatefulWidget {
  const UserImagePicker(
      {Key? key, required this.imagePickFn, required this.image})
      : super(key: key);

  final File? image;

  final Function(
    File pickedImage,
  ) imagePickFn;

  @override
  _UserImagePickerState createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  @override
  void initState() {
    super.initState();
    _image = widget.image;
  }

  File? _image;

  void _pickImage(ImageSource souruce) async {
    final picker = ImagePicker();

    try {
      //gets low quality avatar image to improve loading speed
      final pickedFile = await picker.pickImage(
        source: souruce,
        imageQuality: 80,
        maxHeight: 300,
        maxWidth: 300,
      );
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
        widget.imagePickFn(_image!);
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: SizeConfig.blockSizeHorizontal * 12,
          backgroundColor: Colors.grey,
          backgroundImage: _image != null ? FileImage(_image!) : null,
          child: _image == null
              ? Text(
                  '?',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: SizeConfig.blockSizeHorizontal * 15,
                    fontWeight: FontWeight.w700,
                  ),
                )
              : null,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            //take foto
            TextButton.icon(
              onPressed: () {
                _pickImage(ImageSource.camera);
              },
              icon: Icon(
                Icons.camera,
                size: SizeConfig.blockSizeHorizontal *
                    (SizeConfig.isSmallScreen ? 8 : 5),
              ),
              label: Text(
                'Take foto',
                style: TextStyle(
                  fontSize: SizeConfig.blockSizeHorizontal *
                      (SizeConfig.isSmallScreen ? 4 : 3),
                ),
              ),
            ),
            Text(
              'or',
              style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal *
                    (SizeConfig.isSmallScreen ? 5 : 4),
              ),
            ),
            //choose avatar image from device
            TextButton.icon(
              onPressed: () {
                _pickImage(ImageSource.gallery);
              },
              icon: Icon(
                Icons.image,
                size: SizeConfig.blockSizeHorizontal *
                    (SizeConfig.isSmallScreen ? 8 : 5),
              ),
              label: Text(
                'Add image',
                style: TextStyle(
                  fontSize: SizeConfig.blockSizeHorizontal *
                      (SizeConfig.isSmallScreen ? 4 : 3),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
