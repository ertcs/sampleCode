class AvatarProvider extends ChangeNotifier {
  int _rowIndex = 0;
  int _colorIndex = 0;

  List<String> _list = hair;
  List<int> _currentListIndices = List.filled(9, 0);
  List<Color> skinColors = [
    Color(0xffEDB98A),
    Color(0xffFD9841),
    Color(0xffF9D562),
    Color(0xffFFDBB4),
    Color(0xffD08B5B),
    Color(0xffAE5D29),
    Color(0xff614335),
  ];
  Map<String, String> _face = {
    'hair': hair[0],
    'glasses': glasses[0],
    'eyebrow': eyebrow[0],
    'eye': eye[0],
    'mouth': mouth[0],
    'tshirt': tshirt[0],
    'beard': beard[0],
    'head': head[0],
    'skin': skin[0]
  };
  String uid = AuthService().currentUser().uid;
  updateFace() {
    _face = {
      'hair': hair[_currentListIndices[0]],
      'glasses': glasses[_currentListIndices[5]],
      'eyebrow': eyebrow[_currentListIndices[2]],
      'eye': eye[_currentListIndices[1]],
      'mouth': mouth[_currentListIndices[3]],
      'tshirt': tshirt[_currentListIndices[6]],
      'beard': beard[_currentListIndices[4]],
      'head': head[_currentListIndices[7]],
      'skin': skin[_currentListIndices[8]]
    };
    DBService().saveAvatar(uid, _face);
    print('i is:$_colorIndex');
    notifyListeners();
  }

  setAvatar(Map<String, String> face) {
    _face = face;
    notifyListeners();
  }

  Map<String, String> get face => _face;

  List<String> _skinColorsSvg = [
    "D08B5B",
    "FD9841",
    "F9D562",
    "FFDBB4",
    "EDB98A",
    "AE5D29",
    "614335"
  ];

  setRowIndex(int val) {
    _rowIndex = val;
    notifyListeners();
  }

  int get rowIndex => _rowIndex;
  setColorIndex(int val) {
    _colorIndex = val;
    // setList(1);
    // setList(3);
    // setList(currentRowIndex);
    notifyListeners();
  }

  int get colorIndex => _colorIndex;
//current list index
  List<int> get currentListIndices => _currentListIndices;
  setCurrentListIndex(List<int> val) {
    _currentListIndices = val;
    notifyListeners();
  }

  //hair index
  int get hairIndex => _currentListIndices[0];
  setHairIndex(int val) {
    _currentListIndices[0] = val;
    notifyListeners();
  }


  //mouth index
  int get mouthIndex => _currentListIndices[3];
  setMouthIndex(int val) {
    _currentListIndices[3] = val;
    notifyListeners();
  }

//head index
  int get headIndex => _currentListIndices[7];
  setHeadIndex(int val) {
    _currentListIndices[7] = val;
    notifyListeners();
  }

  //eye index
  int get eyeIndex => _currentListIndices[1];
  seteyeIndex(int val) {
    _currentListIndices[1] = val;
    notifyListeners();
  }

//eyebrew index
  int get eyebrowIndex => _currentListIndices[2];
  seteyebrowIndex(int val) {
    _currentListIndices[2] = val;
    notifyListeners();
  }

//tshirt index
  int get tshirtIndex => _currentListIndices[6];
  setshirtIndex(int val) {
    _currentListIndices[6] = val;
    notifyListeners();
  }

//glasses index
  int get glassesIndex => _currentListIndices[5];
  setglassesIndex(int val) {
    _currentListIndices[5] = val;
    notifyListeners();
  }

//beard index
  int get bearIndex => _currentListIndices[4];
  setbearIndex(int val) {
    _currentListIndices[4] = val;
    notifyListeners();
  }

//skin index
  int get skinIndex => _currentListIndices[8];
  setSkinIndex(int val) {
    _currentListIndices[8] = val;
    notifyListeners();
  }

  setList(int index) {
    setRowIndex(index);
    if (index == 0) {
      _list = hair;
    } else if (index == 1) {
      // setEye();
      _list = eye;
    } else if (index == 2) {
      _list = eyebrow;
    } else if (index == 3) {
      // setMouth();
      _list = mouth;
    } else if (index == 4) {
      _list = beard;
    } else if (index == 5) {
      _list = glasses;
    } else if (index == 6) {
      _list = tshirt;
    } else if (index == 7) {
      _list = head;
    } else if (index == 8) {
      _list = skin;
    }

    notifyListeners();
  }

  List<String> get list => _list;

  makeRandomAvatar() {
    _currentListIndices[0] = Random().nextInt(hair.length);
    _currentListIndices[7] = 0;
    _currentListIndices[2] = Random().nextInt(eyebrow.length);
    _currentListIndices[1] = Random().nextInt(eye.length);
    _currentListIndices[3] = Random().nextInt(mouth.length);
    _currentListIndices[5] = Random().nextInt(glasses.length);
    _currentListIndices[4] =
        _currentListIndices[0] != 15 ? Random().nextInt(beard.length) : 0;
    _currentListIndices[6] = Random().nextInt(tshirt.length);
    _currentListIndices[8] = Random().nextInt(skinColors.length);
    setColorIndex(_currentListIndices[8]);
    _face = {
      'hair': hair[_currentListIndices[0]],
      'glasses': glasses[_currentListIndices[5]],
      'eyebrow': eyebrow[_currentListIndices[2]],
      'eye': eye[_currentListIndices[1]],
      'mouth': mouth[_currentListIndices[3]],
      'tshirt': tshirt[_currentListIndices[6]],
      'beard': beard[_currentListIndices[4]],
      'head': head[_currentListIndices[7]],
      'skin': skin[_currentListIndices[8]]
    };

    DBService().saveAvatar(uid, _face);
    notifyListeners();
  }
}