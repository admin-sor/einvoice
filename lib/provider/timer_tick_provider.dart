import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final timerTickProvider =
    StateNotifierProvider.autoDispose<TimerTickStateNotifier, StateTimerTick>(
        (ref) => TimerTickStateNotifier());

class TimerTickStateNotifier extends StateNotifier<StateTimerTick> {
  TimerTickStateNotifier() : super(StateTimerTickInit());
  late Timer timer;
  void start({required int sec}) {
    timer = Timer.periodic(Duration(seconds: sec), (tmr) {
      state = StateTimerTickDo();
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void stop() {
    timer.cancel();
  }
}

abstract class StateTimerTick extends Equatable {
  final DateTime date;
  const StateTimerTick({required this.date});
  @override
  List<Object?> get props => throw UnimplementedError();
}

class StateTimerTickInit extends StateTimerTick {
  StateTimerTickInit() : super(date: DateTime.now());
}

class StateTimerTickDo extends StateTimerTick {
  StateTimerTickDo() : super(date: DateTime.now());
}

class StateTimerTickErr extends StateTimerTick {
  final String message;
  StateTimerTickErr(this.message) : super(date: DateTime.now());
}
