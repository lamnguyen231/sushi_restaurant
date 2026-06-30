class DeviceInfo {
  const DeviceInfo({
    required this.id,
    required this.deviceName,
    required this.status,
    required this.lastOnlineAt,
    required this.appVersion,
    this.assignedTableId,
  });

  final String id;
  final String deviceName;
  final String? assignedTableId;
  final String status;
  final DateTime lastOnlineAt;
  final String appVersion;
}
