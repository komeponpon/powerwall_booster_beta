import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';

class DateUtils {
  static void showDateTimePicker(
    BuildContext context,
    DateTime initialDateTime,
    DateTime maxDateTime,
    Function(DateTime) onDateTimeChanged,
  ) {
    DateTime now = DateTime.now();
    if (initialDateTime.isBefore(now)) {
      initialDateTime = now;
    }

    DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      minTime: now,
      maxTime: maxDateTime,
      onChanged: (date) {
        print(date);
      },
      onConfirm: (date) {
        onDateTimeChanged(date);
      },
      currentTime: initialDateTime,
      locale: LocaleType.jp,
    );
  }

  static String formattedDateTime(DateTime dateTime) {
    return '${dateTime.year}年${dateTime.month}月${dateTime.day}日 ${dateTime.hour}時${dateTime.minute}分';
  }
}
