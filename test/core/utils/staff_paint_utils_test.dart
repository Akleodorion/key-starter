import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/utils/staff_paint_utils.dart';

void main() {
  group('staffLineGapForHeight', () {
    test('should scale the line gap to a tenth of the available height', () {
      //arrange
      const availableHeight = 240.0;

      //act
      final sut = staffLineGapForHeight(availableHeight);

      //assert
      expect(sut, 24.0);
    });

    test('should never go below the default line gap on short heights', () {
      //arrange
      const availableHeight = 60.0;

      //act
      final sut = staffLineGapForHeight(availableHeight);

      //assert
      expect(sut, 10.0);
    });

    test('should cap the line gap on very tall heights', () {
      //arrange
      const availableHeight = 600.0;

      //act
      final sut = staffLineGapForHeight(availableHeight);

      //assert
      expect(sut, 32.0);
    });
  });
}
