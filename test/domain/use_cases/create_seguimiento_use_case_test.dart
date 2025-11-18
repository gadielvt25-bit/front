import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seguimiento_norandino/core/errors/failures.dart';
import 'package:seguimiento_norandino/features/seguimientos/domain/entities/seguimiento.dart';
import 'package:seguimiento_norandino/features/seguimientos/domain/use_cases/seguimientos_use_cases.dart';

import 'create_seguimiento_use_case_test.mocks.dart';

void main() {
  late MockSeguimientosRepository repository;
  late CreateSeguimientoUseCase useCase;

  const params = CreateSeguimientoParams(
    rutaId: 'ruta-1',
    nombreRuta: 'Ruta Principal',
    asesorId: 'asesor-1',
    nombreAsesor: 'Juan Pérez',
    clienteId: 'cliente-1',
    nombreCliente: 'Cliente Demo',
    tipoVisita: 'cobranza',
    requiereAccion: true,
    accionRequerida: 'Recoger documentos',
  );

  setUp(() {
    repository = MockSeguimientosRepository();
    useCase = CreateSeguimientoUseCase(repository);
  });

  test('UC-S02: debería crear un seguimiento y retornar el id del backend', () async {
    const backendResponse = Right<Failure, Map<String, dynamic>>({'id': 'seguimiento-generado'});
    when(repository.createSeguimiento(any)).thenAnswer((_) async => backendResponse);

    final result = await useCase(params);

    expect(result.isRight(), isTrue);
    final seguimientoCreado = result.getOrElse(() => throw StateError('Resultado inesperado'));
    expect(seguimientoCreado.id, 'seguimiento-generado');
    expect(seguimientoCreado.rutaId, params.rutaId);
    expect(seguimientoCreado.estado, 'pendiente');

    final captured = verify(repository.createSeguimiento(captureAny)).captured.single as Seguimiento;
    expect(captured.id, isEmpty);
    expect(captured.nombreCliente, params.nombreCliente);
    verifyNoMoreInteractions(repository);
  });

  test('UC-S02: debería retornar un ValidationFailure cuando falta la ruta', () async {
    const invalidParams = CreateSeguimientoParams(
      rutaId: '',
      nombreRuta: 'Ruta Principal',
      asesorId: 'asesor-1',
      nombreAsesor: 'Juan Pérez',
      clienteId: 'cliente-1',
      nombreCliente: 'Cliente Demo',
      tipoVisita: 'cobranza',
      requiereAccion: false,
    );

    final result = await useCase(invalidParams);

    result.fold(
      (failure) => expect(failure, const ValidationFailure(message: 'La ruta es requerida')),
      (_) => fail('Se esperaba un fallo de validación'),
    );
    verifyNever(repository.createSeguimiento(any));
  });
}
