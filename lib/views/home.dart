import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:zero/views/history.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _expression = "";
  final List<String> operators = ['+', '-', '*', '/', '%'];
  final List<String> _history = [];

  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        _expression = '';
      } else if (value == '=') {
        try {
          String result = _evaluate(_expression);
          _history.add("$_expression = $result");
          _expression = result;
        } catch (e) {
          _expression = 'Error';
        }
      } else if (value == '+/-') {
        _toggleSign();
      } else if (value == '()') {
        _insertParenthesis();
      } else {
        _appendToExpression(value);
      }
    });
  }

  void _appendToExpression(String value) {
    final lastChar =
        _expression.isNotEmpty ? _expression[_expression.length - 1] : '';

    if (operators.contains(value)) {
      if (_expression.isEmpty) return;
      if (operators.contains(lastChar)) {
        _expression = _expression.substring(0, _expression.length - 1) + value;
        return;
      }
    }

    if (value == '.') {
      if (_expression.isEmpty ||
          lastChar == '.' ||
          operators.contains(lastChar) ||
          lastChar == '(')
        return;
    }

    _expression += value;
  }

  void _toggleSign() {
    if (_expression.isEmpty) return;
    try {
      ShuntingYardParser p = ShuntingYardParser();
      Expression exp = p.parse(_expression);
      ContextModel cm = ContextModel();
      double result = exp.evaluate(EvaluationType.REAL, cm);
      _expression = _formatResult(-result);
    } catch (e) {
      _expression = 'Error';
    }
  }

  void _insertParenthesis() {
    int openCount = '('.allMatches(_expression).length;
    int closeCount = ')'.allMatches(_expression).length;
    if (openCount == closeCount || _expression.endsWith('(')) {
      _expression += '(';
    } else {
      _expression += ')';
    }
  }

  String _evaluate(String expr) {
    expr = expr.replaceAll('×', '*').replaceAll('÷', '/');
    ShuntingYardParser p = ShuntingYardParser();
    Expression exp = p.parse(expr);
    ContextModel cm = ContextModel();
    double result = exp.evaluate(EvaluationType.REAL, cm);
    return _formatResult(result);
  }

  String _formatResult(double result) {
    if (result == result.toInt()) {
      return result.toInt().toString();
    }
    return result.toString();
  }

  Widget _buildButton(String label, bool isDark) {
    final isOperator =
        operators.contains(label) || ['C', '=', '()', '+/-'].contains(label);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor:
                isOperator
                    ? const Color.fromARGB(255, 0, 49, 52)
                    : const Color.fromRGBO(0, 107, 113, 1),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 36),
          ),
          onPressed: () => _onButtonPressed(label),
          child: Text(label, style: const TextStyle(fontSize: 20)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final buttons = [
      ['C', '()', '%', '/'],
      ['7', '8', '9', '*'],
      ['4', '5', '6', '-'],
      ['1', '2', '3', '+'],
      ['+/-', '0', '.', '='],
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Zero",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => HistoryPage(
                        history: _history,
                        onClear: () {
                          setState(() {
                            _history.clear();
                          });
                        },
                      ),
                ),
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, "/settings");
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                alignment: Alignment.bottomRight,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: Text(
                    _expression,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                    softWrap: false,
                  ),
                ),
              ),
            ),

            ...buttons.map(
              (row) => Row(
                children:
                    row.map((label) => _buildButton(label, isDark)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
