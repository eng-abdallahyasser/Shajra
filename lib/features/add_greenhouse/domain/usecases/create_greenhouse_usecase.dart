import '../entities/greenhouse_entity.dart';
import '../repositories/i_greenhouse_repository.dart';

/// Use case orchestrating the creation of a new greenhouse.
class CreateGreenhouseUseCase {
  final IGreenhouseRepository _repository;

  CreateGreenhouseUseCase(this._repository);

  Future<void> call(GreenhouseEntity greenhouse) {
    return _repository.save(greenhouse);
  }
}
