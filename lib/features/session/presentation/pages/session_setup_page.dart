import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/features/session/presentation/pages/lesson_page.dart';
import 'package:key_starter/features/session/presentation/providers/session_setup_notifier.dart';
import 'package:key_starter/features/session/presentation/providers/session_setup_state.dart';
import 'package:key_starter/features/session/presentation/widgets/session_setup_error_view.dart';
import 'package:key_starter/features/session/presentation/widgets/session_setup_layout.dart';
import 'package:key_starter/features/session/presentation/widgets/session_setup_loading_view.dart';

/// Point d'entrée de la configuration d'une session.
///
/// Ce widget est un routeur d'état pur : il délègue chaque état de
/// [sessionSetupNotifierProvider] à un widget dédié et utilise [ref.listen]
/// pour déclencher la navigation vers [LessonPage] en effet de bord
/// (sans provoquer de rebuild). Au retour de [LessonPage], [resetToReady]
/// remet le notifier en état [SessionSetupLoaded] pour permettre une
/// nouvelle configuration.
class SessionSetupPage extends ConsumerWidget {
  const SessionSetupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<SessionSetupState>(sessionSetupNotifierProvider, (_, next) {
      if (next is SessionSetupCreated) {
        Navigator.of(context)
            .push(
              MaterialPageRoute(
                builder: (_) => LessonPage(session: next.session),
              ),
            )
            .then(
              (_) => ref
                  .read(sessionSetupNotifierProvider.notifier)
                  .resetToReady(),
            );
      }
    });

    return switch (ref.watch(sessionSetupNotifierProvider)) {
      SessionSetupInitial() ||
      SessionSetupLoading() ||
      SessionSetupCreated() => const SessionSetupLoadingView(),
      SessionSetupLoaded() => const SessionSetupLayout(),
      SessionSetupError(:final message) => SessionSetupErrorView(
        message: message,
      ),
    };
  }
}
