import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;

class PosterDetailPage extends StatefulWidget {
  final String imageUrl;
  final String title;

  PosterDetailPage({Key? key, required this.imageUrl, required this.title})
      : super(key: key);

  @override
  State<PosterDetailPage> createState() => _PosterDetailPageState();
}

class _PosterDetailPageState extends State<PosterDetailPage> {
  Future<void> _shareFile(String imageUrl, BuildContext context) async {
    final uri = Uri.parse(imageUrl);
    final res = await http.get(uri);
    final bytes = res.bodyBytes;

    final temp = await getTemporaryDirectory();
    final path = '${temp.path}/image.jpg';
    File(path).writeAsBytesSync(bytes);

    await Share.shareFiles([path]);
  }

  Future<void> downloadImage(
      String imageUrl, String title, BuildContext context) async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      var response = await Dio()
          .get(imageUrl, options: Options(responseType: ResponseType.bytes));
      final result = await ImageGallerySaver.saveImage(
          Uint8List.fromList(response.data),
          quality: 60,
          name: title);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image saved in your galery!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black38,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text('Poster Detail'),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Hero(
              tag:
                  widget.imageUrl, // Same tag as the image on the previous page
              child: Image.network(widget.imageUrl, fit: BoxFit.contain),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
              isExtended: true,
              child: Icon(
                Icons.download,
                color: Colors.black,
              ),
              backgroundColor: Colors.amber, // Specify your desired color here
              shape: CircleBorder(),
              onPressed: () {
                downloadImage(widget.imageUrl, widget.title, context);
              }),
          FloatingActionButton(
              isExtended: true,
              child: Icon(
                Icons.share,
                color: Colors.black,
              ),
              backgroundColor: Colors.amber, // Specify your desired color here
              shape: CircleBorder(),
              onPressed: () {
                _shareFile(widget.imageUrl, context);
              }),
        ],
      ),
    );
  }
}
