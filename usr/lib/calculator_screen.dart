import 'package:flutter/material.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _output = "0";
  String _currentNumber = "";
  double _num1 = 0;
  double _num2 = 0;
  String _operand = "";
  String _history = "";
  bool _isResult = false;

  void buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == "C") {
        _output = "0";
        _currentNumber = "";
        _num1 = 0;
        _num2 = 0;
        _operand = "";
        _history = "";
        _isResult = false;
      } else if (buttonText == "+" ||
          buttonText == "-" ||
          buttonText == "×" ||
          buttonText == "÷") {
        
        if (_currentNumber.isEmpty && _output != "0" && _output != "Error") {
           // Use the current output as the first number if currentNumber is empty (e.g. after equals)
           _currentNumber = _output;
        }

        if (_operand.isNotEmpty && _currentNumber.isNotEmpty) {
          // Chain calculation
          _calculateIntermediate();
        } else if (_currentNumber.isNotEmpty) {
          _num1 = double.tryParse(_currentNumber) ?? 0;
        }

        _operand = buttonText;
        _history = "${_formatNumber(_num1)} $_operand";
        _currentNumber = "";
        _isResult = false;
        
      } else if (buttonText == ".") {
        if (_isResult) {
          _currentNumber = "0.";
          _isResult = false;
        } else if (!_currentNumber.contains(".")) {
          _currentNumber = _currentNumber.isEmpty ? "0." : _currentNumber + ".";
        }
        _output = _currentNumber;
      } else if (buttonText == "=") {
        if (_operand.isNotEmpty) {
          if (_currentNumber.isEmpty) {
             // If user hits = without typing second number, use num1 or 0? 
             // Standard calc usually repeats operation or does nothing. 
             // Let's assume user meant to repeat num1 or just use current output.
             _num2 = _num1; // or double.tryParse(_output) ?? 0;
          } else {
             _num2 = double.tryParse(_currentNumber) ?? 0;
          }
          
          _calculateResult();
          _operand = "";
          _history = "";
          _isResult = true;
          _currentNumber = ""; // Clear so next input starts fresh
        }
      } else if (buttonText == "+/-") {
        if (_output != "0" && _output != "Error") {
          if (_output.startsWith("-")) {
            _output = _output.substring(1);
          } else {
            _output = "-$_output";
          }
          _currentNumber = _output;
        }
      } else if (buttonText == "%") {
         if (_output != "0" && _output != "Error") {
             double val = double.tryParse(_output) ?? 0;
             val = val / 100;
             _output = _formatNumber(val);
             _currentNumber = _output;
             _isResult = true; // Treat as a result
         }
      } else {
        // Number
        if (_isResult) {
          _currentNumber = buttonText;
          _isResult = false;
        } else {
          _currentNumber += buttonText;
        }
        _output = _currentNumber;
      }
    });
  }

  void _calculateIntermediate() {
    _num2 = double.tryParse(_currentNumber) ?? 0;
    _performOperation();
    _output = _formatNumber(_num1);
  }

  void _calculateResult() {
    _performOperation();
    _output = _formatNumber(_num1);
  }

  void _performOperation() {
    if (_operand == "+") {
      _num1 = _num1 + _num2;
    } else if (_operand == "-") {
      _num1 = _num1 - _num2;
    } else if (_operand == "×") {
      _num1 = _num1 * _num2;
    } else if (_operand == "÷") {
      if (_num2 == 0) {
        _output = "Error";
        _num1 = 0;
        return;
      }
      _num1 = _num1 / _num2;
    }
  }

  String _formatNumber(double num) {
    if (num == double.infinity || num == double.negativeInfinity) return "Error";
    // Remove decimal if .0
    if (num % 1 == 0) {
      return num.toInt().toString();
    }
    // Limit decimal places to avoid overflow
    String s = num.toString();
    if (s.length > 10) {
      return num.toStringAsPrecision(8);
    }
    return s;
  }

  Widget buildButton(String buttonText, Color buttonColor, Color textColor) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(22.0),
            backgroundColor: buttonColor,
            foregroundColor: textColor,
            elevation: 2,
          ),
          onPressed: () => buttonPressed(buttonText),
          child: Text(
            buttonText,
            style: const TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _history,
                      style: const TextStyle(
                        fontSize: 24.0,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _output,
                        style: const TextStyle(
                          fontSize: 64.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Keypad
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      buildButton("C", Colors.grey, Colors.black),
                      buildButton("+/-", Colors.grey, Colors.black),
                      buildButton("%", Colors.grey, Colors.black),
                      buildButton("÷", Colors.orange, Colors.white),
                    ],
                  ),
                  Row(
                    children: [
                      buildButton("7", Colors.grey[850]!, Colors.white),
                      buildButton("8", Colors.grey[850]!, Colors.white),
                      buildButton("9", Colors.grey[850]!, Colors.white),
                      buildButton("×", Colors.orange, Colors.white),
                    ],
                  ),
                  Row(
                    children: [
                      buildButton("4", Colors.grey[850]!, Colors.white),
                      buildButton("5", Colors.grey[850]!, Colors.white),
                      buildButton("6", Colors.grey[850]!, Colors.white),
                      buildButton("-", Colors.orange, Colors.white),
                    ],
                  ),
                  Row(
                    children: [
                      buildButton("1", Colors.grey[850]!, Colors.white),
                      buildButton("2", Colors.grey[850]!, Colors.white),
                      buildButton("3", Colors.grey[850]!, Colors.white),
                      buildButton("+", Colors.orange, Colors.white),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          margin: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.only(left: 32, top: 20, bottom: 20, right: 20),
                              alignment: Alignment.centerLeft,
                              backgroundColor: Colors.grey[850]!,
                            ),
                            onPressed: () => buttonPressed("0"),
                            child: const Text(
                              "0",
                              style: TextStyle(
                                fontSize: 28.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      buildButton(".", Colors.grey[850]!, Colors.white),
                      buildButton("=", Colors.orange, Colors.white),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
