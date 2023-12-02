import 'package:flutter/material.dart';

import '../model/DsaDate.dart';

class DsaCalendar extends StatefulWidget {
  DsaDate date;
  DsaDate selectedDate;
  DsaCalendar(this.date, this.selectedDate, {super.key});

  @override
  State<DsaCalendar> createState() => _DsaCalendarState(date);
}

class _DsaCalendarState extends State<DsaCalendar> {
  int _currentYear;
  int _currentMonth;
  DsaDate? _selectedDay;

  _DsaCalendarState(DsaDate date) : _currentYear = date.year, _currentMonth = date.month, _selectedDay = date;

  void _nextMonth() {
    if (_currentMonth < 11) {
      setState(() {
        _currentMonth++;
      });
    } else {
      setState(() {
        _currentMonth = 0;
        _currentYear++;
      });
    }
  }

  void _previousMonth() {
    if (_currentMonth > 0) {
      setState(() {
        _currentMonth--;
      });
    } else {
      setState(() {
        _currentMonth = 11;
        _currentYear--;
      });
    }
  }

  void _onDaySelected(DsaDate selectedDay) {
    setState(() {
      _selectedDay = selectedDay;
      widget.selectedDate.copyFrom(selectedDay);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: constraints.maxWidth / 9 * 2,
                  child: FittedBox(
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _previousMonth,
                    ),
                  ),
                ),
                SizedBox(
                  width: constraints.maxWidth / 9 * 5,
                  child: GestureDetector(
                    onTap: () => _selectYear(context),
                    child:
                    FittedBox(
                      child: Row( 
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('${DsaDate.months[_currentMonth]} $_currentYear BF', style: TextStyle(fontSize: Theme.of(context).textTheme.titleLarge?.fontSize)),
                          const SizedBox(width: 6),
                          Icon(Icons.calendar_today, size: Theme.of(context).textTheme.titleLarge?.fontSize), // Kalender-Icon
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: constraints.maxWidth / 9 * 2,
                  child: FittedBox(
                    child: IconButton(
                       icon: Icon(Icons.arrow_forward),
                       onPressed: _nextMonth,
                     ),
                  ),
                )
              ],
            ),
            Expanded(
              child: MonthView(
                year: _currentYear,
                month: _currentMonth,
                onDaySelected: _onDaySelected,
                selectedDay: _selectedDay
              ),
            ),
          ],
        );
      }
    );
  }

  void _selectYear(BuildContext context) async {
    TextEditingController yearController = TextEditingController(text: '$_currentYear');
    int? selectedYear = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Jahr auswählen"),
          content: TextField(
            autofocus: true,
            controller: yearController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: "Jahr"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Abbrechen'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                int? year = int.tryParse(yearController.text);
                Navigator.of(context).pop(year);
              },
            ),
          ],
        );
      },
    );

    if (selectedYear != null && selectedYear != _currentYear) {
      setState(() {
        _currentYear = selectedYear;
      });
    }
  }
}


class MonthView extends StatelessWidget {
  final int year;
  final int month;
  final Function(DsaDate) onDaySelected;
  final DsaDate? selectedDay;

  MonthView({
    Key? key,
    required this.year,
    required this.month,
    required this.onDaySelected,
    this.selectedDay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int daysCount = DsaDate.getDaysInMonth(month);
    DsaDate firstDayOfMonth = DsaDate(year, month, 1);
    String firstDayWeekday = firstDayOfMonth.getWeekday();
    int startDayOffset = DsaDate.weekdays.indexOf(firstDayWeekday);
    int totalCells = daysCount + startDayOffset;

    return AspectRatio(
      aspectRatio: 1,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildWeekdaysHeader(),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0, // Quadratische Zellen
            ),
            itemCount: totalCells,
            itemBuilder: (context, index) {
              if (index < startDayOffset) {
                return Container(); // Leere Zellen vor dem ersten Tag des Monats
              }
              int dayNum = index + 1 - startDayOffset;
              bool isSelected = selectedDay != null &&
                  selectedDay!.year == year &&
                  selectedDay!.month == month &&
                  selectedDay!.day == dayNum;
      
              return GestureDetector(
                onTap: () => onDaySelected(DsaDate(year, month, dayNum)),
                child: Container(
                  margin: EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : null,//TODO theme color
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Center(
                    child: Text(
                      '$dayNum',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildWeekdaysHeader() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7
      ),
      itemCount: DsaDate.weekdaysShort.length,
      itemBuilder: (context, index) {
        return Center(
          child: Text(DsaDate.weekdaysShort[index]),
        );
      },
    );
  }
}

