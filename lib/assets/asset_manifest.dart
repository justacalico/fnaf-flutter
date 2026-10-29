class Assets {
  static const List<int> staticNoise = [11, 12, 13, 14, 15, 16, 17, 19, 21];

  static const int titleBg = 396;
  static const int menuFreddy = 440;
  static const int menuFreddyAlt = 439;
  static const int copyright = 468;
  static const int star = 473;
  static const int newspaper = 574;
  static const int warningText = 601;
  static const int gameOver = 481;
  static const int theEnd = 210;
  static const int fiveAm = 571;

  static const List<int> clockDigits = [120, 121, 122, 123, 124, 125, 126, 127, 128, 129];
  static const List<int> nightDigits = [25, 26, 27, 28, 29, 30, 31, 32, 33, 34];
  static const int amLabel = 37;
  static const int powerLeft = 196;
  static const int usageLabel = 200;
  static const List<int> usageBars = [216, 217, 218, 219, 220];

  static const int officeBase = 62;
  static const int officePan = 41;
  static const int doorLeftPanel = 125;
  static const int doorLeftDoorClosed = 130;
  static const int doorLeftLit = 135;
  static const int doorFrame = 115;
  static const int camMap = 149;
  static const int monitorFlip = 136;

  static const int camButton = 81;

  static const Map<String, int> camLabels = {
    'cam1a': 170,
    'cam1b': 171,
    'cam1c': 172,
    'cam2a': 173,
    'cam2b': 165,
    'cam3': 174,
    'cam4a': 166,
    'cam4b': 167,
    'cam5': 168,
    'cam6': 175,
    'cam7': 169,
  };

  static const Map<String, List<int>> camViews = {
    'cam1a': [58, 59, 60],
    'cam1b': [90, 215, 216, 217, 221, 226, 227],
    'cam1c': [39, 66, 211, 222],
    'cam2a': [67, 245, 246, 247, 248, 250],
    'cam2b': [43, 44, 279, 284],
    'cam3': [46, 48],
    'cam4a': [120, 310, 311, 312, 358],
    'cam4b': [241, 242, 282],
    'cam5': [41, 68, 83, 188, 220, 223],
    'cam6': [190, 320],
    'cam7': [126, 127],
  };

  static const Map<String, List<int>> camAnimatronic = {
    'bonnie': [216, 217, 250, 295, 305],
    'chica': [220, 226, 227, 281],
    'freddy': [215, 206, 224],
    'foxy': [305, 345, 348, 354],
  };

  static const List<int> bonnieJumpscare = [296, 297, 298, 299, 300, 301, 302, 303, 304];
  static const List<int> chicaJumpscare = [228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 239];
  static const List<int> freddyJumpscare = [323, 324, 325, 326, 327, 329, 330, 331, 332, 333, 334, 335];
  static const List<int> foxyJumpscare = [355, 356, 357];
  static const int bonnieAtDoor = 322;
  static const int chicaAtDoor = 281;
  static const int freddyAtDoor = 325;
  static const int foxyRunning = 305;

  static const String sndJumpscare = 'XSCREAM';
  static const String sndJumpscare2 = 'XSCREAM2';
  static const String sndFan = 'Buzz_Fan_Florescent2';
  static const String sndMusicBox = 'music box';
  static const String sndCircus = 'circus';
  static const String sndDoorPound = 'DOOR_POUNDING_ME_D0291401';
  static const String sndWindowscare = 'windowscare';
  static const String sndError = 'error';
  static const String sndBlip = 'blip3';
  static const String sndCameraLoad = 'CAMERA_VIDEO_LOA_60105303';
  static const String sndPowerDown = 'powerdown';
  static const String sndStatic = 'static';
  static const String sndStatic2 = 'static2';
  static const String sndRun = 'run';
  static const String sndRunningFast = 'running fast3';
  static const String sndKnock = 'knock2';
  static const String sndDeepSteps = 'deep steps';
  static const String sndChimes = 'chimes 2';
  static const String sndDarkness = 'darkness music';
  static const String sndGarble1 = 'garble1';
  static const String sndGarble2 = 'garble2';
  static const String sndGarble3 = 'garble3';
  static const String sndLaugh1 = 'Laugh_Giggle_Girl_1d';
  static const String sndLaugh2 = 'Laugh_Giggle_Girl_2d';
  static const String sndLaugh8 = 'Laugh_Giggle_Girl_8d';
  static const String sndWhisper = 'whispering2';
  static const String sndCrowd = 'CROWD_SMALL_CHIL_EC049202';
  static const String sndBreaths = 'Vocals_Breaths_S_35972006';
  static const String sndVoice1 = 'voiceover1c';
  static const String sndVoice2 = 'voiceover2a';
  static const String sndVoice3 = 'voiceover3';
  static const String sndVoice4 = 'voiceover4';
  static const String sndVoice5 = 'voiceover5';
  static const String sndParty = 'PartyFavorraspyPart_AC01__3';
  static const String sndEerie = 'EerieAmbienceLargeSca_MV005';
  static const String sndCold = 'ColdPresc B';
  static const String sndBallast = 'BallastHumMedium2';
  static const String sndPutDown = 'put down';
  static const String sndOven1 = 'OVEN-DRA_1_GEN-HDF18119';
  static const String sndOven2 = 'OVEN-DRA_2_GEN-HDF18120';
  static const String sndOven7 = 'OVEN-DRA_7_GEN-HDF18121';
  static const String sndOvenDrawer = 'OVEN-DRAWE_GEN-HDF18122';
  static const String sndMiniDv = 'MiniDV_Tape_Eject_1';
  static const String sndComputer = 'COMPUTER_DIGITAL_L2076505';
  static const String sndSfx = 'SFXBible_12478';
  static const String sndRobot = 'robotvoice';
  static const String sndPirate = 'pirate song2';
  static const String sndAmbience = 'ambience2';
}
