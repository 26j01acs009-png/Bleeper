import 'package:flutter/material.dart';

import '../widgets/bleep_logo_loader.dart';
import '../../theme/app_theme_data.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      body: const Center(child: BleepLogoLoader(size: 80)),
    );
  }
}
