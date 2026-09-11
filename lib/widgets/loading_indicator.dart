import 'package:flutter/material.dart';
import '../utils/theme.dart';

/// Indicador de carga centrado con color primario
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
      ),
    );
  }
}
