import 'dart:math';

import 'package:flutter/foundation.dart';

abstract class GameRng {
  int nextInt(int max);
  bool nextBool();
  double nextDouble();
}

class SystemRng implements GameRng {
  final Random _r;
  SystemRng(this._r);
  @override
  int nextInt(int max) => _r.nextInt(max);
  @override
  bool nextBool() => _r.nextBool();
  @override
  double nextDouble() => _r.nextDouble();
}

enum Animatronic { freddy, bonnie, chica, foxy }

enum Room {
  showStage,
  diningArea,
  backstage,
  pirateCove,
  westHall,
  westHallCorner,
  supplyCloset,
  eastHall,
  eastHallCorner,
  restrooms,
  kitchen,
  leftDoor,
  rightDoor,
  office,
}

const camRooms = <String, Room>{
  'cam1a': Room.showStage,
  'cam1b': Room.diningArea,
  'cam1c': Room.pirateCove,
  'cam2a': Room.westHall,
  'cam2b': Room.westHallCorner,
  'cam3': Room.supplyCloset,
  'cam4a': Room.eastHall,
  'cam4b': Room.eastHallCorner,
  'cam5': Room.backstage,
  'cam6': Room.kitchen,
  'cam7': Room.restrooms,
};

const camOrder = [
  'cam1a', 'cam1b', 'cam1c', 'cam2a', 'cam2b',
  'cam3', 'cam4a', 'cam4b', 'cam5', 'cam6', 'cam7'
];

const bonniePath = [
  Room.showStage, Room.diningArea, Room.backstage, Room.westHall,
  Room.supplyCloset, Room.westHall, Room.westHallCorner, Room.leftDoor,
];

const chicaPath = [
  Room.showStage, Room.diningArea, Room.restrooms, Room.kitchen,
  Room.eastHall, Room.eastHallCorner, Room.rightDoor,
];

const freddyPath = [
  Room.showStage, Room.diningArea, Room.restrooms, Room.kitchen,
  Room.eastHall, Room.eastHallCorner, Room.rightDoor,
];

class NightConfig {
  static const List<Map<Animatronic, int>> ai = [
    {},
    {Animatronic.freddy: 0, Animatronic.bonnie: 3, Animatronic.chica: 2, Animatronic.foxy: 1},
    {Animatronic.freddy: 1, Animatronic.bonnie: 4, Animatronic.chica: 4, Animatronic.foxy: 3},
    {Animatronic.freddy: 2, Animatronic.bonnie: 5, Animatronic.chica: 5, Animatronic.foxy: 5},
    {Animatronic.freddy: 3, Animatronic.bonnie: 7, Animatronic.chica: 6, Animatronic.foxy: 6},
    {Animatronic.freddy: 4, Animatronic.bonnie: 8, Animatronic.chica: 8, Animatronic.foxy: 8},
    {Animatronic.freddy: 5, Animatronic.bonnie: 10, Animatronic.chica: 10, Animatronic.foxy: 10},
  ];

  static const double hourSeconds = 86.0;

  static const List<String> phoneCall = [
    '',
    'voiceover1c', 'voiceover2a', 'voiceover3', 'voiceover4', 'voiceover5', ''
  ];
}

class EngineEvents {
  void onJumpscare(Animatronic a) {}
  void onNightWin() {}
  void onPowerOut() {}
  void onDoorPound() {}
}

class GameEngine {
  final int night;
  final GameRng rng;
  EngineEvents events;

  double timeSeconds = 0;
  double power = 100;
  bool powerOut = false;
  double powerOutTimer = 0;
  bool officeDarkOut = false;

  bool leftDoorClosed = false;
  bool rightDoorClosed = false;
  bool leftLight = false;
  bool rightLight = false;
  bool monitorUp = false;
  String currentCam = 'cam1a';
  bool camTransitioning = false;

  final Map<Animatronic, int> pathIndex = {
    Animatronic.freddy: 0,
    Animatronic.bonnie: 0,
    Animatronic.chica: 0,
  };
  int foxyStage = 1;
  final Map<Animatronic, double> moveTimers = {
    Animatronic.freddy: 0,
    Animatronic.bonnie: 0,
    Animatronic.chica: 0,
    Animatronic.foxy: 0,
  };

  bool bonnieInOffice = false;
  bool chicaInOffice = false;
  bool freddyInside = false;
  double bonnieAttackTimer = 0;
  double chicaAttackTimer = 0;
  double freddyAttackTimer = 0;
  bool dead = false;
  bool won = false;
  Animatronic? jumpscareBy;
  double foxyRunCooldown = 0;

  static const moveInterval = {
    Animatronic.freddy: 3.02,
    Animatronic.bonnie: 4.97,
    Animatronic.chica: 4.98,
    Animatronic.foxy: 5.01,
  };

  GameEngine({required this.night, GameRng? rng, EngineEvents? events})
      : rng = rng ?? SystemRng(Random()),
        events = events ?? EngineEvents();

  @visibleForTesting
  void forceMove(Animatronic a) => _move(a, monitorUp ? currentCam : null);

  Map<Animatronic, int> get ai => NightConfig.ai[night.clamp(1, 6)];

  int get hour => (timeSeconds / NightConfig.hourSeconds).floor();
  String get clockLabel {
    final h = hour == 0 ? 12 : hour;
    return '$h:00';
  }

  Room roomOf(Animatronic a) {
    switch (a) {
      case Animatronic.bonnie:
        return bonniePath[pathIndex[a]!.clamp(0, bonniePath.length - 1)];
      case Animatronic.chica:
        return chicaPath[pathIndex[a]!.clamp(0, chicaPath.length - 1)];
      case Animatronic.freddy:
        return freddyPath[pathIndex[a]!.clamp(0, freddyPath.length - 1)];
      case Animatronic.foxy:
        return Room.pirateCove;
    }
  }

  int get usageLevel {
    var u = 1;
    if (leftDoorClosed) u++;
    if (rightDoorClosed) u++;
    if (leftLight || rightLight) u++;
    if (monitorUp) u++;
    return u;
  }

  static const List<double> drainPerSecond = [0, 0.08, 0.12, 0.17, 0.23, 0.30];

  void tick(double dt) {
    if (dead || won) return;
    if (powerOut) {
      powerOutTimer += dt;
      if (powerOutTimer > 5 && !officeDarkOut) {
        officeDarkOut = true;
      }
      if (powerOutTimer > 20 && rng.nextInt(100) < 2) {
        _kill(Animatronic.freddy);
      }
      return;
    }
    timeSeconds += dt;
    if (hour >= 6) {
      won = true;
      events.onNightWin();
      return;
    }
    power -= drainPerSecond[usageLevel] * dt;
    if (power <= 0) {
      power = 0;
      powerOut = true;
      leftDoorClosed = rightDoorClosed = false;
      leftLight = rightLight = false;
      monitorUp = false;
      events.onPowerOut();
      return;
    }
    _tickAnimatronics(dt);
    _tickAttacks(dt);
    if (foxyRunCooldown > 0) foxyRunCooldown -= dt;
    if (camTransitioning) camTransitioning = false;
  }

  void _tickAnimatronics(double dt) {
    final watchedCam = monitorUp ? currentCam : null;
    for (final a in Animatronic.values) {
      moveTimers[a] = moveTimers[a]! + dt;
      if (moveTimers[a]! < moveInterval[a]!) continue;
      moveTimers[a] = 0;
      final roll = rng.nextInt(20) + 1;
      if (roll > (ai[a] ?? 0)) continue;
      _move(a, watchedCam);
    }
  }

  void _move(Animatronic a, String? watchedCam) {
    switch (a) {
      case Animatronic.bonnie:
        if (bonnieInOffice) return;
        if (pathIndex[a]! < bonniePath.length - 1) {
          pathIndex[a] = pathIndex[a]! + 1;
          if (roomOf(a) == Room.leftDoor && leftDoorClosed) {
            pathIndex[a] = 1 + rng.nextInt(2);
          }
        } else if (!leftDoorClosed) {
          bonnieInOffice = true;
          bonnieAttackTimer = 5 + rng.nextDouble() * 10;
        }
      case Animatronic.chica:
        if (chicaInOffice) return;
        if (pathIndex[a]! < chicaPath.length - 1) {
          pathIndex[a] = pathIndex[a]! + 1;
          if (roomOf(a) == Room.rightDoor && rightDoorClosed) {
            pathIndex[a] = 1 + rng.nextInt(2);
          }
        } else if (!rightDoorClosed) {
          chicaInOffice = true;
          chicaAttackTimer = 5 + rng.nextDouble() * 10;
        }
      case Animatronic.freddy:
        if (freddyInside) return;
        if (watchedCam != null && camRooms[watchedCam] == roomOf(a)) return;
        if (pathIndex[a]! < freddyPath.length - 1) {
          pathIndex[a] = pathIndex[a]! + 1;
        } else if (!rightDoorClosed) {
          freddyInside = true;
          freddyAttackTimer = 15 + rng.nextDouble() * 15;
        }
      case Animatronic.foxy:
        if (foxyRunCooldown > 0) return;
        if (watchedCam == 'cam1c' && rng.nextBool()) return;
        if (foxyStage < 4) {
          foxyStage++;
        } else {
          foxyStage = 1;
          foxyRunCooldown = 25;
          if (leftDoorClosed) {
            power = (power - 1).clamp(0, 100);
            events.onDoorPound();
          } else {
            _kill(Animatronic.foxy);
          }
        }
    }
  }

  void _tickAttacks(double dt) {
    if (bonnieInOffice) {
      bonnieAttackTimer -= dt;
      if (bonnieAttackTimer <= 0) _kill(Animatronic.bonnie);
    }
    if (chicaInOffice) {
      chicaAttackTimer -= dt;
      if (chicaAttackTimer <= 0) _kill(Animatronic.chica);
    }
    if (freddyInside) {
      freddyAttackTimer -= dt;
      if (freddyAttackTimer <= 0) _kill(Animatronic.freddy);
    }
  }

  void _kill(Animatronic a) {
    if (dead || won) return;
    dead = true;
    jumpscareBy = a;
    events.onJumpscare(a);
  }

  void toggleLeftDoor() {
    if (powerOut) return;
    leftDoorClosed = !leftDoorClosed;
    if (leftDoorClosed && bonnieInOffice) {
      bonnieInOffice = false;
      pathIndex[Animatronic.bonnie] = 1;
    }
  }

  void toggleRightDoor() {
    if (powerOut) return;
    rightDoorClosed = !rightDoorClosed;
    if (rightDoorClosed && chicaInOffice) {
      chicaInOffice = false;
      pathIndex[Animatronic.chica] = 1;
    }
  }

  void toggleMonitor() {
    if (powerOut) return;
    monitorUp = !monitorUp;
    camTransitioning = true;
  }

  void selectCam(String cam) {
    if (powerOut || !monitorUp) return;
    if (currentCam != cam) {
      currentCam = cam;
      camTransitioning = true;
    }
  }

  bool lightSeesLeft() =>
      leftLight && roomOf(Animatronic.bonnie) == Room.leftDoor;
  bool lightSeesRight() =>
      rightLight && roomOf(Animatronic.chica) == Room.rightDoor;

  Set<Animatronic> occupantsOf(Room r) {
    final s = <Animatronic>{};
    for (final a in [Animatronic.bonnie, Animatronic.chica, Animatronic.freddy]) {
      if (roomOf(a) == r) s.add(a);
    }
    if (r == Room.pirateCove && foxyStage > 1) s.add(Animatronic.foxy);
    return s;
  }
}
