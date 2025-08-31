extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String capitalizeWords() {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize()).join(' ');
  }

  bool get isValidCityName {
    if (isEmpty) return false;
    // Basic validation: at least 2 characters, only letters, spaces, and hyphens
    final regex = RegExp(r'^[a-zA-ZÀ-ÿ\s\-]{2,}$');
    return regex.hasMatch(this);
  }
}

extension DateTimeExtension on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool isAfter(DateTime other, {bool orEqual = false}) {
    if (orEqual && isAtSameMomentAs(other)) return true;
    return isAfter(other);
  }

  bool isBefore(DateTime other, {bool orEqual = false}) {
    if (orEqual && isAtSameMomentAs(other)) return true;
    return isBefore(other);
  }
}

extension DoubleExtension on double {
  String toTemperatureString(bool useCelsius) {
    if (useCelsius) {
      return '${round()}°C';
    } else {
      final fahrenheit = (this * 9 / 5) + 32;
      return '${fahrenheit.round()}°F';
    }
  }

  String toPressureString() {
    return '${round()} hPa';
  }

  String toWindSpeedString(String unit) {
    switch (unit.toLowerCase()) {
      case 'mph':
        final mph = this * 0.621371;
        return '${mph.round()} mph';
      case 'km/h':
      default:
        return '${round()} km/h';
    }
  }

  String toPercentageString() {
    return '${round()}%';
  }
}

extension IntExtension on int {
  String toPercentageString() {
    return '$this%';
  }

  String toHumidityString() {
    return '$this%';
  }
}

extension ListExtension<T> on List<T> {
  List<T> safeSublist(int start, [int? end]) {
    if (isEmpty) return [];
    final safeStart = start.clamp(0, length);
    final safeEnd = (end ?? length).clamp(safeStart, length);
    return sublist(safeStart, safeEnd);
  }

  T? get safeFirst => isEmpty ? null : first;
  T? get safeLast => isEmpty ? null : last;

  T? safeElementAt(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }
}