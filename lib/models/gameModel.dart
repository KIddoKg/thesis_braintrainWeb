class GameModel {
  String id;
  String gameType;
  String gameName;
  int noOfLevels;
  int score;
  int playTime;
  int level;
  dynamic newPicOneResult;
  dynamic newPicTwoResult;
  dynamic noOfFishCaught;
  bool boatStatus;
  dynamic wordList;
  int createdDate;

  GameModel({
    required this.id,
    required this.gameType,
    required this.gameName,
    required this.noOfLevels,
    required this.score,
    required this.playTime,
    required this.level,
    required this.newPicOneResult,
    required this.newPicTwoResult,
    required this.noOfFishCaught,
    required this.boatStatus,
    required this.wordList,
    required this.createdDate,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      id: json['id'] ?? "",
      gameType: json['gameType'] ?? "",
      gameName: json['gameName'] ?? "",
      noOfLevels: json['noOfLevels'] ??0,
      score: json['score'] ?? 0,
      playTime: json['playTime'] ?? 0,
      level: json['level'] ??0,
      newPicOneResult: json['newPicOneResult']?? [],
      newPicTwoResult: json['newPicTwoResult']??[],
      noOfFishCaught: json['noOfFishCaught']?? 0,
      boatStatus: json['boatStatus']??false,
      wordList: json['wordList'],
      createdDate: json['createdDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gameType': gameType,
      'gameName': gameName,
      'noOfLevels': noOfLevels,
      'score': score,
      'playTime': playTime,
      'level': level,
      'newPicOneResult': newPicOneResult,
      'newPicTwoResult': newPicTwoResult,
      'noOfFishCaught': noOfFishCaught,
      'boatStatus': boatStatus,
      'wordList': wordList,
      'createdDate': createdDate,
    };
  }
}
