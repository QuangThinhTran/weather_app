import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> isLocationPermissionGranted() async {
    final status = await Permission.location.status;
    return status == PermissionStatus.granted;
  }

  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status == PermissionStatus.granted;
  }

  Future<bool> isLocationPermissionDeniedForever() async {
    final status = await Permission.location.status;
    return status == PermissionStatus.permanentlyDenied;
  }

  Future<void> openAppSettings() async {
    await openAppSettings();
  }

  Future<PermissionStatus> getLocationPermissionStatus() async {
    return await Permission.location.status;
  }
}