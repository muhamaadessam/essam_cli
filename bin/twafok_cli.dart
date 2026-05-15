#!/usr/bin/env dart

import 'dart:io';
import 'package:twafok_cli/commands/add_usecase_command.dart';
import 'package:twafok_cli/commands/create_feature_command.dart';
import 'package:twafok_cli/commands/generate_di_command.dart';
import 'package:twafok_cli/commands/generate_paths_command.dart';

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    _printUsage();
    return;
  }

  final command = arguments[0];
  final args = arguments.skip(1).toList();
  final currentDir = Directory.current.path;

  switch (command) {
    case 'create_feature':
    case 'create':
    case 'cr':
      final cli = CreateFeatureCommand();
      cli.run(args, workingDirectory: currentDir);
      break;

    case 'add_usecase':
    case 'add-use-case':
    case 'add':
      final cli = AddUsecaseCommand();
      cli.run(args, workingDirectory: currentDir);
      break;

    case 'generate_di':
    case 'gen-di':
      final cli = GenerateDiCommand();
      cli.run(args, workingDirectory: currentDir);
      break;

    case 'generate_paths':
    case 'gen-paths':
    case 'gen-barrel':
      final cli = GeneratePathsCommand();
      cli.run(args, workingDirectory: currentDir);
      break;

    case 'help':
    case '--help':
    case '-h':
      _printUsage();
      break;

    default:
      print('❌ Unknown command: $command');
      print('');
      print('Available commands:');
      print('  create, create_feature  - Create a complete feature');
      print('  add_usecase, add        - Add a new UseCase to a feature');
      print('  generate_di, gen-di     - Generate dependency injection file');
      print('  generate_paths, gen-paths - Generate barrel file');
      print('');
      print('Run "twafok help" for more information');
      exit(1);
  }
}

void _printUsage() {
  print('''
╔══════════════════════════════════════════════════════════╗
║                    Twafok CLI - Usage                     ║
╚══════════════════════════════════════════════════════════╝

Commands:
  create, create_feature  Create a complete feature
  add_usecase, add        Add a new UseCase to a feature
  generate_di, gen-di     Generate dependency injection file
  generate_paths, gen-paths Generate barrel file

Examples:
  # Create a new feature
  twafok_cli create Profile
  twafok_cli create_feature Authentication
  
  # Add UseCase to feature
  twafok_cli add_usecase lib/features/Profile update_profile
  twafok_cli add update_profile (from inside Profile folder)
  
  # Generate DI and barrel files
  twafok_cli gen-di lib/features/Profile
  twafok_cli gen-paths (from inside feature folder)

For help on specific commands:
  twafok <command> --help
''');
}