import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'core/services/graphql_service.dart';
import 'core/services/storage_service.dart';
import 'features/auth/auth_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService();
  await storageService.init();

  final graphqlService = GraphQLService(storageService: storageService);
  final authController = AuthController(
    storageService: storageService,
    graphqlService: graphqlService,
  );
  await authController.init();

  runApp(
    MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storageService),
        Provider<GraphQLService>.value(value: graphqlService),
        ChangeNotifierProvider<AuthController>.value(value: authController),
      ],
      child: const FoodDeliveryApp(),
    ),
  );
}
