import 'dart:convert';
import 'dart:io';

const _configPath = 'firebase_config.local.json';
const _androidOutputPath = 'android/app/google-services.json';
const _iosOutputPath = 'ios/Runner/GoogleService-Info.plist';
const _androidPackageName = 'com.example.sushi_restaurant';

void main() {
  final configFile = File(_configPath);
  if (!configFile.existsSync()) {
    throw StateError(
      'Missing $_configPath. Copy firebase_config.example.json to '
      '$_configPath and fill in real Firebase values first.',
    );
  }

  final config = _readConfig(configFile);
  _writeAndroidConfig(config);
  _writeIosConfig(config);
}

Map<String, String> _readConfig(File file) {
  final decoded = jsonDecode(file.readAsStringSync());
  if (decoded is! Map<String, dynamic>) {
    throw StateError('$_configPath must contain a JSON object.');
  }

  return decoded.map((key, value) => MapEntry(key, value?.toString() ?? ''));
}

void _writeAndroidConfig(Map<String, String> config) {
  final projectNumber = _required(config, 'FIREBASE_MESSAGING_SENDER_ID');
  final projectId = _required(config, 'FIREBASE_PROJECT_ID');
  final output = File(_androidOutputPath)..parent.createSync(recursive: true);

  final googleServices = <String, Object>{
    'project_info': <String, String>{
      'project_number': projectNumber,
      'project_id': projectId,
      'storage_bucket': _required(config, 'FIREBASE_STORAGE_BUCKET'),
    },
    'client': [
      <String, Object>{
        'client_info': <String, Object>{
          'mobilesdk_app_id': _required(config, 'FIREBASE_ANDROID_APP_ID'),
          'android_client_info': <String, String>{
            'package_name': _androidPackageName,
          },
        },
        'oauth_client': <Object>[],
        'api_key': [
          <String, String>{
            'current_key': _required(config, 'FIREBASE_ANDROID_API_KEY'),
          },
        ],
        'services': <String, Object>{
          'appinvite_service': <String, Object>{
            'other_platform_oauth_client': <Object>[],
          },
        },
      },
    ],
    'configuration_version': '1',
  };

  const encoder = JsonEncoder.withIndent('  ');
  output.writeAsStringSync('${encoder.convert(googleServices)}\n');
}

void _writeIosConfig(Map<String, String> config) {
  final output = File(_iosOutputPath)..parent.createSync(recursive: true);

  output.writeAsStringSync('''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>API_KEY</key>
	<string>${_xml(_required(config, 'FIREBASE_IOS_API_KEY'))}</string>
	<key>GCM_SENDER_ID</key>
	<string>${_xml(_required(config, 'FIREBASE_MESSAGING_SENDER_ID'))}</string>
	<key>PLIST_VERSION</key>
	<string>1</string>
	<key>BUNDLE_ID</key>
	<string>${_xml(_required(config, 'FIREBASE_IOS_BUNDLE_ID'))}</string>
	<key>PROJECT_ID</key>
	<string>${_xml(_required(config, 'FIREBASE_PROJECT_ID'))}</string>
	<key>STORAGE_BUCKET</key>
	<string>${_xml(_required(config, 'FIREBASE_STORAGE_BUCKET'))}</string>
	<key>GOOGLE_APP_ID</key>
	<string>${_xml(_required(config, 'FIREBASE_IOS_APP_ID'))}</string>
</dict>
</plist>
''');
}

String _required(Map<String, String> config, String key) {
  final value = config[key]?.trim() ?? '';
  if (value.isEmpty || value.startsWith('YOUR_')) {
    throw StateError('$_configPath is missing a real value for $key.');
  }
  return value;
}

String _xml(String value) {
  return value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&apos;');
}
