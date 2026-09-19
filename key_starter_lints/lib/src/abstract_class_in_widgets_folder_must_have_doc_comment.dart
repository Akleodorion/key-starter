import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Any abstract class declared in a `widgets/` folder (the Abstract Widget
/// pattern itself, or a companion abstraction such as a data contract used by
/// several widgets) must have a class-level doc comment explaining what it
/// does, the contract it imposes on implementers, a usage example, and a
/// `Voir aussi`/`See also` reference to a real implementation.
class AbstractClassInWidgetsFolderMustHaveDocComment extends DartLintRule {
  const AbstractClassInWidgetsFolderMustHaveDocComment() : super(code: _code);

  static const _code = LintCode(
    name: 'abstract_class_in_widgets_folder_must_have_doc_comment',
    problemMessage:
        'Abstract classes declared in a widgets/ folder must have a '
        'documentation comment explaining the pattern and its contract for '
        'implementers.',
    errorSeverity: DiagnosticSeverity.WARNING,
  );

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    if (!_isInWidgetsFolder(resolver.path)) return;

    context.registry.addClassDeclaration((node) {
      if (node.abstractKeyword == null) return;
      if (node.documentationComment == null) {
        reporter.atNode(node, _code);
      }
    });
  }
}

bool _isInWidgetsFolder(String path) {
  final normalized = path.replaceAll('\\', '/');
  return normalized.contains('/lib/') && normalized.contains('/widgets/');
}
