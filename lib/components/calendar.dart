
 import 'package:examenflutteriit/l10n/l10n.dart';
import 'package:flutter/material.dart';
 import 'package:syncfusion_flutter_datepicker/datepicker.dart';

void showCalendar(BuildContext context, DateRangePickerSelectionMode selectionMode, Function(dynamic) onSubmit) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(context.l10n.oK), // Make sure L10n is correctly implemented to fetch localized strings
        content: Container(
          height: 300,
          width: 400,
          child: SfDateRangePicker(
            view: DateRangePickerView.month,
            headerHeight: 50,
            headerStyle: DateRangePickerHeaderStyle(
                textStyle: TextStyle(fontStyle: FontStyle.normal, fontSize: 25, fontWeight: FontWeight.w500)),
            selectionRadius: 30,
            monthViewSettings: DateRangePickerMonthViewSettings(firstDayOfWeek: 1),
            selectionMode: selectionMode,
            controller: DateRangePickerController(),
            selectionColor: Colors.green,
            showActionButtons: true,
            onCancel: () => Navigator.pop(context),
            onSubmit: (value) {
              Navigator.pop(context);
              onSubmit(value);
            },
            cancelText:context.l10n.close,
            confirmText:context.l10n.oK,
          ),
        ),
      );
    },
  );
}

bool isStartTimeGreaterThanEndTime(TimeOfDay startTime, TimeOfDay endTime) {
  if (startTime.hour > endTime.hour) {
    return true;
  } else if (startTime.hour == endTime.hour) {
    return startTime.minute > endTime.minute;
  }
  return false;
}

 Future<TimeOfDay?> showTimer(BuildContext context, {TimeOfDay startTime = const TimeOfDay(hour: 8, minute: 0)}) async {
   TimeOfDay? picked = await showTimePicker(
     context: context,
     initialTime: startTime,
   );

   // Additional logic to handle picked time can be implemented here
   return picked;
 }


 Future<String?> getTimeOfDay(BuildContext context) async {
   TimeOfDay? picked = await showTimer(context);
   if (picked != null) {
     String hour = picked.hour.toString().padLeft(2, '0');
     String minute = picked.minute.toString().padLeft(2, '0');
     return "$hour:$minute";
   }
   return null;
 }

