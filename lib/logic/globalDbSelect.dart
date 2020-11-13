class GlobalDbSelect {
  int dbNumber = 0;

  static final GlobalDbSelect _instance = GlobalDbSelect._internal();

  factory GlobalDbSelect() {
    return _instance;
  }

  GlobalDbSelect._internal();

  int get dbNo {
    return dbNumber;
  }

  void set dbNo(int dbNum) {
    dbNumber = dbNum;
  }
}
