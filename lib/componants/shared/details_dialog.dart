import 'package:flutter/material.dart';
import 'package:music/data/song_model.dart';

class DetailsDialog extends StatelessWidget {
  final Song song;

  const DetailsDialog({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Details',
        style: TextStyle(fontSize: 16.0),
      ),
      content: SizedBox(
        width: 350.0,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: ListBody(
            children: <Widget>[
              Text("Name: ${song.filePath?.split('/').last ?? 'Unknown'}"),
              Text("Created At: ${formatDateTime(song.createdAt!)}"),
              const Text("Artist:"),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Close'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

String formatDateTime(DateTime dateTime) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  String hour = twoDigits(dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12);
  String minute = twoDigits(dateTime.minute);
  String period = dateTime.hour >= 12 ? 'PM' : 'AM';
  String day = dateTime.day.toString();
  List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  String month = months[dateTime.month - 1];
  String year = dateTime.year.toString();

  return '$hour:$minute $period, $day $month $year';
}
