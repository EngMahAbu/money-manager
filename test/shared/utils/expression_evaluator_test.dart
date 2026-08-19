import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/shared/utils/expression_evaluator.dart';

void main() {
  group('ExpressionEvaluator', () {
    test('evaluates multi-digit decimal expressions with precedence', () {
      expect(ExpressionEvaluator.evaluate('12.50+8.30×2'), 29.1);
    });

    test('evaluates decimal points in multiple operands', () {
      expect(
        ExpressionEvaluator.evaluate('1.25+3.50−0.75'),
        closeTo(4.0, 0.000001),
      );
    });

    test('accepts the typographic minus used by the calculator display', () {
      expect(
        ExpressionEvaluator.evaluate('12.50−8.30'),
        closeTo(4.2, 0.000001),
      );
    });

    test('formats expressions with readable operators', () {
      expect(
        ExpressionEvaluator.formatExpression('12.50-8.30'),
        '12.50 − 8.30',
      );
    });
  });
}
