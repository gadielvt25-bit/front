import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seguimiento_norandino/core/errors/failures.dart';
import 'package:seguimiento_norandino/features/seguimientos/domain/entities/seguimiento.dart';
import 'package:seguimiento_norandino/features/seguimientos/domain/use_cases/seguimientos_use_cases.dart';

import 'get_seguimiento_by_id_use_case_test.mocks.dart';

void main() {
  late MockSeguimientosRepository repository;
  late GetSeguimientoByIdUseCase useCase;

  const seguimiento = Seguimiento(
    id: 'seg-1',
    rutaId: 'ruta-1',
    nombreRuta: 'Ruta Principal',
    asesorId: 'asesor-1',
    nombreAsesor: 'Juan Pérez',
    clienteId: 'cliente-1',
    nombreCliente: 'Cliente Demo',
    tipoVisita: 'cobranza',
    estado: 'pendiente',
    requiereAccion: false,
  );

  setUp(() {
    repository = MockSeguimientosRepository();
    useCase = GetSeguimientoByIdUseCase(repository);
  });

  test('UC-S01: debería obtener un seguimiento por id', () async {
    when(repository.getSeguimientoById(any)).thenAnswer((_) async => const Right(seguimiento));

    final result = await useCase('seg-1');

    expect(result.isRight(), isTrue);
    expect(result.getOrElse(() => throw StateError('Resultado inesperado')), seguimiento);
    verify(repository.getSeguimientoById('seg-1')).called(1);
  });

  test('UC-S01: debería fallar si el id está vacío', () async {
    final result = await useCase('');

    result.fold(
      (failure) => expect(failure, const ValidationFailure(message: 'ID de seguimiento inválido')),
      (_) => fail('Se esperaba un fallo de validación'),
    );
    verifyNever(repository.getSeguimientoById(any));
  });
}
