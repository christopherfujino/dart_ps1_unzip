import 'dart:io' as io;

import 'package:file/local.dart';
import 'package:file/src/interface/file.dart';
import 'package:process/process.dart';

const LocalFileSystem fs = LocalFileSystem();
final File unzipper = fs.file('unzipPowershell.ps1');
final processManager = LocalProcessManager();

Future<void> main(List<String> args) async {
  if (args.length != 1) {
    io.stderr.writeln('Bad usage!');
    io.exit(1);
  }
  final String input = args.first;

  _runPowershellScript(<String>[unzipper.absolute.path, input]);
  print('success');
}

Future<void> _runPowershellScript(List<String> command) async {
  final String binary = command.first;
  final List<String> args = command.sublist(1);
  final List<String> powershellCommand = <String>[
      'PowerShell.exe', // TODO discover name
      '-ExecutionPolicy',
      'Bypass',
      '-NoProfile',
      '-Command',
      // TODO LastExitCode not piping through
      "Unblock-File -Path '$binary'; & '$binary' ${args.map((arg) => '$arg').join(' ')}; Exit \$LastExitCode",
      //"Unblock-File -Path '$binary'; & '$binary'; Exit \$LastExitCode",
    ];
  final io.Process process = await processManager.start(
    powershellCommand,
    mode: io.ProcessStartMode.inheritStdio,
  );

  if ((await process.exitCode) != 0) {
    io.stderr.writeln('Failed to bypass execution policy for unzip.ps1');
    io.exit(1);
  }

  // TODO not catching failures
}
