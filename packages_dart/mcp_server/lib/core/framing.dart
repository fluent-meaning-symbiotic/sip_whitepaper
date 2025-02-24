import 'dart:typed_data';

import '../common_imports.dart';

/// Encodes a message as a length-prefixed JSON byte array
List<int> encodeMessage(Map<String, dynamic> message) {
  final jsonBytes = utf8.encode(json.encode(message));
  final length = jsonBytes.length;

  final buffer = ByteData(4 + length);
  buffer.setUint32(0, length, Endian.big);
  final list = buffer.buffer.asUint8List();
  list.setRange(4, 4 + length, jsonBytes);

  return list;
}

/// Decodes a length-prefixed JSON message from a stream of bytes
Future<Map<String, dynamic>> decodeMessage(Stream<List<int>> stream) async {
  final controller = StreamController<List<int>>();
  final lengthBytes = await stream
      .take(4)
      .fold<List<int>>([], (previous, element) => [...previous, ...element]);

  if (lengthBytes.length < 4) {
    throw FormatException('Incomplete message length prefix');
  }

  final length = ByteData.sublistView(
    Uint8List.fromList(lengthBytes),
  ).getUint32(0, Endian.big);

  final messageBytes = await stream
      .take(length)
      .fold<List<int>>([], (previous, element) => [...previous, ...element]);

  if (messageBytes.length < length) {
    throw FormatException('Incomplete message body');
  }

  final messageString = utf8.decode(messageBytes);
  try {
    return json.decode(messageString) as Map<String, dynamic>;
  } catch (e) {
    throw FormatException('Invalid JSON message: $e');
  }
}
