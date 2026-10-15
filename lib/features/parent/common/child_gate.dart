import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skoolstar_teacher_module/core/router/app_routes.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_empty_state.dart';
import 'package:skoolstar_teacher_module/core/widgets/loading_view.dart';
import 'package:skoolstar_teacher_module/features/parent/common/children_cubit.dart';

/// Shows [builder] only when a child is selected; otherwise the right
/// loading / error / "no children" screen, so no parent screen has to deal
/// with those cases itself.
class ChildGate extends StatelessWidget {
  const ChildGate({required this.builder, super.key});

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChildrenCubit, ChildrenState>(
      builder: (context, state) => switch (state) {
        ChildrenLoaded(:final selected) when selected != null => builder(
          context,
        ),
        ChildrenLoaded() => AppEmptyState(
          icon: Icons.child_care_rounded,
          title: 'No children linked yet',
          subtitle:
              'Your account has no children on it. Please contact the school '
              'to link your child, then pull to refresh.',
          action: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () =>
                    context.read<ChildrenCubit>().load(refresh: true),
                child: const Text('Check again'),
              ),
              TextButton(
                onPressed: () => context.push(AppRoutes.selectRolePath),
                child: const Text('Switch role'),
              ),
            ],
          ),
        ),
        ChildrenError(:final message) => ErrorView(
          message: message,
          onRetry: () => context.read<ChildrenCubit>().load(),
        ),
        _ => const LoadingView(),
      },
    );
  }
}
