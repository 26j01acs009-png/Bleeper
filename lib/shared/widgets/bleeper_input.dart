import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_data.dart';

class BleeperInput extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool enabled;
  final TextAlign? textAlign;
  final TextStyle? style;
  final String? label;
  final int? maxLines;
  final void Function(String)? onChanged;
  final bool readOnly;
  final VoidCallback? onTap;

  const BleeperInput({
    super.key,
    this.controller,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.enabled = true,
    this.textAlign,
    this.style,
    this.label,
    this.maxLines = 1,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: context.label,
          ),
          const SizedBox(height: 6),
        ],
TextFormField(
           controller: controller,
           obscureText: obscureText,
           keyboardType: keyboardType,
           validator: validator,
           enabled: enabled,
           maxLines: maxLines,
           readOnly: readOnly,
           onTap: onTap,
           textAlign: textAlign ?? TextAlign.start,
           style: style ?? context.body,
           onChanged: onChanged,
           decoration: InputDecoration(
            hintText: hintText,
            hintStyle: context.bodyMedium.copyWith(
              color: context.textTertiary,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    color: context.textTertiary,
                    size: 22,
                  )
                : null,
            suffixIcon: suffixIcon != null
                ? IconButton(
                    icon: Icon(
                      suffixIcon,
                      color: context.textTertiary,
                      size: 22,
                    ),
                    onPressed: onSuffixTap,
                  )
                : null,
            filled: true,
            fillColor: context.surfaceAlt,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.radiusLg),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.radiusLg),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.radiusLg),
              borderSide: BorderSide(
                color: context.accent.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.radiusLg),
              borderSide: BorderSide(
                color: context.error,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 18,
            ),
          ),
        ),
      ],
    );
  }
}
