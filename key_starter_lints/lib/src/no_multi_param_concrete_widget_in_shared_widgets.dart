import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'widget_checkers.dart';

/// A `ref.watch(xProvider)`/`ref.read(xProvider)` call, capturing the
/// provider identifier in group 1.
final _providerReadPattern = RegExp(r'ref\.(?:watch|read)\(\s*([A-Za-z0-9_]+)');

/// A shared widget (declared in `core/widgets/` or the app-shell
/// `presentation/widgets/`, i.e. not scoped to a single feature) must not be
/// instantiated with 2+ arguments that read from the same provider — that
/// widget should read the provider itself via the Abstract Widget pattern
/// instead of receiving its fields as parameters.
class NoMultiParamConcreteWidgetInSharedWidgets extends DartLintRule {
  const NoMultiParamConcreteWidgetInSharedWidgets() : super(code: _code);

  static const _code = LintCode(
    name: 'no_multi_param_concrete_widget_in_shared_widgets',
    problemMessage:
        'This widget is instantiated with 2+ fields read from the same '
        'provider — use the Abstract Widget pattern so the widget reads the '
        'provider itself instead.',
    errorSeverity: DiagnosticSeverity.WARNING,
  );

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      final classElement = node.constructorName.type.element;
      if (classElement == null ||
          !isWidgetClass(classElement) ||
          !_isDeclaredInSharedWidgetPath(classElement)) {
        return;
      }

      final providerNames = <String>[];
      for (final argument in node.argumentList.arguments) {
        final isKeyArgument =
            argument is NamedExpression && argument.name.label.name == 'key';
        if (isKeyArgument) continue;

        final expression = argument is NamedExpression
            ? argument.expression
            : argument;
        final providerName = _resolveProviderName(expression);
        if (providerName != null) providerNames.add(providerName);
      }

      final hasDuplicatedProvider =
          providerNames.toSet().length != providerNames.length;
      if (hasDuplicatedProvider) {
        reporter.atNode(node, _code);
      }
    });
  }
}

/// Finds the provider identifier this argument's value is derived from, be it
/// a direct `ref.watch(xProvider)`/`ref.read(xProvider)` call, or a local
/// variable initialized from one (e.g. `final settings = ref.watch(x); ...
/// settings.field`).
String? _resolveProviderName(Expression expression) {
  final directMatch = _providerReadPattern.firstMatch(expression.toSource());
  if (directMatch != null) return directMatch.group(1);

  final rootName = _rootIdentifierName(expression);
  if (rootName == null) return null;

  final initializer = _findLocalVariableInitializer(expression, rootName);
  if (initializer == null) return null;

  return _providerReadPattern.firstMatch(initializer.toSource())?.group(1);
}

String? _rootIdentifierName(Expression expression) {
  if (expression is SimpleIdentifier) return expression.name;
  if (expression is PrefixedIdentifier) return expression.prefix.name;
  return null;
}

Expression? _findLocalVariableInitializer(Expression expression, String name) {
  final body = expression.thisOrAncestorOfType<BlockFunctionBody>();
  final statements = body?.block.statements;
  if (statements == null) return null;

  for (final statement in statements) {
    if (statement is! VariableDeclarationStatement) continue;
    for (final variable in statement.variables.variables) {
      if (variable.name.lexeme == name) return variable.initializer;
    }
  }
  return null;
}

bool _isDeclaredInSharedWidgetPath(Element classElement) {
  final path = classElement.library?.firstFragment.source.fullName;
  if (path == null) return false;

  final normalized = path.replaceAll('\\', '/');
  if (normalized.contains('/lib/features/')) return false;
  return normalized.contains('/lib/core/widgets/') ||
      normalized.contains('/lib/presentation/widgets/');
}
