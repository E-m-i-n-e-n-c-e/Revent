import 'package:events_manager/models/event.dart';

final List<Event> sampleEvents = [
  Event(
    title: 'Hack the Box: Cyber Challenge',
    description:
        'Join us for an action-packed Hack the Box Challenge! Solve puzzles, crack codes, and compete to top the leaderboard. Open to all skill...',
    startTime: DateTime.now().copyWith(hour: 16, minute: 30),
    endTime: DateTime.now().copyWith(hour: 17, minute: 30),
    clubId: 'cyberarc',
    venue: ' ',
  ),
  Event(
    title: 'Code Smart: Problem-Solving 101',
    description:
        'Level up your coding game and dive into the fundamentals of algorithms, data structures, and problem-solving techniques.',
    startTime: DateTime.now().copyWith(hour: 17, minute: 30),
    endTime: DateTime.now().copyWith(hour: 18, minute: 30),
    clubId: 'codersclub',
    venue: 'AC 404',
  ),
];
