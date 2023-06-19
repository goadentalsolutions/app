import 'package:flutter/material.dart';
import 'dart:io';

class ImageModel{
  String? description, url;
  File? file;

  ImageModel({this.description = '', required this.url, this.file});
}