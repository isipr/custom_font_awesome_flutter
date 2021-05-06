import 'dart:convert';
import 'dart:io';

import 'package:recase/recase.dart';

const Map<String, String> nameAdjustments = {
  "500px": "fiveHundredPx",
  "1": "one",
  "2": "two",
  "3": "three",
  "4": "four",
  "5": "five",
  "6": "six",
  "7": "seven",
  "8": "eight",
  "9": "nine",
  "0": "zero",
};

void main(List<String> arguments) {
  var file = new File(arguments.first);

  if (!file.existsSync()) {
    print('Cannot find the file "${arguments.first}".');
  }

  var content = file.readAsStringSync();
  Map<String, dynamic> icons = json.decode(content);

  Map<String, String> iconDefinitions = {};

  for (String iconName in icons.keys) {
    var icon = icons[iconName];

    // At least one icon does not have a glyph in the font files. This property
    // is marked with "private": true in icons.json
    if((icon as Map<String, dynamic>).containsKey('private') && icon['private'])
      continue;

    List<String> styles = (icon['styles'] as List).cast<String>();

    if (styles.length > 1) {
      if (styles.contains('regular')) {
        styles.remove('regular');
        iconDefinitions[iconName] = generateExampleIcon(iconName);
      }

      for (String style in styles) {
        String name = '${style}_$iconName';
        iconDefinitions[name] = generateExampleIcon(name);
      }
    } else {
      iconDefinitions[iconName] = generateExampleIcon(iconName);
    }
  }

  List<String> generatedOutput = [
    '',
    "import 'package:font_awesome_flutter/font_awesome_flutter.dart';",
    "import 'package:font_awesome_flutter_example/example_icon.dart';",
    '',
    '// THIS FILE IS AUTOMATICALLY GENERATED!',
    '',
    'final icons = <ExampleIcon>[',
  ];

  generatedOutput.addAll(iconDefinitions.values);

  generatedOutput.add('];');

  File output = new File('example/lib/icons.dart');
  output.writeAsStringSync(generatedOutput.join('\n'));
}

String generateExampleIcon(String iconName) {
  if(nameAdjustments.containsKey(iconName)) {
    iconName = nameAdjustments[iconName]!;
  }

  iconName = new ReCase(iconName).camelCase;

  return "ExampleIcon(FontAwesomeIcons.$iconName, '$iconName'),";
}
