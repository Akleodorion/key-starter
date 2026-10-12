import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/errors/failures.dart';
import 'package:key_starter/features/chord_chart/domain/entities/bundled_chord_chart.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_chart.dart';
import 'package:key_starter/features/chord_chart/domain/usecases/list_chord_charts_usecase.dart';
import 'package:key_starter/features/chord_chart/domain/usecases/load_chord_chart_usecase.dart';
import 'package:key_starter/injection_container.dart';

final listChordChartsUseCaseProvider = Provider<ListChordChartsUseCase>(
  (ref) => sl<ListChordChartsUseCase>(),
);

/// Les grilles livrées avec l'app, triées par titre.
final chordChartListProvider =
    FutureProvider.autoDispose<Either<Failure, List<BundledChordChart>>>(
      (ref) => ref.read(listChordChartsUseCaseProvider)(),
    );

final loadChordChartUseCaseProvider = Provider<LoadChordChartUseCase>(
  (ref) => sl<LoadChordChartUseCase>(),
);

/// La grille lue depuis son fichier, ou la raison de l'échec.
final chordChartProvider = FutureProvider.autoDispose
    .family<Either<Failure, ChordChart>, BundledChordChart>(
      (ref, bundledChordChart) =>
          ref.read(loadChordChartUseCaseProvider)(bundledChordChart),
    );
