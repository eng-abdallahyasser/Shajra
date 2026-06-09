import '../../models/counter_model.dart';

/// In-memory local data source for the counter.
/// In a real app this would be replaced with SharedPreferences, Hive, etc.
class CounterLocalSource {
  int _counterValue = 0;

  Future<CounterModel> fetchCounter() async {
    return CounterModel(value: _counterValue);
  }

  Future<void> persistCounter(CounterModel counter) async {
    _counterValue = counter.value;
  }
}
