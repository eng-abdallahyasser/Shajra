import '../../domain/entities/counter_entity.dart';

/// Data-layer model that extends the domain entity.
/// Handles JSON serialization / deserialization.
class CounterModel extends CounterEntity {
  const CounterModel({super.value});

  factory CounterModel.fromJson(Map<String, dynamic> json) {
    return CounterModel(value: json['value'] as int? ?? 0);
  }

  Map<String, dynamic> toJson() {
    return {'value': value};
  }

  factory CounterModel.fromEntity(CounterEntity entity) {
    return CounterModel(value: entity.value);
  }
}
