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
  int compareTo(Version other) {
    if (major != other.major) return major - other.major;
    if (minor != other.minor) return minor - other.minor;
    return patch - other.patch;
  }

  bool operator >(Version other) => compareTo(other) > 0;
  @override
  String toString() => '$major.$minor.$patch';
  @override
  bool operator ==(Object other) =>
      other is Version &&
      major == other.major &&
      minor == other.minor &&
      patch == other.patch;
  @override
  int get hashCode => Object.hash(major, minor, patch);
}
