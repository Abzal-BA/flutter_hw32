#!/usr/bin/env bash
set -euo pipefail

flutter test --coverage

echo
echo "Coverage lines for key files:"
grep -n "lib/features/tasks/data/models/task_model.dart" coverage/lcov.info || true
grep -n "lib/features/tasks/domain/usecases/add_task_usecase.dart" coverage/lcov.info || true
