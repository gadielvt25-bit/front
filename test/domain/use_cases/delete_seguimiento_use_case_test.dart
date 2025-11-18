import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seguimiento_norandino/core/errors/failures.dart';
import 'package:seguimiento_norandino/features/seguimientos/domain/use_cases/seguimientos_use_cases.dart';

import 'delete_seguimiento_use_case_test.mocks.dart';

void main() {
  late MockSeguimientosRepository repository;
  late DeleteSeguimientoUseCase useCase;

  setUp(() {
    repository = MockSeguimientosRepository();
    useCase = DeleteSeguimientoUseCase(repository);
  });

  test('UC-S05: debería eliminar un seguimiento existente', () async {
    when(repository.deleteSeguimiento(any)).thenAnswer((_) async => const Right<Failure, void>(null));

    final result = await useCase('seg-15');

    expect(result.isRight(), isTrue);
    verify(repository.deleteSeguimiento('seg-15')).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('UC-S05: debería fallar cuando el id es inválido', () async {
    final result = await useCase('');

    result.fold(
      (failure) => expect(failure, const ValidationFailure(message: 'ID de seguimiento inválido')),
      (_) => fail('Se esperaba un fallo de validación'),
    );
    verifyNever(repository.deleteSeguimiento(any));
  });
}
