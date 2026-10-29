import 'dart:convert';
import 'dart:typed_data';

class ByteReader {
  ByteReader(this._data, [this._offset = 0, int? length])
      : _end = length == null ? _data.length : _offset + length;

  final Uint8List _data;
  int _offset;
  final int _end;

  int get position => _offset;
  int get remaining => _end - _offset;
  bool get done => _offset >= _end;

  void seek(int position) {
    if (position < 0 || position > _end) {
      throw RangeError.range(position, 0, _end);
    }
    _offset = position;
  }

  void skip(int bytes) => seek(_offset + bytes);

  bool hasMemory(int size) => remaining >= size;

  int readByte() => _data[_offset++];

  int readShort() {
    final v = _data[_offset] | (_data[_offset + 1] << 8);
    _offset += 2;
    return v >= 0x8000 ? v - 0x10000 : v;
  }

  int readUShort() {
    final v = _data[_offset] | (_data[_offset + 1] << 8);
    _offset += 2;
    return v;
  }

  int readInt() {
    final v = ByteData.sublistView(_data, _offset, _offset + 4)
        .getInt32(0, Endian.little);
    _offset += 4;
    return v;
  }

  int readUInt() {
    final v = ByteData.sublistView(_data, _offset, _offset + 4)
        .getUint32(0, Endian.little);
    _offset += 4;
    return v;
  }

  int peekInt() => ByteData.sublistView(_data, _offset, _offset + 4)
      .getInt32(0, Endian.little);

  int peekShort() {
    final v = _data[_offset] | (_data[_offset + 1] << 8);
    return v >= 0x8000 ? v - 0x10000 : v;
  }

  Uint8List readBytes([int count = -1]) {
    final n = count < 0 ? remaining : count;
    final out = Uint8List.sublistView(_data, _offset, _offset + n);
    _offset += n;
    return out;
  }

  String readAscii([int length = -1]) {
    if (length < 0) {
      final start = _offset;
      while (_offset < _end && _data[_offset] != 0) {
        _offset++;
      }
      if (_offset < _end) _offset++;
      return latin1.decode(
          Uint8List.sublistView(_data, start, _offset - 1), allowInvalid: true);
    }
    final s = latin1.decode(readBytes(length), allowInvalid: true);
    return s.replaceAll('\x00', '');
  }

  String readAsciiStop(int length) {
    final s = readAscii(length);
    final i = s.indexOf('\x00');
    return i < 0 ? s : s.substring(0, i);
  }

  String readYunicode([int length = -1]) {
    final units = <int>[];
    if (length < 0) {
      while (_offset + 1 < _end) {
        final u = _data[_offset] | (_data[_offset + 1] << 8);
        _offset += 2;
        if (u == 0) break;
        units.add(u);
      }
    } else {
      for (var i = 0; i < length; i++) {
        units.add(readUShort());
      }
    }
    var s = String.fromCharCodes(units);
    final i = s.indexOf('\x00');
    if (i >= 0) s = s.substring(0, i);
    return s;
  }

  String readYuniversal([int length = -1]) => readYunicode(length);

  String readYuniversalStop(int length) {
    final s = readYunicode(length);
    final i = s.indexOf('\x00');
    return i < 0 ? s : s.substring(0, i);
  }
}
