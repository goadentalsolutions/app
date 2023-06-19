import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:goa_dental_clinic/constants.dart';
import 'package:goa_dental_clinic/custom_widgets/image_viewer.dart';

import '../models/image_model.dart';

class ImageDesContainer extends StatefulWidget {
  ImageDesContainer({required this.im});
  ImageModel im;

  @override
  State<ImageDesContainer> createState() => _ImageDesContainerState();
}

class _ImageDesContainerState extends State<ImageDesContainer> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return UnconstrainedBox(
      child: Container(
        padding: EdgeInsets.all(8.0),
        height: size.height * 0.35,
        decoration: BoxDecoration(
          color: kBackgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Expanded(
                child: Container(
              child: (widget.im.file == null) ? CachedNetworkImage(
                imageUrl: widget.im.url!,
                fit: BoxFit.cover,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    Center(child: CircularProgressIndicator(value: downloadProgress.progress, color: kPrimaryColor,)),
              ) : Image.file(widget.im!.file!),
            )),
            SizedBox(
              height: 12,
            ),
            Container(
              constraints: BoxConstraints(maxWidth: size.width * 0.4),
              child: Text('${widget.im.description}', maxLines: 1,),
            ),
            SizedBox(height: 8,),
            InkWell(child: Text('View Image', style: TextStyle(color: kPrimaryColor, fontSize: 14),), onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => ImageViewer(im: widget.im),),);
            },),
          ],
        ),
      ),
    );
  }
}
