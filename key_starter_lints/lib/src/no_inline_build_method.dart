import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'widget_checkers.dart';

/// Pages and widgets must not contain private `Widget _xxx(...)` build
/// helpers — every visually distinct section should be its own named widget
/// class instead.
class NoInlineBuildMethod extends DartLintRule {
  const NoInlineBuildMethod() : super(code: _code);

  static const _code = LintCode(
    name: 'no_inline_build_method',
    problemMessage:
        'Extract this into its own named widget class instead of a private '
        'build method.',
    errorSeverity: DiagnosticSeverity.WARNING,
  );

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodDeclaration((node) {
      if (!node.name.lexeme.startsWith('_')) return;

      final returnType = node.declaredFragment?.element.returnType;
      if (returnType == null ||
          !widgetChecker.isAssignableFromType(returnType)) {
        return;
      }

      reporter.atNode(node, _code);
    });
  }
}
