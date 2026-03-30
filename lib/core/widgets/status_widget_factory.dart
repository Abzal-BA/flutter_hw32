import 'package:flutter/material.dart';

enum StatusWidgetType { loading, success, error }

class StatusWidgetFactory {
  const StatusWidgetFactory._();

  // Day 37 Factory: builds loading/success/error widgets from enum input.
  static Widget create(
    StatusWidgetType type, {
    String? message,
    VoidCallback? onRetry,
    bool compact = false,
  }) {
    switch (type) {
      case StatusWidgetType.loading:
        return compact
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 10),
                  Text(message ?? 'Loading...'),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 12),
                  Text(message ?? 'Loading...'),
                ],
              );
      case StatusWidgetType.success:
        return _StatusMessageCard(
          color: Colors.green,
          icon: Icons.check_circle_outline,
          message: message ?? 'Completed successfully.',
          compact: compact,
        );
      case StatusWidgetType.error:
        if (compact) {
          return _StatusMessageCard(
            color: Colors.red,
            icon: Icons.error_outline,
            message: message ?? 'Something went wrong.',
            compact: true,
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StatusMessageCard(
              color: Colors.red,
              icon: Icons.error_outline,
              message: message ?? 'Something went wrong.',
            ),
            if (onRetry != null) const SizedBox(height: 12),
            if (onRetry != null)
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
          ],
        );
    }
  }
}

class _StatusMessageCard extends StatelessWidget {
  const _StatusMessageCard({
    required this.color,
    required this.icon,
    required this.message,
    this.compact = false,
  });

  final MaterialColor color;
  final IconData icon;
  final String message;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Flexible(
            child: Text(message, style: TextStyle(color: color.shade700)),
          ),
        ],
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: color.shade700),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: TextStyle(color: color.shade800)),
          ),
        ],
      ),
    );
  }
}
