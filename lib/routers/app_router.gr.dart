// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [ActivityDetailListPage]
class ActivityDetailListRoute
    extends PageRouteInfo<ActivityDetailListRouteArgs> {
  ActivityDetailListRoute({
    Key? key,
    List<AktivitasModel>? activities,
    int? initialIndex,
    List<PageRouteInfo>? children,
  }) : super(
         ActivityDetailListRoute.name,
         args: ActivityDetailListRouteArgs(
           key: key,
           activities: activities,
           initialIndex: initialIndex,
         ),
         initialChildren: children,
       );

  static const String name = 'ActivityDetailListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ActivityDetailListRouteArgs>(
        orElse: () => const ActivityDetailListRouteArgs(),
      );
      return ActivityDetailListPage(
        key: args.key,
        activities: args.activities,
        initialIndex: args.initialIndex,
      );
    },
  );
}

class ActivityDetailListRouteArgs {
  const ActivityDetailListRouteArgs({
    this.key,
    this.activities,
    this.initialIndex,
  });

  final Key? key;

  final List<AktivitasModel>? activities;

  final int? initialIndex;

  @override
  String toString() {
    return 'ActivityDetailListRouteArgs{key: $key, activities: $activities, initialIndex: $initialIndex}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ActivityDetailListRouteArgs) return false;
    return key == other.key &&
        const ListEquality().equals(activities, other.activities) &&
        initialIndex == other.initialIndex;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      const ListEquality().hash(activities) ^
      initialIndex.hashCode;
}

/// generated route for
/// [AddAktivitasPage]
class AddAktivitasRoute extends PageRouteInfo<AddAktivitasRouteArgs> {
  AddAktivitasRoute({
    Key? key,
    AktivitasModel? existingAktivitas,
    List<PageRouteInfo>? children,
  }) : super(
         AddAktivitasRoute.name,
         args: AddAktivitasRouteArgs(
           key: key,
           existingAktivitas: existingAktivitas,
         ),
         initialChildren: children,
       );

  static const String name = 'AddAktivitasRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AddAktivitasRouteArgs>(
        orElse: () => const AddAktivitasRouteArgs(),
      );
      return AddAktivitasPage(
        key: args.key,
        existingAktivitas: args.existingAktivitas,
      );
    },
  );
}

class AddAktivitasRouteArgs {
  const AddAktivitasRouteArgs({this.key, this.existingAktivitas});

  final Key? key;

  final AktivitasModel? existingAktivitas;

  @override
  String toString() {
    return 'AddAktivitasRouteArgs{key: $key, existingAktivitas: $existingAktivitas}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AddAktivitasRouteArgs) return false;
    return key == other.key && existingAktivitas == other.existingAktivitas;
  }

  @override
  int get hashCode => key.hashCode ^ existingAktivitas.hashCode;
}

/// generated route for
/// [AddTaskScreen]
class AddTaskRoute extends PageRouteInfo<AddTaskRouteArgs> {
  AddTaskRoute({Key? key, Task? existingTask, List<PageRouteInfo>? children})
    : super(
        AddTaskRoute.name,
        args: AddTaskRouteArgs(key: key, existingTask: existingTask),
        initialChildren: children,
      );

  static const String name = 'AddTaskRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AddTaskRouteArgs>(
        orElse: () => const AddTaskRouteArgs(),
      );
      return AddTaskScreen(key: args.key, existingTask: args.existingTask);
    },
  );
}

class AddTaskRouteArgs {
  const AddTaskRouteArgs({this.key, this.existingTask});

  final Key? key;

  final Task? existingTask;

  @override
  String toString() {
    return 'AddTaskRouteArgs{key: $key, existingTask: $existingTask}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AddTaskRouteArgs) return false;
    return key == other.key && existingTask == other.existingTask;
  }

  @override
  int get hashCode => key.hashCode ^ existingTask.hashCode;
}

/// generated route for
/// [AktivitasPage]
class AktivitasRoute extends PageRouteInfo<void> {
  const AktivitasRoute({List<PageRouteInfo>? children})
    : super(AktivitasRoute.name, initialChildren: children);

  static const String name = 'AktivitasRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AktivitasPage();
    },
  );
}

/// generated route for
/// [AlarmRingingScreen]
class AlarmRingingRoute extends PageRouteInfo<AlarmRingingRouteArgs> {
  AlarmRingingRoute({
    Key? key,
    required AlarmSettings alarmSettings,
    VoidCallback? onDismiss,
    List<PageRouteInfo>? children,
  }) : super(
         AlarmRingingRoute.name,
         args: AlarmRingingRouteArgs(
           key: key,
           alarmSettings: alarmSettings,
           onDismiss: onDismiss,
         ),
         initialChildren: children,
       );

  static const String name = 'AlarmRingingRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AlarmRingingRouteArgs>();
      return AlarmRingingScreen(
        key: args.key,
        alarmSettings: args.alarmSettings,
        onDismiss: args.onDismiss,
      );
    },
  );
}

class AlarmRingingRouteArgs {
  const AlarmRingingRouteArgs({
    this.key,
    required this.alarmSettings,
    this.onDismiss,
  });

  final Key? key;

  final AlarmSettings alarmSettings;

  final VoidCallback? onDismiss;

  @override
  String toString() {
    return 'AlarmRingingRouteArgs{key: $key, alarmSettings: $alarmSettings, onDismiss: $onDismiss}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AlarmRingingRouteArgs) return false;
    return key == other.key &&
        alarmSettings == other.alarmSettings &&
        onDismiss == other.onDismiss;
  }

  @override
  int get hashCode =>
      key.hashCode ^ alarmSettings.hashCode ^ onDismiss.hashCode;
}

/// generated route for
/// [HomePage]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomePage();
    },
  );
}

/// generated route for
/// [LoginPage]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LoginPage();
    },
  );
}

/// generated route for
/// [OnboardingScreen]
class OnboardingRoute extends PageRouteInfo<void> {
  const OnboardingRoute({List<PageRouteInfo>? children})
    : super(OnboardingRoute.name, initialChildren: children);

  static const String name = 'OnboardingRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const OnboardingScreen();
    },
  );
}

/// generated route for
/// [ProfileEditPage]
class ProfileEditRoute extends PageRouteInfo<ProfileEditRouteArgs> {
  ProfileEditRoute({
    Key? key,
    required User user,
    List<PageRouteInfo>? children,
  }) : super(
         ProfileEditRoute.name,
         args: ProfileEditRouteArgs(key: key, user: user),
         initialChildren: children,
       );

  static const String name = 'ProfileEditRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ProfileEditRouteArgs>();
      return ProfileEditPage(key: args.key, user: args.user);
    },
  );
}

class ProfileEditRouteArgs {
  const ProfileEditRouteArgs({this.key, required this.user});

  final Key? key;

  final User user;

  @override
  String toString() {
    return 'ProfileEditRouteArgs{key: $key, user: $user}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ProfileEditRouteArgs) return false;
    return key == other.key && user == other.user;
  }

  @override
  int get hashCode => key.hashCode ^ user.hashCode;
}

/// generated route for
/// [ProfilePage]
class ProfileRoute extends PageRouteInfo<void> {
  const ProfileRoute({List<PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfilePage();
    },
  );
}

/// generated route for
/// [RegisterPage]
class RegisterRoute extends PageRouteInfo<void> {
  const RegisterRoute({List<PageRouteInfo>? children})
    : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RegisterPage();
    },
  );
}

/// generated route for
/// [SplashScreen]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SplashScreen();
    },
  );
}

/// generated route for
/// [TaskDetailListScreen]
class TaskDetailListRoute extends PageRouteInfo<void> {
  const TaskDetailListRoute({List<PageRouteInfo>? children})
    : super(TaskDetailListRoute.name, initialChildren: children);

  static const String name = 'TaskDetailListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const TaskDetailListScreen();
    },
  );
}

/// generated route for
/// [TaskDetailScreen]
class TaskDetailRoute extends PageRouteInfo<TaskDetailRouteArgs> {
  TaskDetailRoute({Key? key, required Task task, List<PageRouteInfo>? children})
    : super(
        TaskDetailRoute.name,
        args: TaskDetailRouteArgs(key: key, task: task),
        initialChildren: children,
      );

  static const String name = 'TaskDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<TaskDetailRouteArgs>();
      return TaskDetailScreen(key: args.key, task: args.task);
    },
  );
}

class TaskDetailRouteArgs {
  const TaskDetailRouteArgs({this.key, required this.task});

  final Key? key;

  final Task task;

  @override
  String toString() {
    return 'TaskDetailRouteArgs{key: $key, task: $task}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TaskDetailRouteArgs) return false;
    return key == other.key && task == other.task;
  }

  @override
  int get hashCode => key.hashCode ^ task.hashCode;
}

/// generated route for
/// [TaskListScreen]
class TaskListRoute extends PageRouteInfo<void> {
  const TaskListRoute({List<PageRouteInfo>? children})
    : super(TaskListRoute.name, initialChildren: children);

  static const String name = 'TaskListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const TaskListScreen();
    },
  );
}
