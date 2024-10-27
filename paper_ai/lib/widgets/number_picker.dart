import 'package:flutter/material.dart';
import 'package:paper_ai/widgets/paper_button.dart';

class NumberPicker extends StatefulWidget {
  final int initialValue;
  final ValueChanged<int> onValueChanged;

  const NumberPicker({
    super.key,
    required this.initialValue,
    required this.onValueChanged,
  });

  @override
  State createState() => _NumberPickerState();
}

class _NumberPickerState extends State<NumberPicker> {
  late int _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  void _increment() {
    setState(() {
      _currentValue++;
      widget.onValueChanged(_currentValue);
    });
  }

  void _decrement() {
    setState(() {
      if (_currentValue > 1) {
        _currentValue--;
        widget.onValueChanged(_currentValue);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: PaperButton(
              text: '-',
              outlined: true,
              onPressed: _decrement,
            ),
          ),
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    '$_currentValue',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PaperButton(
              text: '+',
              outlined: true,
              onPressed: _increment,
            ),
          ),
        ],
      ),
    );
  }
}
