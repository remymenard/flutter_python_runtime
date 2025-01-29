import 'dart:io';

/// Gets the appropriate micromamba download URL based on the current platform
String getMicromambaUrl() {
  const String baseUrl = 'https://micro.mamba.pm/api/micromamba';
  
  if (Platform.isWindows) {
    return '$baseUrl/win-64/latest';
  } else if (Platform.isLinux) {
    if (Platform.version.contains('arm64')) {
      return '$baseUrl/linux-aarch64/latest';
    } else if (Platform.version.contains('ppc64')) {
      return '$baseUrl/linux-ppc64le/latest';
    }
    return '$baseUrl/linux-64/latest';
  } else if (Platform.isMacOS) {
    if (Platform.version.contains('arm64')) {
      return '$baseUrl/osx-arm64/latest';
    }
    return '$baseUrl/osx-64/latest';
  }
  throw UnsupportedError('Unsupported platform for micromamba installation');
} 