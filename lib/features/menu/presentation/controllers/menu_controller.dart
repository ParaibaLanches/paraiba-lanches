import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedCategoryNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void select(int? id) => state = id;
}
