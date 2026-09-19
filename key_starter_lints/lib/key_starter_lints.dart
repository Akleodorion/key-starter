import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'src/abstract_class_in_widgets_folder_must_have_doc_comment.dart';
import 'src/file_name_matches_widget_class.dart';
import 'src/no_inline_build_method.dart';
import 'src/no_multi_param_concrete_widget_in_shared_widgets.dart';
import 'src/single_widget_class_per_file.dart';

PluginBase createPlugin() => _KeyStarterLints();

class _KeyStarterLints extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => const [
    FileNameMatchesWidgetClass(),
    NoMultiParamConcreteWidgetInSharedWidgets(),
    NoInlineBuildMethod(),
    SingleWidgetClassPerFile(),
    AbstractClassInWidgetsFolderMustHaveDocComment(),
  ];
}
