import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../providers/reflections_provider.dart';
import '../models/reflection_entry.dart';
import '../utils/safe_provider_base.dart';
import 'reflection_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> with SafeStateMixin {
  late final ValueNotifier<List<ReflectionEntry>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<ReflectionEntry> _getEventsForDay(DateTime day) {
    final provider = Provider.of<ReflectionsProvider>(context, listen: false);
    final reflection = provider.getReflectionForDate(day);
    return reflection != null ? [reflection] : [];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reflection Calendar'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Consumer<ReflectionsProvider>(
            builder: (context, provider, child) {
              return TableCalendar<ReflectionEntry>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                eventLoader: _getEventsForDay,
                startingDayOfWeek: StartingDayOfWeek.monday,
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  weekendTextStyle: TextStyle(color: theme.colorScheme.error),
                  holidayTextStyle: TextStyle(color: theme.colorScheme.error),
                  markerDecoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                  formatButtonShowsNext: false,
                  formatButtonDecoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  formatButtonTextStyle: TextStyle(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    safeSetState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    _selectedEvents.value = _getEventsForDay(selectedDay);
                  }
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    safeSetState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
              );
            },
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ValueListenableBuilder<List<ReflectionEntry>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                if (value.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    final reflection = value[index];
                    return _buildReflectionCard(reflection);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton:
          _selectedDay != null
              ? FloatingActionButton(
                onPressed: () => _createOrEditReflection(_selectedDay!),
                tooltip:
                    'Add reflection for ${DateFormat('MMM d').format(_selectedDay!)}',
                child: const Icon(Icons.add),
              )
              : null,
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final isToday =
        _selectedDay != null && isSameDay(_selectedDay!, DateTime.now());

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              isToday
                  ? 'No reflection for today yet'
                  : 'No reflection for ${DateFormat('MMMM d, y').format(_selectedDay!)}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isToday
                  ? 'Tap the + button to start reflecting'
                  : 'Tap the + button to add a reflection',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReflectionCard(ReflectionEntry reflection) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            Icons.auto_stories,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          reflection.prompt,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              reflection.reflection,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Written at ${DateFormat('h:mm a').format(reflection.createdAt)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _viewReflection(reflection),
      ),
    );
  }

  void _createOrEditReflection(DateTime date) {
    final provider = Provider.of<ReflectionsProvider>(context, listen: false);
    final existingReflection = provider.getReflectionForDate(date);

    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder:
                (context) => ReflectionDetailScreen(
                  date: date,
                  reflection: existingReflection,
                ),
          ),
        )
        .then((_) {
          // Refresh the selected events when returning from detail screen
          _selectedEvents.value = _getEventsForDay(_selectedDay!);
        });
  }

  void _viewReflection(ReflectionEntry reflection) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder:
                (context) => ReflectionDetailScreen(
                  date: reflection.date,
                  reflection: reflection,
                ),
          ),
        )
        .then((_) {
          // Refresh the selected events when returning from detail screen
          _selectedEvents.value = _getEventsForDay(_selectedDay!);
        });
  }
}
