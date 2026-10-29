class Version implements Comparable<Version> {
  final int major;
  final int minor;
  final int patch;
  const Version(this.major, this.minor, this.patch);

  static Version? parse(String s) {
    if (s.startsWith('v')) s = s.substring(1);
    final m = RegExp(r'^(\d+)\.(\d+)\.(\d+)').firstMatch(s);
    if (m == null) return null;
    return Version(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!));
  }

  @override
  int compareTo(Version o) {
    if (major != o.major) return major - o.major;
    if (minor != o.minor) return minor - o.minor;
    return patch - o.patch;
  }

  bool operator >(Version o) => compareTo(o) > 0;
  @override
  String toString() => '$major.$minor.$patch';
  @override
  bool operator ==(Object o) =>
      o is Version && major == o.major && minor == o.minor && patch == o.patch;
  @override
  int get hashCode => Object.hash(major, minor, patch);
}
