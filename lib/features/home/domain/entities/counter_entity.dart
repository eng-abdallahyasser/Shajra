class CounterEntity {
  final int value;

  const CounterEntity({this.value = 0});

  CounterEntity copyWith({int? value}) {
    return CounterEntity(value: value ?? this.value);
  }
}
