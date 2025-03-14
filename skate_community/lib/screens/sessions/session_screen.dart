// session_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skate_community/screens/widgets/background_wrapper.dart';
import 'package:skate_community/services/sesion_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:skate_community/screens/widgets/footer_widget.dart';

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key});

  @override
  _SessionScreenState createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay(
    hour: (TimeOfDay.now().hour + (TimeOfDay.now().minute + 30) ~/ 60) % 24,
    minute: (TimeOfDay.now().minute + 30) % 60,
  );
  String? _selectedSkatepark;
  List<Map<String, dynamic>> _skateparks = [];
  final SesionService _sesionService = SesionService();
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _fetchSkateparks();
  }

  Future<void> _fetchSkateparks() async {
    final response = await supabase.from('skateparks').select('id, name');
    setState(() {
      _skateparks = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          _startTime = pickedTime;
        } else {
          _endTime = pickedTime;
        }
      });
    }
  }

  String _combineDateAndTime(DateTime date, TimeOfDay time) {
    final dt =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    final utcDateTime = dt.toUtc(); // Zet om naar UTC
    return DateFormat("yyyy-MM-dd HH:mm:ss.SSSSSS'Z'").format(utcDateTime);
  }

  Future<void> _createSession() async {
    if (_selectedSkatepark == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kies een skatepark!')),
      );
      return;
    }

    final startTime = _combineDateAndTime(_selectedDate, _startTime);
    final endTime = _combineDateAndTime(_selectedDate, _endTime);

    if (startTime.compareTo(endTime) >= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Eindtijd moet na de starttijd zijn!')),
      );
      return;
    }

    if (DateTime.now().compareTo(DateTime.parse(startTime)) >= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Starttijd moet in de toekomst zijn!')),
      );
      return;
    }

    if (DateTime.now().compareTo(DateTime.parse(endTime)) >= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Eindtijd moet in de toekomst zijn!')),
      );
      return;
    }

    if (DateTime.parse(endTime)
            .difference(DateTime.parse(startTime))
            .inMinutes <
        30) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sessie moet minimaal 30 minuten duren!')),
      );
      return;
    }

    await _sesionService.createSession(startTime, endTime, _selectedSkatepark!);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sessie succesvol aangemaakt!')),
    );
    setState(() {
      _selectedDate = DateTime.now();
      _startTime = TimeOfDay.now();
      _endTime = TimeOfDay.now();
      _selectedSkatepark = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0C1033), Color(0xFF9AC4F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            automaticallyImplyLeading: false,
            title: const Text(
              'Nieuwe Sessie',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
        ),
      ),
      body: BackgroundWrapper(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 400, // Limiteer de breedte van de card
              ),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 4.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Datum: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF0C1033),
                          ),
                        ),
                        trailing: const Icon(
                          Icons.calendar_today,
                          color: Color(0xFF0C1033),
                        ),
                        onTap: () => _selectDate(context),
                      ),
                      const Divider(),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Starttijd: ${_startTime.format(context)}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF0C1033),
                          ),
                        ),
                        trailing: const Icon(
                          Icons.access_time,
                          color: Color(0xFF0C1033),
                        ),
                        onTap: () => _selectTime(context, true),
                      ),
                      const Divider(),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Eindtijd: ${_endTime.format(context)}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF0C1033),
                          ),
                        ),
                        trailing: const Icon(
                          Icons.access_time,
                          color: Color(0xFF0C1033),
                        ),
                        onTap: () => _selectTime(context, false),
                      ),
                      const Divider(),
                      DropdownButtonFormField<String>(
                        value: _selectedSkatepark,
                        items: _skateparks.map((skatepark) {
                          return DropdownMenuItem(
                            value: skatepark['id'].toString(),
                            child: Text(skatepark['name']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSkatepark = value;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Kies een Skatepark',
                          labelStyle: const TextStyle(color: Color(0xFF0C1033)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF0C1033)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _createSession,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          backgroundColor: const Color(0xFF0C1033),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        child: const Text(
                          'Sessie Aanmaken',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: FooterWidget(currentIndex: 3),
    );
  }
}
