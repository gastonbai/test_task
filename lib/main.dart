import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Дневник Настроения',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static List<Widget> _widgetOptions = <Widget>[
    MoodDiary(),
    StatisticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Дневник Настроения'),
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: 'Дневник',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Статистика',
          ),
        ],
      ),
    );
  }
}

class MoodDiary extends StatefulWidget {
  @override
  _MoodDiaryState createState() => _MoodDiaryState();
}

class _MoodDiaryState extends State<MoodDiary> {
  final Map<String, List<String>> feelings = {
    'Счастье': [
      'Радость',
      'Эйфория',
      'Удовлетворение',
      'Оптимизм',
      'Воодушевление'
    ],
    'Грусть': ['Тоска', 'Печаль', 'Одиночество', 'Разочарование', 'Ностальгия'],
    'Тревога': [
      'Беспокойство',
      'Страх',
      'Неуверенность',
      'Стресс',
      'Напряженность'
    ],
  };

  Map<String, String?> selectedSubFeelings = {};
  double stressLevel = 0;
  double selfEsteem = 0;
  String notes = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            ...feelings.keys.map((feeling) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(feeling,
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Выберите подчувство',
                    ),
                    value: selectedSubFeelings[feeling],
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedSubFeelings[feeling] = newValue;
                      });
                    },
                    items: feelings[feeling]!
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          children: [
                            Icon(Icons.mood,
                                color: Theme.of(context).colorScheme.primary),
                            SizedBox(width: 10),
                            Text(value),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            }).toList(),
            SizedBox(height: 16),
            Text('Уровень стресса',
                style: Theme.of(context).textTheme.titleMedium),
            Slider(
              value: stressLevel,
              min: 0,
              max: 10,
              divisions: 10,
              label: stressLevel.round().toString(),
              onChanged: (double newValue) {
                setState(() {
                  stressLevel = newValue;
                });
              },
            ),
            SizedBox(height: 16),
            Text('Самооценка', style: Theme.of(context).textTheme.titleMedium),
            Slider(
              value: selfEsteem,
              min: 0,
              max: 10,
              divisions: 10,
              label: selfEsteem.round().toString(),
              onChanged: (double newValue) {
                setState(() {
                  selfEsteem = newValue;
                });
              },
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Заметки',
              ),
              maxLines: null,
              onChanged: (text) {
                notes = text;
              },
            ),
            SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CalendarScreen()),
                );
              },
              child: Text('Перейти к Календарю'),
            ),
          ],
        ),
      ),
    );
  }
}

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Календарь'),
        actions: [
          IconButton(
            icon: Icon(Icons.today),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
            },
          ),
        ],
      ),
      body: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            setState(() {
              _calendarFormat = format;
            });
          }
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
      ),
    );
  }
}

class StatisticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Экран статистики будет здесь!',
          style: Theme.of(context).textTheme.titleLarge),
    );
  }
}
