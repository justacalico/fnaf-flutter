import 'dart:typed_data';

import 'package:archive/archive.dart';

bool isZlib(Uint8List data) {
  if (data.length < 2 || data[0] != 0x78) return false;
  return data[1] == 0x01 || data[1] == 0x5E || data[1] == 0x9C || data[1] == 0xDA;
}

Uint8List decompressBlock(Uint8List data) {
  if (isZlib(data)) {
    return Uint8List.fromList(const ZLibDecoder().decodeBytes(data));
  }
  final inflater = Inflate(data);
  return Uint8List.fromList(inflater.getBytes());
}

Uint8List lz4Decompress(Uint8List input, int outputLength) {
  final out = Uint8List(outputLength);
  var ip = 0;
  var op = 0;
  while (ip < input.length) {
    final token = input[ip++];
    var literalLen = token >> 4;
    if (literalLen == 15) {
      int b;
      do {
        b = input[ip++];
        literalLen += b;
      } while (b == 255);
    }
    out.setRange(op, op + literalLen, input, ip);
    ip += literalLen;
    op += literalLen;
    if (ip >= input.length) break;
    final offset = input[ip] | (input[ip + 1] << 8);
    ip += 2;
    var matchLen = token & 0xF;
    if (matchLen == 15) {
      int b;
      do {
        b = input[ip++];
        matchLen += b;
      } while (b == 255);
    }
    matchLen += 4;
    for (var i = 0; i < matchLen; i++) {
      out[op] = out[op - offset];
      op++;
    }
  }
  return out;
}
