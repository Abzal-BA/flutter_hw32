enum AppFlavor { dev, prod }

class AppEnvironment {
  const AppEnvironment({
    required this.flavor,
    required this.appTitle,
    required this.bannerLabel,
    required this.showBanner,
  });

  final AppFlavor flavor;
  final String appTitle;
  final String bannerLabel;
  final bool showBanner;

  bool get isProduction => flavor == AppFlavor.prod;

  static AppEnvironment fromFlavor(AppFlavor flavor) {
    switch (flavor) {
      case AppFlavor.dev:
        return const AppEnvironment(
          flavor: AppFlavor.dev,
          appTitle: 'Flutter HW32 Dev',
          bannerLabel: 'DEV',
          showBanner: true,
        );
      case AppFlavor.prod:
        return const AppEnvironment(
          flavor: AppFlavor.prod,
          appTitle: 'Flutter HW32',
          bannerLabel: 'PROD',
          showBanner: false,
        );
    }
  }
}
