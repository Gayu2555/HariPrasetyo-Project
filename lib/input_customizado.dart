import 'package:flutter/material.dart';

class InputCustomizado extends StatefulWidget {
  final String hint;
  final bool obscure;
  final Icon icon;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const InputCustomizado({
    Key? key,
    required this.hint,
    required this.obscure,
    required this.icon,
    this.controller,
    this.validator,
    this.keyboardType,
  }) : super(key: key);

  @override
  State<InputCustomizado> createState() => _InputCustomizadoState();
}

class _InputCustomizadoState extends State<InputCustomizado> {
  bool _isFocused = false;
  bool _isObscure = true;

  @override
  void initState() {
    super.initState();
    _isObscure = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: _isFocused ? primaryColor.withOpacity(0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isFocused ? primaryColor.withOpacity(0.5) : Colors.grey[200]!,
          width: 1.5,
        ),
      ),
      child: Focus(
        onFocusChange: (hasFocus) {
          setState(() {
            _isFocused = hasFocus;
          });
        },
        child: TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          obscureText: widget.obscure && _isObscure,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: IconTheme(
                data: IconThemeData(
                  color: _isFocused ? primaryColor : Colors.grey[400],
                  size: 22,
                ),
                child: widget.icon,
              ),
            ),
            suffixIcon: widget.obscure
                ? IconButton(
                    icon: Icon(
                      _isObscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: _isFocused ? primaryColor : Colors.grey[400],
                      size: 22,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
          ),
        ),
      ),
    );
  }
}
