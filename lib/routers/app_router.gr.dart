// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

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
}

/// generated route for
/// [AlarmRingingScreen]
class AlarmRingingRoute extends PageRouteInfo<AlarmRingingRouteArgs> {
  AlarmRingingRoute({
    Key? key,
    required AlarmSettings alarmSettings,
    List<PageRouteInfo>? children,
  }) : super(
         AlarmRingingRoute.name,
         args: AlarmRingingRouteArgs(key: key, alarmSettings: alarmSettings),
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
      );
    },
  );
}

class AlarmRingingRouteArgs {
  const AlarmRingingRouteArgs({this.key, required this.alarmSettings});

  final Key? key;

  final AlarmSettings alarmSettings;

  @override
  String toString() {
    return 'AlarmRingingRouteArgs{key: $key, alarmSettings: $alarmSettings}';
  }
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
