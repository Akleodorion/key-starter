import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:path/path.dart' as p;

import 'widget_checkers.dart';

/// A file declaring a widget class must be named after that class, in
/// snake_case — e.g. `ConceptBadge` lives in `concept_badge.dart`.
class FileNameMatchesWidgetClass extends DartLintRule {
  const FileNameMatchesWidgetClass() : super(code: _code);

  static const _code = LintCode(
    name: 'file_name_matches_widget_class',
    problemMessage:
        'The file name should be the snake_case form of the widget class '
        'name.',
    errorSeverity: DiagnosticSeverity.WARNING,
  );

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    final actualFileName = p.basenameWithoutExtension(resolver.path);
    // `main.dart` is the conventional Dart/Flutter entrypoint file name and
    // always hosts the root app widget regardless of its class name.
    if (actualFileName == 'main') return;

    context.registry.addClassDeclaration((node) {
      final element = node.declaredFragment?.element;
      if (element == null || !isWidgetClass(element)) return;

      final expectedFileName = _toSnakeCase(node.name.lexeme);
      if (actualFileName != expectedFileName) {
        reporter.atNode(node, _code);
      }
    });
  }
}

String _toSnakeCase(String pascalCase) {
  final withoutLeadingUnderscores = pascalCase.replaceFirst(RegExp('^_+'), '');
  return withoutLeadingUnderscores
      .replaceAllMapped(
        RegExp(r'(?<=[a-z0-9])[A-Z]'),
        (match) => '_${match.group(0)}',
      )
      .toLowerCase();
}
