import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'widget_checkers.dart';

/// A file must declare at most one widget class. `State`/`ConsumerState`
/// counterparts and `CustomPainter` subclasses are not widgets and may still
/// share the file.
class SingleWidgetClassPerFile extends DartLintRule {
  const SingleWidgetClassPerFile() : super(code: _code);

  static const _code = LintCode(
    name: 'single_widget_class_per_file',
    problemMessage: 'A file must declare at most one widget class.',
    errorSeverity: DiagnosticSeverity.WARNING,
  );

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addCompilationUnit((node) {
      final widgetClasses = node.declarations
          .whereType<ClassDeclaration>()
          .where((declaration) {
            final element = declaration.declaredFragment?.element;
            return element != null && isWidgetClass(element);
          })
          .toList();

      if (widgetClasses.length <= 1) return;

      for (final declaration in widgetClasses.skip(1)) {
        reporter.atNode(declaration, _code);
      }
    });
  }
}
