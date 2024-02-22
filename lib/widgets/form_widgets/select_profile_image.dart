import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:opti_food_app/assets/images.dart';

import '../../screens/MountedState.dart';
import '../app_theme.dart';

class SelectProfileImage extends StatefulWidget{
  var selectedImagePath;
  Function onChangeImage;
  SelectProfileImage(this.selectedImagePath,this.onChangeImage);
  late _SelectProfileImageState __selectProfileImageState;
  @override
  State<StatefulWidget> createState(){
    __selectProfileImageState = _SelectProfileImageState();
    return __selectProfileImageState;
  }

  void updateImage(String path){
      __selectProfileImageState.updateImage(path);
  }
}
class _SelectProfileImageState extends MountedState<SelectProfileImage>{
  var _image;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.selectedImagePath!=null){
      _image = File(widget.selectedImagePath);
    }
  }
  void updateImage(String path){
    setState(() {
      widget.selectedImagePath = path;
      _image = File(widget.selectedImagePath);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(padding: EdgeInsets.only(top: 35,bottom: 35),
          margin: EdgeInsets.only(bottom: 30),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),

          child: Container( // Container to add shaddow for circular avatar
            width: 65,
            decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12,spreadRadius: 2)]
            ),
            child: GestureDetector(
              child: CircleAvatar( // outer cicleavatar to add white border around actual avatar
                backgroundColor: Colors.white,
                radius: 55,
                child: CircleAvatar( // actual circle avatar
                  backgroundImage: _image==null?null:FileImage(_image),
                  backgroundColor: Colors.white,
                  radius: 50,
                  child: _image!=null?null:
                  SvgPicture.asset(AppImages.addLogoIcon,
                      height: 35),
                ),
              ),
              onTap: () async { // on click of circle avatar
                //final image = await ImagePicker().getImage(source: ImageSource.gallery);
                final image = await ImagePicker().pickImage(source: ImageSource.gallery);
                if(image == null) return;
                final imageTemp = File(image.path);
                widget.selectedImagePath = image.path;
                widget.onChangeImage(widget.selectedImagePath);
                setState(() => this._image = imageTemp); // setting selected image to cirlce avatar
              },
            ),
          ),

        ),
        if(widget.selectedImagePath!=null)...[
          GestureDetector(
            child: Center(
              child: Container(
                  padding: EdgeInsets.all(3),
                  margin: EdgeInsets.only(top: 40, left: 70),
                  child: Icon(
                    Icons.close, color: Colors.white,),
                  decoration: BoxDecoration(
                    color: AppTheme.colorDarkGrey,
                    shape: BoxShape.circle,
                  )
              ),
            ),
            onTap: (){
              setState((){
                widget.selectedImagePath = null;
                _image = null;
                widget.onChangeImage(widget.selectedImagePath);
              });
            },
          )
        ]
      ],
    );
  }

}