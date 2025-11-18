import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seguimiento_norandino/core/errors/failures.dart';
import 'package:seguimiento_norandino/features/seguimientos/domain/entities/seguimiento.dart';
import 'package:seguimiento_norandino/features/seguimientos/domain/use_cases/seguimientos_use_cases.dart';

import 'update_seguimiento_use_case_test.mocks.dart';

void main() {
  late MockSeguimientosRepository repository;
  late UpdateSeguimientoUseCase useCase;

  const seguimiento = Seguimiento(
    id: 'seg-2',
    rutaId: 'ruta-1',
    nombreRuta: 'Ruta Principal',
    asesorId: 'asesor-1',
    nombreAsesor: 'Juan Pérez',
    clienteId: 'cliente-1',
    nombreCliente: 'Cliente Demo',
    tipoVisita: 'cobranza',
    estado: 'en_proceso',
    requiereAccion: true,
    accionRequerida: 'Contactar cliente',
  );

  setUp(() {
    repository = MockSeguimientosRepository();
    useCase = UpdateSeguimientoUseCase(repository);
  });

  test('UC-S03: debería actualizar un seguimiento con id válido', () async {
    when(repository.updateSeguimiento(any)).thenAnswer((_) async => const Right(seguimiento));

    final result = await useCase(seguimiento);

    expect(result.isRight(), isTrue);
    expect(result.getOrElse(() => throw StateError('Resultado inesperado')), seguimiento);
    verify(repository.updateSeguimiento(seguimiento)).called(1);
  });

  test('UC-S03: debería fallar cuando el seguimiento no tiene id', () async {
    const seguimientoSinId = Seguimiento(
      id: '',
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

    final result = await useCase(seguimientoSinId);

    result.fold(
      (failure) => expect(failure, const ValidationFailure(message: 'ID de seguimiento inválido')),
      (_) => fail('Se esperaba un fallo de validación'),
    );
    verifyNever(repository.updateSeguimiento(any));
  });
}
