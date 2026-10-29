class Assets {
  static const List<int> staticNoise = [12, 13, 14, 15, 16, 17, 18, 20];
  static const List<int> blipStatic = [22, 23, 4, 25, 6, 8, 9, 10, 21];

  static const List<int> titleBgs = [430, 439, 440, 441];
  static const int titleLogo = 444;
  static const int newGame = 448;
  static const int continueWord = 449;
  static const int customNight = 526;
  static const int sixthNight = 443;
  static const int nightWord = 475;
  static const int star = 432;
  static const int tinyMan = 477;
  static const int demo = 572;
  static const int newspaper = 574;
  static const int paycheck = 210;
  static const int pinkSlip = 555;
  static const int goldenFreddy = 573;

  static const int officeBase = 39;
  static const int officeLitLeft = 126;
  static const int officeLitRight = 127;
  static const int ceilingLights = 608;
  static const int doorFrameLeft = 40;
  static const int doorFrameRight = 44;
  static const int fan = 59;

  static const List<int> doorLeftClose = [103, 88, 105, 89, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102];
  static const List<int> doorRightClose = [119, 104, 121, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118];
  static const int panelButton = 128;
  static const int panelLeft = 129;
  static const int panelRight = 130;
  static const int muteCall = 481;

  static const int doorLitEmpty = 242;
  static const int bonnieAtDoor = 226;
  static const int chicaAtDoor = 227;
  static const int foxyAtDoor = 243;
  static const int doorAttackSprite = 60;

  static const int monitorFrame = 11;
  static const int monitorFlipBarTop = 156;
  static const int monitorFlipBarBottom = 162;
  static const List<int> monitorFlipDown = [141, 140, 139, 138, 137, 136, 133, 132, 144, 46, 142];

  static const int camMap = 164;
  static const int camButton = 166;
  static const int camButtonActive = 167;
  static const List<int> camMapLabels = [170, 171, 172, 165, 168, 169, 173, 174, 175, 176, 177];
  static const int markerBonnie = 63;
  static const int markerChica = 218;
  static const int markerFreddy = 356;
  static const int markerYou = 64;

  static const Map<String, int> camLabels = {
    'cam1a': 54, 'cam1b': 71, 'cam1c': 73, 'cam2a': 74, 'cam2b': 75,
    'cam3': 76, 'cam4a': 77, 'cam4b': 78, 'cam5': 50, 'cam6': 79, 'cam7': 80,
  };

  static const Map<String, List<int>> camViews = {
    'cam1a': [2, 68, 358],
    'cam1b': [48, 222],
    'cam1c': [66, 211, 240, 340],
    'cam2a': [44, 67],
    'cam2b': [62, 120],
    'cam3': [83],
    'cam4a': [217],
    'cam4b': [206, 205],
    'cam5': [355],
    'cam6': [41],
    'cam7': [49, 219],
  };

  static const Map<String, List<int>> camOccupants = {
    'bonnie': [90, 83],
    'chica': [69, 219, 220],
    'freddy': [120, 188],
    'foxy': [340],
  };

  static const List<int> foxyHallRun = [279, 280, 281, 282, 283, 284, 285, 286, 287, 288, 289, 290];
  static const List<int> foxySprint = [327, 329, 330, 331, 332, 333, 334, 335, 336, 337, 338];
  static const List<int> foxyDoorAttack = [396, 397, 398, 399, 400, 401, 402, 403, 404, 405, 406, 407];

  static const List<int> bonnieJumpscare = [291, 292, 293, 294, 295, 296, 297, 298, 299, 300, 301, 302, 303];
  static const List<int> chicaJumpscare = [228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 239];
  static const List<int> freddyJumpscare = [307, 308, 309, 310, 311, 312, 313, 314, 315, 316, 317, 318, 319, 320, 321, 322, 323, 324, 325];
  static const List<int> foxyJumpscare = [329, 330, 331, 332, 333, 334, 335, 336, 337, 338, 340, 354];
  static const List<int> goldenFreddyScare = [512, 513, 514, 515, 516, 517, 518, 519];

  static const int powerOutOffice = 307;
  static const int audioOnly = 41;

  static const List<int> clockDigits = [349, 350, 351, 352, 353, 354, 355, 356, 357];
  static const int amLabel = 251;
  static const int nightLabel = 447;

  static const List<int> customNightFaces = [524, 530, 531, 533, 534, 535];
  static const int aiArrowUp = 541;
  static const int aiArrowDown = 542;

  static const String sndJumpscare = 'XSCREAM';
  static const String sndJumpscare2 = 'XSCREAM2';
  static const String sndFan = 'Buzz_Fan_Florescent2';
  static const String sndMusicBox = 'music box';
  static const String sndPowerDown = 'Powerdown';
  static const String sndDoorPound = 'knock2';
  static const String sndDoor = 'door';
  static const String sndLight = 'BallastHum2';
  static const String sndCold = 'cold presc';
  static const String sndBlip = 'blip3';
  static const String sndCall = 'voiceover1';
}
