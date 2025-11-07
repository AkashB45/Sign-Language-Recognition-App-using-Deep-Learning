import 'dart:math';

List<List<int>> calcLandmarkList(
    List<dynamic> landmarks, int imageWidth, int imageHeight) {
  List<List<int>> landmarkPoint = [];

  for (var landmark in landmarks) {
    int x = min((landmark['x'] * imageWidth).round(), imageWidth - 1);
    int y = min((landmark['y'] * imageHeight).round(), imageHeight - 1);
    landmarkPoint.add([x, y]);
  }

  return landmarkPoint;
}

List<double> preProcessLandmark(List<List<int>> landmarkList) {
  List<List<int>> tempLandmarkList = List.from(landmarkList);

  // Relative coordinates
  int baseX = tempLandmarkList[0][0];
  int baseY = tempLandmarkList[0][1];
  for (int i = 0; i < tempLandmarkList.length; i++) {
    tempLandmarkList[i][0] -= baseX;
    tempLandmarkList[i][1] -= baseY;
  }

  // Flatten
  List<int> flat = [];
  for (var p in tempLandmarkList) {
    flat.addAll(p);
  }

  // Normalize safely
  double maxValue = flat.map((e) => e.abs()).reduce(max).toDouble();
  if (maxValue == 0) maxValue = 1.0;

  return flat.map((n) => n / maxValue).toList();
}
