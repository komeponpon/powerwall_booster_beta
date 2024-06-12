class PowerwallModel {
  final double batteryLevel;
  final double solarPower;
  final double gridPower;
  final double consumption;
  final bool isCharging;

  PowerwallModel({
    required this.batteryLevel,
    required this.solarPower,
    required this.gridPower,
    required this.consumption,
    required this.isCharging,
  });

  factory PowerwallModel.fromJson(Map<String, dynamic> json) {
    return PowerwallModel(
      batteryLevel: json['battery_level'].toDouble(),
      solarPower: json['solar_power'].toDouble(),
      gridPower: json['grid_power'].toDouble(),
      consumption: json['consumption'].toDouble(),
      isCharging: json['is_charging'] as bool,
    );
  }
}
