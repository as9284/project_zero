import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:zero/views/history.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _rawExpression = "0";
  String _expression = "0";
  final List<String> operators = ['+', '-', '*', '/', '%'];
  final List<String> _history = [];
  final ScrollController _scrollController = ScrollController();

  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        _rawExpression = '0';
        _expression = '0';
      } else if (value == '=') {
        if (_rawExpression == '0') {
          _expression = 'Enter an expression';
          return;
        }

        if (!_isBalancedParentheses(_rawExpression)) {
          _expression = 'Unmatched parentheses';
          return;
        }

        final lastChar = _rawExpression[_rawExpression.length - 1];
        if (operators.contains(lastChar) || lastChar == '(') {
          _expression = 'Incomplete expression';
          return;
        }

        try {
          String result = _evaluate(_rawExpression);
          _history.add("$_expression = $result");
          _rawExpression = result.replaceAll(',', ''); // update raw
          _expression = result;
        } on FormatException {
          _expression = 'Invalid number format';
        } on UnsupportedError {
          _expression = 'Cannot divide by zero';
        } catch (e) {
          _expression = 'Calculation error';
        }
      } else if (value == '+/-') {
        _toggleSign();
      } else if (value == '()') {
        _insertParenthesis();
      } else {
        _appendToExpression(value);
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
        );
      });
    });
  }

  void _appendToExpression(String value) {
    if (value.isEmpty) return;

    if (_rawExpression == "0" && !operators.contains(value) && value != '.') {
      _rawExpression = value;
      _expression = value;
      return;
    }

    final lastChar =
        _rawExpression.isNotEmpty
            ? _rawExpression[_rawExpression.length - 1]
            : '';

    if (operators.contains(value)) {
      if (_rawExpression.isEmpty ||
          operators.contains(lastChar) ||
          lastChar == '(') {
        return;
      }
      if (operators.contains(lastChar)) {
        _rawExpression = _rawExpression.substring(0, _rawExpression.length - 1);
      }
      _rawExpression += value;
      _expression = _rawExpression;
      return;
    }

    if (value == '.') {
      if (_rawExpression.isEmpty ||
          operators.contains(lastChar) ||
          lastChar == '(') {
        return;
      }
      final number = _rawExpression.split(RegExp(r'[\+\-\*/\%\(\)]')).last;
      if (number.contains('.')) return;
      _rawExpression += value;
      _expression = _rawExpression;
      return;
    }

    if (value == ')') {
      int open = '('.allMatches(_rawExpression).length;
      int close = ')'.allMatches(_rawExpression).length;
      if (close >= open) return;
      if (_rawExpression.isEmpty ||
          operators.contains(lastChar) ||
          lastChar == '(') {
        return;
      }
    }

    _rawExpression += value;
    _expression = _rawExpression;
  }

  void _toggleSign() {
    if (_rawExpression == '0') return;
    try {
      final raw = _rawExpression.replaceAll(',', '');
      ShuntingYardParser p = ShuntingYardParser();
      Expression exp = p.parse(raw);
      ContextModel cm = ContextModel();
      double result = exp.evaluate(EvaluationType.REAL, cm);
      _rawExpression = (-result).toString();
      _expression = _formatResult(-result);
    } catch (_) {
      _expression = 'Invalid toggle';
    }
  }

  void _insertParenthesis() {
    String lastChar =
        _rawExpression.isNotEmpty
            ? _rawExpression[_rawExpression.length - 1]
            : '';

    int openCount = '('.allMatches(_rawExpression).length;
    int closeCount = ')'.allMatches(_rawExpression).length;

    if (_rawExpression == '0') {
      _rawExpression = '(';
    } else if (_rawExpression.isEmpty ||
        operators.contains(lastChar) ||
        lastChar == '(') {
      _rawExpression += '(';
    } else if (openCount > closeCount &&
        RegExp(r'[0-9)]$').hasMatch(lastChar)) {
      _rawExpression += ')';
    }
    _expression = _rawExpression;
  }

  String _evaluate(String expr) {
    expr = expr.replaceAll('×', '*').replaceAll('÷', '/');

    if (RegExp(r'/\s*0(?!\d)').hasMatch(expr)) {
      throw UnsupportedError('Division by zero is not supported');
    }

    ShuntingYardParser p = ShuntingYardParser();
    Expression exp = p.parse(expr);
    ContextModel cm = ContextModel();
    double result = exp.evaluate(EvaluationType.REAL, cm);

    if (result.isInfinite || result.isNaN) {
      throw FormatException("Invalid result");
    }

    return _formatResult(result);
  }

  String _formatResult(double result) {
    final formatter = NumberFormat("#,##0.##########");
    return formatter.format(result);
  }

  void _deleteLastCharacter() {
    setState(() {
      if (_rawExpression.length <= 1) {
        _rawExpression = '0';
      } else {
        _rawExpression = _rawExpression.substring(0, _rawExpression.length - 1);
      }
      _expression = _rawExpression;
    });
  }

  bool _isBalancedParentheses(String expr) {
    int balance = 0;
    for (var char in expr.split('')) {
      if (char == '(') balance++;
      if (char == ')') balance--;
      if (balance < 0) return false;
    }
    return balance == 0;
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
                    ? const Color.fromARGB(255, 0, 40, 43)
                    : const Color.fromRGBO(0, 107, 113, 1),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 28),
          ),
          onPressed: () => _onButtonPressed(label),
          child: Text(
            label,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
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
        actionsPadding: const EdgeInsets.only(right: 16),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 100,
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Stack(
                children: [
                  Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    trackVisibility: true,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          _expression,
                          style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.w400,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.visible,
                          softWrap: false,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IgnorePointer(
                      child: Container(
                        width: 20,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                            colors: [
                              Theme.of(context).scaffoldBackgroundColor,
                              Theme.of(
                                context,
                              ).scaffoldBackgroundColor.withAlpha(0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 20,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.backspace),
                          iconSize: 28,
                          tooltip: 'Delete',
                          onPressed: _deleteLastCharacter,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...buttons.map((row) {
                      return Row(
                        children:
                            row
                                .map((label) => _buildButton(label, isDark))
                                .toList(),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
