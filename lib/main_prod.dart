import 'app/app_environment.dart';
import 'bootstrap.dart';

Future<void> main() async {
  await bootstrap(AppFlavor.prod);
}
