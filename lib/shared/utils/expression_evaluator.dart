/// Evaluates simple mathematical expressions with +, -, ×, ÷ operators
/// The expression should be a valid infix notation string like "12.50+8.30-4.20"
/// Returns the evaluated result as a double
/// Throws FormatException if the expression is invalid
class ExpressionEvaluator {
  /// Parses and evaluates an expression string
  /// Supports: +, -, ×, ÷ operators with proper precedence
  /// Example: "10+5×2" = 20 (multiplication has higher precedence)
  static double evaluate(String expression) {
    // Remove any whitespace from the expression
    final cleaned = expression.replaceAll(' ', '').replaceAll('−', '-');

    if (cleaned.isEmpty) {
      throw const FormatException('Empty expression');
    }

    // Parse the expression into tokens (numbers and operators)
    final tokens = _tokenize(cleaned);

    if (tokens.isEmpty) {
      throw const FormatException('No valid tokens found');
    }

    // Convert to postfix notation (Reverse Polish Notation) using Shunting-yard algorithm
    final postfix = _infixToPostfix(tokens);

    // Evaluate the postfix expression
    return _evaluatePostfix(postfix);
  }

  /// Tokenizes the expression string into numbers and operators
  static List<String> _tokenize(String expression) {
    final tokens = <String>[];
    var i = 0;

    while (i < expression.length) {
      final char = expression[i];

      // Skip spaces (shouldn't be any after cleaning, but just in case)
      if (char == ' ') {
        i++;
        continue;
      }

      // Check for operators
      if (_isOperator(char)) {
        tokens.add(char);
        i++;
        continue;
      }

      // Parse numbers (including decimals).
      if (char == '.' || _isDigit(char)) {
        var numStr = '';
        while (i < expression.length &&
            (expression[i] == '.' || _isDigit(expression[i]))) {
          numStr += expression[i];
          i++;
        }
        tokens.add(numStr);
        continue;
      }

      // If we get here, it's an invalid character
      throw FormatException('Invalid character in expression: \'$char\'');
    }

    return tokens;
  }

  /// Checks if a character is a digit
  static bool _isDigit(String char) {
    return char.codeUnitAt(0) >= '0'.codeUnitAt(0) &&
        char.codeUnitAt(0) <= '9'.codeUnitAt(0);
  }

  /// Checks if a character is an operator
  static bool _isOperator(String char) {
    return char == '+' || char == '-' || char == '×' || char == '÷';
  }

  /// Gets the precedence of an operator (higher number = higher precedence)
  static int _getPrecedence(String operator) {
    switch (operator) {
      case '×':
      case '÷':
        return 2;
      case '+':
      case '-':
        return 1;
      default:
        return 0;
    }
  }

  /// Converts infix notation to postfix notation using Shunting-yard algorithm
  static List<String> _infixToPostfix(List<String> tokens) {
    final output = <String>[];
    final operatorStack = <String>[];

    for (final token in tokens) {
      // If token is a number, add to output
      if (_isNumber(token)) {
        output.add(token);
      }
      // If token is an operator
      else if (_isOperator(token)) {
        while (operatorStack.isNotEmpty &&
            operatorStack.last != '(' &&
            _getPrecedence(operatorStack.last) >= _getPrecedence(token)) {
          output.add(operatorStack.removeLast());
        }
        operatorStack.add(token);
      }
    }

    // Pop remaining operators from stack to output
    while (operatorStack.isNotEmpty) {
      output.add(operatorStack.removeLast());
    }

    return output;
  }

  /// Checks if a token is a number
  static bool _isNumber(String token) {
    return double.tryParse(token) != null;
  }

  /// Evaluates a postfix expression
  static double _evaluatePostfix(List<String> postfix) {
    final stack = <double>[];

    for (final token in postfix) {
      if (_isNumber(token)) {
        stack.add(double.parse(token));
      } else {
        // It's an operator
        if (stack.length < 2) {
          throw const FormatException('Insufficient operands for operator');
        }
        final b = stack.removeLast();
        final a = stack.removeLast();

        switch (token) {
          case '+':
            stack.add(a + b);
            break;
          case '-':
            stack.add(a - b);
            break;
          case '×':
            stack.add(a * b);
            break;
          case '÷':
            if (b == 0) {
              throw const FormatException('Division by zero');
            }
            stack.add(a / b);
            break;
          default:
            throw FormatException('Unknown operator: $token');
        }
      }
    }

    if (stack.length != 1) {
      throw const FormatException('Invalid expression - too many operands');
    }

    return stack.first;
  }

  /// Formats an expression string for display
  /// Adds spaces around operators for readability
  /// Example: "10+5×2" -> "10 + 5 × 2"
  static String formatExpression(String expression) {
    // Remove all spaces first
    final cleaned = expression.replaceAll(' ', '').replaceAll('-', '−');

    // Add spaces around operators
    var formatted = cleaned;
    for (final op in ['+', '−', '×', '÷']) {
      formatted = formatted.replaceAll(op, ' $op ');
    }

    // Trim and collapse multiple spaces
    return formatted.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
}
