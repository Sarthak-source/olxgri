import 'dart:io';

class ProductImage {
  String url;
  String urlPrefix;
  File? file;
  bool isLocal;

  ProductImage({
     this.file,
    required this.url,
    required this.urlPrefix,
    required this.isLocal,
  });
}
