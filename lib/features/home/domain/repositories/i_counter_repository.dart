import '../entities/counter_entity.dart';

/// Abstract repository contract for counter data operations.
/// This belongs to the domain layer — no framework dependencies.
abstract class ICounterRepository {
  Future<CounterEntity> getCounter();
  Future<void> saveCounter(CounterEntity counter);
}
