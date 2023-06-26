import 'dart:ffi';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:goa_dental_clinic/models/image_model.dart';
import 'package:image_downloader/image_downloader.dart';

import '../constants.dart';

class ImageViewer extends StatefulWidget {
  ImageViewer({required this.im});
  ImageModel im;

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  downloadImage() async {
    var imageId = await ImageDownloader.downloadImage(widget.im.url.toString());
    print('Image Id of downloaded image : $imageId}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: (widget.im.url != null || widget.im.url!.isNotEmpty) ? FloatingActionButton(onPressed: (){
        downloadImage();
      }, child: Icon(Icons.download, color: Colors.white,),) : null,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: Center(child: InkWell(child: CircleAvatar(child: Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white,), backgroundColor: Colors.black.withOpacity(0.4),), onTap: () => Navigator.pop(context),)),),
      body: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          (widget.im.file == null) ? CachedNetworkImage(imageUrl: widget.im.url!, progressIndicatorBuilder: (context, url, downloadProgress) =>
              Center(child: CircularProgressIndicator(value: downloadProgress.progress, color: kPrimaryColor,)),) : Image.file(widget.im.file!),
          Container(
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 30, top: 8),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.4),),
            child: Text('${widget.im.description}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
            width: double.infinity,
          )
        ],
      ),
    );
  }
}
