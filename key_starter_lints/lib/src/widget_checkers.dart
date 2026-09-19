import 'package:analyzer/dart/element/element.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Matches `StatelessWidget` and its subtypes (e.g. Riverpod's
/// `ConsumerWidget`).
const statelessWidgetChecker = TypeChecker.fromName(
  'StatelessWidget',
  packageName: 'flutter',
);

/// Matches `StatefulWidget` and its subtypes (e.g. Riverpod's
/// `ConsumerStatefulWidget`).
const statefulWidgetChecker = TypeChecker.fromName(
  'StatefulWidget',
  packageName: 'flutter',
);

/// Matches the `Widget` type itself.
const widgetChecker = TypeChecker.fromName('Widget', packageName: 'flutter');

/// Whether [element] declares a widget class (`StatelessWidget` or
/// `StatefulWidget`, including their Riverpod `Consumer*` subtypes).
bool isWidgetClass(Element element) =>
    statelessWidgetChecker.isAssignableFrom(element) ||
    statefulWidgetChecker.isAssignableFrom(element);
