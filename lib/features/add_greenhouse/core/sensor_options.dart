import 'package:flutter/material.dart';

/// A descriptor for a sensor type option in the greenhouse wizard.
class SensorOption {
  final String key;
  final String label;
  final IconData icon;

  const SensorOption({
    required this.key,
    required this.label,
    required this.icon,
  });
}

/// All available sensor options.
const sensorOptions = [
  SensorOption(key: 'temperature', label: 'Temperature', icon: Icons.thermostat),
  SensorOption(key: 'humidity', label: 'Humidity', icon: Icons.water_drop),
  SensorOption(key: 'soil_moisture', label: 'Soil Moisture', icon: Icons.grass),
  SensorOption(key: 'light', label: 'Light Intensity', icon: Icons.wb_sunny),
];

/// Resolves a sensor option key to its display label.
/// Returns "—" if the key is empty or unknown.
String sensorLabel(String key) {
  final option = sensorOptions.where((o) => o.key == key);
  return option.isNotEmpty ? option.first.label : '—';
}
