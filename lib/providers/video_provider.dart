import 'package:flutter/cupertino.dart';

class VideoProvider extends ChangeNotifier {
  List<bool> favorite = List.generate(3, (index) => false);
  List<bool> commentSheet = List.generate(3, (index) => false);
  List<bool> isLiked = List.generate(3, (index) => false);

  setLike(bool value, int index) {
    isLiked[index] = value;
    notifyListeners();
  }

  showCommentSheet(bool value, int index) {
    commentSheet[index] = value;
    notifyListeners();
  }

  changeFavorite(bool value, int index) {
    favorite[index] = value;
    notifyListeners();
  }
}
