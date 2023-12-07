import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

void main(List<String> arguments) async {
  final parser = ArgParser();
  parser.addOption('file');
  parser.addFlag('c');
  parser.addFlag('l');
  parser.addFlag('w');
  parser.addFlag('m');

  final results = parser.parse(arguments);

  var path = arguments.last;

  if (!await FileSystemEntity.isFile(path)) {
    path = '_test.txt';
    final newFile = File(path);
    stdin.pipe(newFile.openWrite());
  }

  final file = File(path);

  if (results['c']) {
    final size = file.lengthSync();
    printResult(size, path);
  } else if (results['l']) {
    final linesCount = await countLines(file, path);
    printResult(linesCount, path);
  } else if (results['w']) {
    int count = await countWords(file);
    printResult(count, path);
  } else if (results['m']) {
    int count = await countChars(file);
    printResult(count, path);
  } else {
    int chars = await countChars(file);
    final totalLines = await countLines(file, path);
    int words = await countWords(file);
    stdout.write(
        '$totalLines $words $chars ${path != '_test.txt' ? path : ''}\n');
  }

  if (path == '_test.txt') {
    file.delete();
  }
}

void printResult(int count, String? path) {
  stdout.write('$count ${path != '_test.txt' ? path : ''}\n');
}

Future<int> countChars(File file) async {
  final lines = file.openRead().transform(
        utf8.decoder,
      );
  var count = 0;
  await for (final line in lines) {
    count += line.length;
  }
  return count; // EOF
}

Future<int> countWords(File file) async {
  final lines = file
      .openRead()
      .transform(
        utf8.decoder,
      )
      .transform(
        LineSplitter(),
      );

  var count = 0;

  await for (final line in lines) {
    final words = line.trim().split(RegExp(' +'));
    count += words.length;
  }
  return count;
}

Future<int> countLines(File file, String path) async {
  final lines = await file.readAsLines();
  return lines.length;
}
