import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:under_control_flutter/helpers/responsive_size.dart';
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

class _UserImagePickerState extends State<UserImagePicker> with ResponsiveSize {
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
          radius: responsiveSize(small: 12, large: 6),
          backgroundColor: Colors.grey,
          backgroundImage: _image != null ? FileImage(_image!) : null,
          child: _image == null
              ? Text(
                  '?',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: responsiveSize(small: 15, large: 7),
                    fontWeight: FontWeight.w700,
                  ),
                )
              : null,
        ),
        Row(
          mainAxisAlignment: isLargeScreen()
              ? MainAxisAlignment.center
              : MainAxisAlignment.spaceAround,
          children: [
            //take foto
            TextButton.icon(
              onPressed: () {
                _pickImage(ImageSource.camera);
              },
              icon: Icon(
                Icons.camera,
                size: responsiveSize(small: 8, medium: 5, large: 2),
              ),
              label: Text(
                'Take foto',
                style: TextStyle(
                  fontSize: responsiveSize(small: 4, medium: 3, large: 1),
                ),
              ),
            ),
            Text(
              'or',
              style: TextStyle(
                fontSize: responsiveSize(small: 5, medium: 4, large: 1),
              ),
            ),
            //choose avatar image from device
            TextButton.icon(
              onPressed: () {
                _pickImage(ImageSource.gallery);
              },
              icon: Icon(
                Icons.image,
                size: responsiveSize(small: 8, medium: 5, large: 2),
              ),
              label: Text(
                'Add image',
                style: TextStyle(
                  fontSize: responsiveSize(small: 4, medium: 3, large: 1),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
