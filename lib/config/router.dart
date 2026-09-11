import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/notification_list/notification_list_screen.dart';
import '../screens/notification_detail/notification_detail_screen.dart';
import '../screens/notification_form/notification_form_screen.dart';

/// Configuración de rutas con go_router
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const NotificationListScreen(),
    ),
    GoRoute(
      path: '/notification/new',
      builder: (context, state) => const NotificationFormScreen(),
    ),
    GoRoute(
      path: '/notification/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return NotificationDetailScreen(notificationId: id);
      },
    ),
    // Deep link placeholder
    // TODO: Procesar deep links reales de notificaciones
    // Cuando una notificación tiene data.deepLink (ej: "app://orders/1234"),
    // se debería parsear el path y navegar a la pantalla correspondiente.
    // Approach: interceptar en NotificationDetailScreen y usar go_router
    // para resolver la ruta basándose en el esquema del deep link.
    GoRoute(
      path: '/deep/:path',
      builder: (context, state) {
        final path = state.pathParameters['path'] ?? '';
        return Scaffold(
          appBar: AppBar(title: const Text('Deep Link')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Deep link procesado:'),
                const SizedBox(height: 8),
                Text(
                  path,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    ),
  ],
);
