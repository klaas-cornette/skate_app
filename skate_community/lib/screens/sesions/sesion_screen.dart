// session_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skate_community/services/sesion_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SessionScreen extends StatefulWidget {
  @override
  _SessionScreenState createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay(hour: (TimeOfDay.now().hour + (TimeOfDay.now().minute + 30) ~/ 60) % 24, minute: (TimeOfDay.now().minute + 30) % 60,);
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
    final dt =DateTime(date.year, date.month, date.day, time.hour, time.minute);
    final utcDateTime = dt.toUtc(); // Zet om naar UTC
    print(DateFormat("yyyy-MM-dd HH:mm:ss.SSSSSS'Z'").format(utcDateTime));
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

    if (DateTime.parse(endTime).difference(DateTime.parse(startTime)).inMinutes < 30) {
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
      appBar: AppBar(
        title: Text('Nieuwe Sessie'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
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
                Text('Plan je sessie',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    )),
                SizedBox(height: 20),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                      'Datum: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
                      style: TextStyle(fontSize: 16)),
                  trailing: Icon(Icons.calendar_today,
                      color: Theme.of(context).primaryColor),
                  onTap: () => _selectDate(context),
                ),
                Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Starttijd: ${_startTime.format(context)}',
                      style: TextStyle(fontSize: 16)),
                  trailing: Icon(Icons.access_time,
                      color: Theme.of(context).primaryColor),
                  onTap: () => _selectTime(context, true),
                ),
                Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Eindtijd: ${_endTime.format(context)}',
                      style: TextStyle(fontSize: 16)),
                  trailing: Icon(Icons.access_time,
                      color: Theme.of(context).primaryColor),
                  onTap: () => _selectTime(context, false),
                ),
                Divider(),
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _createSession,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child:
                      Text('Sessie Aanmaken', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
