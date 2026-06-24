import 'package:flutter/material.dart';

class PriceInput extends StatefulWidget {
  final double initialPrice;
  final String currency;
  final String unit;
  final String label;
  final ValueChanged<double> onPriceChanged;

  const PriceInput({
    super.key,
    required this.initialPrice,
    required this.currency,
    required this.unit,
    required this.onPriceChanged,
    this.label = "Prix Unitaire",
  });

  @override
  State<PriceInput> createState() => _PriceInputState();
}

class _PriceInputState extends State<PriceInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // If the price is integer, format as integer to avoid trailing dot/zeroes
    final isInt = widget.initialPrice == widget.initialPrice.roundToDouble();
    final initialText = isInt 
        ? widget.initialPrice.round().toString() 
        : widget.initialPrice.toString();
    _controller = TextEditingController(text: initialText);
  }

  @override
  void didUpdateWidget(PriceInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialPrice != widget.initialPrice) {
      final isInt = widget.initialPrice == widget.initialPrice.roundToDouble();
      final text = isInt 
          ? widget.initialPrice.round().toString() 
          : widget.initialPrice.toString();
      
      // Keep selection if focused
      final selection = _controller.selection;
      _controller.text = text;
      try {
        _controller.selection = selection;
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F2A44),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E8E5A), // Secondary green for money
          ),
          onChanged: (val) {
            final doublePrice = double.tryParse(val) ?? 0.0;
            widget.onPriceChanged(doublePrice);
          },
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            prefixIcon: const Icon(Icons.payments, color: Color(0xFF1E8E5A), size: 18),
            suffixIcon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Text(
                "${widget.currency} / ${widget.unit}",
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF1E8E5A),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
