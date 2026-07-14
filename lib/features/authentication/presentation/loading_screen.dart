import 'package:flutter/material.dart';

import '../../../shared/widgets/widgets.dart';

/// Tela de carregamento genérica (transições de sessão).
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({this.message, super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: LoadingWidget(message: message));
  }
}
