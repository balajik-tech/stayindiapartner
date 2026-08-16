class ForceUpdateResponse {
  final bool success;
  final ForceUpdateData data;

  ForceUpdateResponse({
    required this.success,
    required this.data,
  });

  factory ForceUpdateResponse.fromJson(Map<String, dynamic> json) {
    return ForceUpdateResponse(
      success: json['success'] ?? false,
      data: ForceUpdateData.fromJson(
        json['data'] ?? {},
      ),
    );
  }
}

class ForceUpdateData {
  final PlatformUpdate android;
  final PlatformUpdate ios;

  ForceUpdateData({
    required this.android,
    required this.ios,
  });

  factory ForceUpdateData.fromJson(Map<String, dynamic> json) {
    return ForceUpdateData(
      android: PlatformUpdate.fromJson(
        json['android'] ?? {},
      ),
      ios: PlatformUpdate.fromJson(
        json['ios'] ?? {},
      ),
    );
  }
}

class PlatformUpdate {
  final String minimumVersion;
  final String latestVersion;
  final bool forceUpdate;
  final String updateUrl;

  PlatformUpdate({
    required this.minimumVersion,
    required this.latestVersion,
    required this.forceUpdate,
    required this.updateUrl,
  });

  factory PlatformUpdate.fromJson(Map<String, dynamic> json) {
    return PlatformUpdate(
      minimumVersion:
      json['minimumVersion']?.toString() ?? '',
      latestVersion:
      json['latestVersion']?.toString() ?? '',
      forceUpdate:
      json['forceUpdate'] ?? false,
      updateUrl:
      json['updateUrl']?.toString() ?? '',
    );
  }
}