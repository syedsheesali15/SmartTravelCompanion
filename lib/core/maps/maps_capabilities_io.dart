import 'dart:io' show Platform;

bool get googleMapsPlatformSupported => Platform.isAndroid || Platform.isIOS;
