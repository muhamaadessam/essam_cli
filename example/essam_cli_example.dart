import 'dart:io';

void main() async {
  print('Essam CLI Example');
  print('=================');
  print('To use this CLI, you should run it directly from your terminal:');
  print('\n> essam create Authentication');
  print('\nOr you can run it programmatically:');

  // Example of running the CLI programmatically
  // NOTE: This will only work if the CLI is globally activated
  try {
    var result = await Process.run('essam', ['--help']);
    print('\nOutput of `essam --help`:');
    print(result.stdout);
  } catch (e) {
    print('\nCould not run CLI programmatically. Is it installed?');
  }
}
