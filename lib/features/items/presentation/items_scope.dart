import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../di/service_locator.dart';
import 'controller/items_controller.dart';

class ItemsScope extends StatelessWidget {
  const ItemsScope({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ItemsController>(
      create: (_) => getIt<ItemsController>()..loadItems(),
      child: child,
    );
  }
}
