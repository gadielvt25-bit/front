import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seguimiento_norandino/core/errors/failures.dart';
import 'package:seguimiento_norandino/features/seguimientos/domain/entities/seguimiento.dart';
import 'package:seguimiento_norandino/features/seguimientos/domain/use_cases/seguimientos_use_cases.dart';

import 'complete_seguimiento_use_case_test.mocks.dart';

void main() {
  late MockSeguimientosRepository repository;
  late CompleteSeguimientoUseCase useCase;

  final seguimientoCompletado = Seguimiento(
    id: 'seg-10',
    rutaId: 'ruta-1',
    nombreRuta: 'Ruta Principal',
    asesorId: 'asesor-1',
    nombreAsesor: 'Juan Pérez',
    clienteId: 'cliente-1',
    nombreCliente: 'Cliente Demo',
    tipoVisita: 'cobranza',
    observaciones: 'visita exitosa',
    estado: 'completada',
    requiereAccion: false,
  );

  setUp(() {
    repository = MockSeguimientosRepository();
    useCase = CompleteSeguimientoUseCase(repository);
  });

  test('UC-S04: debería completar un seguimiento válido', () async {
    const params = CompleteSeguimientoParams(
      id: 'seg-10',
      observaciones: 'Pago registrado',
      montoRecaudado: 150.0,
    );

    when(
      repository.completeSeguimiento(
        any,
        observaciones: anyNamed('observaciones'),
        montoRecaudado: anyNamed('montoRecaudado'),
      ),
    ).thenAnswer((_) async => Right(seguimientoCompletado));

    final result = await useCase(params);

    expect(result.isRight(), isTrue);
    expect(result.getOrElse(() => throw StateError('Resultado inesperado')), seguimientoCompletado);

    verify(
      repository.completeSeguimiento(
        params.id,
        observaciones: params.observaciones,
        montoRecaudado: params.montoRecaudado,
      ),
    ).called(1);
  });

  test('UC-S04: debería fallar cuando el id es inválido', () async {
    const params = CompleteSeguimientoParams(id: '');

    final result = await useCase(params);

    result.fold(
      (failure) => expect(failure, const ValidationFailure(message: 'ID de seguimiento inválido')),
      (_) => fail('Se esperaba un fallo de validación'),
    );
    verifyNever(repository.completeSeguimiento(any, observaciones: anyNamed('observaciones'), montoRecaudado: anyNamed('montoRecaudado')));
  });
}
