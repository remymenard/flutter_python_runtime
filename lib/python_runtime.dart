import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:archive/archive.dart';
import 'micromamba_urls.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

/// A Python runtime manager that handles micromamba installation and environment setup.
class PythonRuntime {
  /// Gets the path to the micromamba executable, copying it from the bundle if needed
  Future<String> _getMicromambaPath() async {
  if (Platform.isMacOS) {
    final home = Platform.environment['HOME'];
    if (home == null) {
      throw Exception('Could not determine HOME directory');
    }
    
    // Use ~/.micromamba instead of Application Support
    final micromambaDir = Directory(path.join(home, '.micromamba', 'bin'));
    final micromambaPath = path.join(micromambaDir.path, 'micromamba');
    final micromambaFile = File(micromambaPath);

    if (!micromambaFile.existsSync()) {
      try {
        // Create the directory if it doesn't exist
        await micromambaDir.create(recursive: true);

        // Copy the bundled executable
        final bytes = await rootBundle.load(
          'packages/python_runtime/assets/micromamba/micromamba-osx-64'
        );
        await micromambaFile.writeAsBytes(bytes.buffer.asUint8List());
        
        // Make it executable and verify the operation
        final chmodResult = await Process.run('chmod', ['+x', micromambaPath]);
        if (chmodResult.exitCode != 0) {
          throw Exception('chmod failed: ${chmodResult.stderr}');
        }

        // Verify we can execute it
        final testResult = await Process.run(micromambaPath, ['--version']);
        if (testResult.exitCode != 0) {
          throw Exception('Micromamba test failed: ${testResult.stderr}');
        }
      } catch (e) {
        throw Exception('Failed to setup micromamba: $e');
      }
    }
    return micromambaPath;
  } else {
    final appDocDir = await getApplicationDocumentsDirectory();
    return path.join(appDocDir.path, 'micromamba', 'bin', 'micromamba');
  }
}

  /// Downloads and extracts micromamba if it doesn't exist
  Future<void> downloadMicromamba() async {
    final micromambaPath = await _getMicromambaPath();
    final micromambaFile = File(micromambaPath);

    // Check if micromamba already exists
    if (micromambaFile.existsSync()) {
      return; // Micromamba already available
    }

    if (Platform.isMacOS) {
      // On macOS, we should have copied it from the bundle
      throw Exception('Micromamba not found in bundle');
    }

    // For other platforms, download it
    final downloadParams = {
      'url': getMicromambaUrl(),
      'targetDir': path.dirname(path.dirname(micromambaPath)),
      'micromambaPath': micromambaPath,
    };

    try {
      await compute(_downloadAndExtractMicromamba, downloadParams);
    } catch (e) {
      throw Exception('Failed to download micromamba in isolate: $e');
    }
  }

  /// Creates a new Mamba environment with the specified name and Python version
  Future<void> createMambaEnvironment(
      String envName, String pythonVersion) async {
    final micromambaPath = await _getMicromambaPath();
    final micromambaFile = File(micromambaPath);

    // Check if micromamba exists
    if (!micromambaFile.existsSync()) {
      throw Exception(
          'Micromamba not found. Please run downloadMicromamba() first.');
    }

    // Create the environment parameters
    final envParams = {
      'micromambaPath': micromambaPath,
      'envName': envName,
      'pythonVersion': pythonVersion,
    };

    try {
      await compute(_createMambaEnvironment, envParams);
    } catch (e) {
      throw Exception('Failed to create Mamba environment: $e');
    }
  }
}

/// Isolate function to handle downloading and extracting micromamba
Future<void> _downloadAndExtractMicromamba(Map<String, String> params) async {
  final url = params['url']!;
  final targetDir = params['targetDir']!;
  final micromambaPath = params['micromambaPath']!;
  final micromambaFile = File(micromambaPath);

  // Create the target directory if it doesn't exist
  final directory = Directory(targetDir);
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }

  try {
    // Download the file with timeout
    final response = await http.get(
      Uri.parse(url),
      headers: {'User-Agent': 'Dart/PythonRuntime'},
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw TimeoutException('Connection timed out'),
    );

    debugPrint('Downloaded micromamba');

    if (response.statusCode != 200) {
      throw HttpException(
        'Failed to download micromamba: ${response.statusCode}',
        uri: Uri.parse(url),
      );
    }

    // Decompress the bzip2 archive
    final bzip2Data = BZip2Decoder().decodeBytes(response.bodyBytes);
    debugPrint('Decompressed micromamba');

    // Extract the tar archive
    final archive = TarDecoder().decodeBytes(bzip2Data);
    debugPrint('Extracted micromamba');

    // Find and extract the micromamba binary
    final micromambaFileInArchive = archive.findFile('bin/micromamba');
    if (micromambaFileInArchive == null) {
      throw Exception('Micromamba binary not found in archive');
    }

    debugPrint('Found micromamba in archive');

    // Write the binary to the target location
    await micromambaFile.parent.create(recursive: true);
    await micromambaFile
        .writeAsBytes(micromambaFileInArchive.content as List<int>);
    debugPrint('Wrote micromamba to target location');

    // Make the binary executable on Unix-like systems
    if (!Platform.isWindows) {
      final result = await Process.run('chmod', ['+x', micromambaFile.path]);
      if (result.exitCode != 0) {
        throw Exception(
            'Failed to set executable permissions: ${result.stderr}');
      }
      debugPrint('Made micromamba executable');
    }
  } on SocketException catch (e) {
    throw Exception(
      'Network error while downloading micromamba: ${e.message}\n'
      'Please check your internet connection and firewall settings. You might need to setup your platform to allow network access. Read the README for more information.',
    );
  } on HttpException catch (e) {
    throw Exception(
      'HTTP error while downloading micromamba: ${e.message}',
    );
  } catch (e) {
    throw Exception(
      'Unexpected error while downloading micromamba: $e',
    );
  }
}

/// Isolate function to handle creating the Mamba environment
Future<void> _createMambaEnvironment(Map<String, String> params) async {
  final micromambaPath = params['micromambaPath']!;
  final envName = params['envName']!;
  final pythonVersion = params['pythonVersion']!;

  try {
    // Ensure the micromamba binary is executable
    // if (!Platform.isWindows) {
    //   // First, try to make it executable
    //   try {
    //     await Process.run('chmod', ['+x', micromambaPath]);
    //   } catch (e) {
    //     debugPrint('Warning: Could not set executable permissions: $e');
    //   }

    //   // Verify the file permissions
    //   final stat = await File(micromambaPath).stat();
    //   debugPrint('File permissions: ${stat.mode}');
    // }

    final baseDir = path.dirname(path.dirname(micromambaPath));
    final env = {
      'MAMBA_ROOT_PREFIX': baseDir,
      'CONDA_PKGS_DIRS': path.join(baseDir, 'pkgs'),
      'CONDA_ENVS_DIRS': path.join(baseDir, 'envs'),
      // Add PATH to ensure system commands are available
      'PATH': Platform.environment['PATH'] ?? '',
      // Add HOME to ensure proper user context
      'HOME': Platform.environment['HOME'] ?? '',
    };

    debugPrint('Running micromamba with environment: $env');
    debugPrint(
        'Command: $micromambaPath create -n $envName python=$pythonVersion -y --quiet');

    // Run micromamba create command with full path
    final result = await Process.run(
      micromambaPath,
      [
        'create',
        '-n',
        envName,
        'python=$pythonVersion',
        '-y',
        '--quiet',
        '--debug', // Add debug output to see more details
      ],
      environment: env,
      runInShell: true,
      includeParentEnvironment: true, // Include parent environment variables
    );

    debugPrint('Process completed with exit code: ${result.exitCode}');
    debugPrint('Stdout: ${result.stdout}');
    debugPrint('Stderr: ${result.stderr}');

    if (result.exitCode != 0) {
      // Try to get more information about the binary
      final fileInfo = await Process.run('file', [micromambaPath]);
      debugPrint('File info: ${fileInfo.stdout}');

      throw Exception(
        'Failed to create environment:\n'
        'Exit code: ${result.exitCode}\n'
        'Stdout: ${result.stdout}\n'
        'Stderr: ${result.stderr}',
      );
    }

    debugPrint(
        'Successfully created Mamba environment "$envName" with Python $pythonVersion');
  } catch (e) {
    debugPrint('Error details: $e');
    throw Exception('Error creating Mamba environment: $e');
  }
}
