import 'dart:async';

import 'package:date_picker_timeline/date_widget.dart';
import 'package:date_picker_timeline/datetimehelper/datetimehelper.dart';
import 'package:date_picker_timeline/extra/color.dart';
import 'package:date_picker_timeline/extra/style.dart';
import 'package:date_picker_timeline/gestures/tap.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

class DatePicker extends StatefulWidget {
  /// Start Date in case user wants to show past dates
  /// If not provided calendar will start from the initialSelectedDate
  final DateTime startDate;

  /// Width of the selector
  final double width;

  /// Height of the selector
  final double height;

  /// DatePicker Controller
  final DatePickerController? controller;

  /// Text color for the selected Date
  final Color selectedTextColor;

  /// Background color for the selector
  final Color selectionColor;

  ///Background color for swipe handling
  final Color swipeSelectionColor;

  /// Text Color for the deactivated dates
  final Color deactivatedColor;

  ///Background color for each widget when not selected
  final Color backgroundColor;

  /// TextStyle for Month Value
  final TextStyle monthTextStyle;

  /// TextStyle for day Value
  final TextStyle dayTextStyle;

  /// TextStyle for the date Value
  final TextStyle dateTextStyle;

  /// Current Selected Date
  final DateTime? /*?*/ initialSelectedDate;

  /// Contains the list of inactive dates.
  /// All the dates defined in this List will be deactivated
  final List<DateTime>? inactiveDates;

  /// Contains the list of active dates.
  /// Only the dates in this list will be activated.
  final List<DateTime>? activeDates;

  /// Callback function for when a different date is selected
  final DateChangeListener? onDateChange;

  /// Max limit up to which the dates are shown.
  /// Days are counted from the startDate
  final int daysCount;

  /// Locale for the calendar default: en_us
  final String locale;

  /// Show dates in reverse order or not
  final bool reverseDays;

  /// Timeout to swipe in ms
  final Duration swipeTimeout;

  /// Padding between widget
  final double widgetMargin;

  /// Scroll extra day
  final bool scrollExtraDay;

  //Scrollphysics (change behaviour of Listview scrolling)
  final ScrollPhysics? scrollPhysics;

  DatePicker(
    this.startDate, {
    Key? key,
    this.width = 60,
    this.height = 80,
    this.controller,
    this.monthTextStyle = defaultMonthTextStyle,
    this.dayTextStyle = defaultDayTextStyle,
    this.dateTextStyle = defaultDateTextStyle,
    this.selectedTextColor = Colors.white,
    this.selectionColor = AppColors.defaultSelectionColor,
    this.deactivatedColor = AppColors.defaultDeactivatedColor,
    this.swipeSelectionColor = AppColors.defaultSwipeSelectionColor,
    this.backgroundColor = AppColors.defaultBackgroundColor,
    this.initialSelectedDate,
    this.activeDates,
    this.inactiveDates,
    this.daysCount = 500,
    this.onDateChange,
    this.locale = "en_US",
    this.reverseDays = false,
    this.widgetMargin = 3,
    this.swipeTimeout = const Duration(milliseconds: 1000),
    this.scrollExtraDay = true,
    this.scrollPhysics,
  }) : assert(
            activeDates == null || inactiveDates == null,
            "Can't "
            "provide both activated and deactivated dates List at the same time.");

  @override
  State<StatefulWidget> createState() => new _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  DateTime? _currentDate;
  DateTime? _swipeCurrentDate;

  ScrollController _controller = ScrollController();

  //Controls the scroll to be called only once
  bool startUp = true;

  late final TextStyle selectedDateStyle;
  late final TextStyle selectedMonthStyle;
  late final TextStyle selectedDayStyle;

  late final TextStyle deactivatedDateStyle;
  late final TextStyle deactivatedMonthStyle;
  late final TextStyle deactivatedDayStyle;

  @override
  void initState() {
    // Init the calendar locale
    initializeDateFormatting(widget.locale, null);
    // Set initial Values
    _currentDate = widget.initialSelectedDate!.dateWithoutTime();

    if (widget.controller != null) {
      widget.controller!._setDatePickerState(this);
    }

    this.selectedDateStyle =
        widget.dateTextStyle.copyWith(color: widget.selectedTextColor);
    this.selectedMonthStyle =
        widget.monthTextStyle.copyWith(color: widget.selectedTextColor);
    this.selectedDayStyle =
        widget.dayTextStyle.copyWith(color: widget.selectedTextColor);

    this.deactivatedDateStyle =
        widget.dateTextStyle.copyWith(color: widget.deactivatedColor);
    this.deactivatedMonthStyle =
        widget.monthTextStyle.copyWith(color: widget.deactivatedColor);
    this.deactivatedDayStyle =
        widget.dayTextStyle.copyWith(color: widget.deactivatedColor);

    super.initState();
  }

  /// Called after build and will ensure the item selected is scrolled to
  void _onAfterBuild(BuildContext context) {
    if (startUp) {
      widget.controller!
          .animateToSelection(scrollOneExtraPosition: widget.scrollExtraDay);
      startUp = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    //Ensure selected item is scrolled to
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _onAfterBuild(context);
    });

    return Container(
      height: widget.height,
      child: ListView.builder(
        //Padding zero is important in landscape mode!
        physics: widget.scrollPhysics,
        padding: EdgeInsets.zero,
        reverse: widget.reverseDays,
        itemCount: widget.daysCount,
        scrollDirection: Axis.horizontal,
        controller: _controller,
        itemBuilder: (context, index) {
          // get the date object based on the index position
          // if widget.startDate is null then use the initialDateValue
          DateTime date;
          //Duration removed because of daylight saving will mess things up
          //DateTime _date = widget.startDate.add(Duration(days: index));
          DateTime _date = widget.startDate.addDays(index);
          date = _date.dateWithoutTime();

          bool isDeactivated = false;

          // check if this date needs to be deactivated for only DeactivatedDates
          if (widget.inactiveDates != null) {
            for (DateTime inactiveDate in widget.inactiveDates!) {
              if (date.compareDateWithoutTime(inactiveDate)) {
                isDeactivated = true;
                break;
              }
            }
          }

          // check if this date needs to be deactivated for only ActivatedDates
          if (widget.activeDates != null) {
            isDeactivated = true;
            for (DateTime activateDate in widget.activeDates!) {
              // Compare the date if it is in the
              if (date.compareDateWithoutTime(activateDate)) {
                isDeactivated = false;
                break;
              }
            }
          }

          // Check if this date is the one that is currently selected
          bool isSelected = _currentDate != null
              ? date.compareDateWithoutTime(_currentDate!)
              : false;

          // Check if a swipe date is set
          bool isSwipeSelected = _swipeCurrentDate != null
              ? date.compareDateWithoutTime(_swipeCurrentDate!)
              : false;

          // Return the Date Widget
          return DateWidget(
            date: date,
            margin: widget.widgetMargin,
            monthTextStyle: isDeactivated
                ? deactivatedMonthStyle
                : isSelected
                    ? selectedMonthStyle
                    : widget.monthTextStyle,
            dateTextStyle: isDeactivated
                ? deactivatedDateStyle
                : isSelected
                    ? selectedDateStyle
                    : widget.dateTextStyle,
            dayTextStyle: isDeactivated
                ? deactivatedDayStyle
                : isSelected
                    ? selectedDayStyle
                    : widget.dayTextStyle,
            width: widget.width,
            locale: widget.locale,
            selectionColor: isSelected
                ? widget.selectionColor
                : isSwipeSelected
                    ? widget.swipeSelectionColor
                    : widget.backgroundColor,
            onDateSelected: (selectedDate) {
              // Don't notify listener if date is deactivated
              if (isDeactivated) return;

              //Call the onDateSelected
              onDateSelected(selectedDate);
            },
          );
        },
      ),
    );
  }

  //Helper to call onDateSelected which trigger onDateChange if enabled
  void onDateSelected(DateTime selectedDate) {
    // A date is selected
    if (widget.onDateChange != null) {
      widget.onDateChange!(selectedDate);
    }
    setState(() {
      _currentDate = selectedDate;
      _swipeCurrentDate = _currentDate;
    });
  }

  /// Swipedate set, will mark a date with "swipe color" and select it if timed out
  void setSwipeDate(DateTime date) {
    setState(() {
      _swipeCurrentDate = date;
    });
  }
}

class DatePickerController {
  _DatePickerState? _datePickerState;
  Timer? _swipeTimer;

  void _setDatePickerState(_DatePickerState state) {
    _datePickerState = state;
  }

  void jumpToSelection({bool scrollOneExtraPosition = false}) {
    assert(_datePickerState != null,
        'DatePickerController is not attached to any DatePicker View.');

    // jump to the current Date
    _datePickerState!._controller.jumpTo(_calculateDateOffset(
        _datePickerState!._currentDate!,
        scrollOneDayAhead: scrollOneExtraPosition));
  }

  /// This function will animate the Timeline to the currently selected Date
  void animateToSelection(
      {duration = const Duration(milliseconds: 500),
      curve = Curves.easeInOut,
      bool scrollOneExtraPosition = false}) {
    assert(_datePickerState != null,
        'DatePickerController is not attached to any DatePicker View.');

    // animate to the current date
    _datePickerState!._controller.animateTo(
        _calculateDateOffset(_datePickerState!._currentDate!,
            scrollOneDayAhead: scrollOneExtraPosition),
        duration: duration,
        curve: curve);
  }

  /// This function will animate to any date that is passed as an argument
  /// In case a date is out of range nothing will happen
  void animateToDate(DateTime date,
      {duration = const Duration(milliseconds: 500),
      curve = Curves.easeInOut,
      bool scrollOneExtraPosition = false}) {
    assert(_datePickerState != null,
        'DatePickerController is not attached to any DatePicker View.');

    //Ignore timestamp in DateTime
    date = date.dateWithoutTime();

    //Animate based on selection
    _datePickerState!._controller.animateTo(
        _calculateDateOffset(date, scrollOneDayAhead: scrollOneExtraPosition),
        duration: duration,
        curve: curve);
  }

  /// This function will animate to any date that is passed as an argument
  /// this will also set that date as the current selected date
  void setDateAndAnimate(DateTime date,
      {duration = const Duration(milliseconds: 500),
      curve = Curves.easeInOut,
      bool scrollOneExtraPosition = false}) {
    assert(_datePickerState != null,
        'DatePickerController is not attached to any DatePicker View.');

    //Ignore timestamp in DateTime
    date = date.dateWithoutTime();

    _datePickerState!._controller.animateTo(
        _calculateDateOffset(date, scrollOneDayAhead: scrollOneExtraPosition),
        duration: duration,
        curve: curve);

    if (date.compareTo(_datePickerState!.widget.startDate) >= 0 &&
        date.compareTo(_datePickerState!.widget.startDate
                .add(Duration(days: _datePickerState!.widget.daysCount))) <=
            0) {
      // date is in the range
      //Call the onDateSelected which enabled also callback to the main class
      _datePickerState!.onDateSelected(date);
    }
  }

  /// Swipe handling (easy way to move dates with swipe anywhere)
  void swipeSelection(int days) {
    assert(_datePickerState != null,
        'DatePickerController is not attached to any DatePicker View.');
    if (_datePickerState!._swipeCurrentDate == null) {
      _datePickerState!._swipeCurrentDate = _datePickerState!._currentDate;
    }

    //Find start and enddate to ensure we don't go past it
    final startDate = _datePickerState!.widget.startDate.dateWithoutTime();
    final endDate = startDate.addDays(_datePickerState!.widget.daysCount - 1);

    //No love when we are at the start or end
    if (_datePickerState!._swipeCurrentDate!
            .compareDateWithoutTime(startDate) &&
        days < 0) return;
    if (_datePickerState!._swipeCurrentDate!.compareDateWithoutTime(endDate) &&
        days > 0) return;

    //Adds days to the swipedate
    _datePickerState!
        .setSwipeDate(_datePickerState!._swipeCurrentDate!.addDays(days));
    animateToDate(_datePickerState!._swipeCurrentDate!);

    //Cancel old swipe timer if it was running
    if (_swipeTimer != null) {
      if (_swipeTimer!.isActive) _swipeTimer!.cancel();
    }

    //Make new timer that will select current swipe date when timed out
    _swipeTimer = Timer(_datePickerState!.widget.swipeTimeout, () {
      _datePickerState!.onDateSelected(_datePickerState!._swipeCurrentDate!);
    });
  }

  /// Calculate the number of pixels that needs to be scrolled to go to the
  /// date provided in the argument
  double _calculateDateOffset(DateTime date, {bool scrollOneDayAhead = false}) {
    //Remove time from startDate
    final startDate = _datePickerState!.widget.startDate.dateWithoutTime();

    //Get offset between dates
    int offset = date.difference(startDate).inDays;

    //Check if there we are going to scroll one date further
    if (scrollOneDayAhead && offset <= _datePickerState!.widget.daysCount) {
      offset++;
    }

    //Get widget size and set the date as second to the right
    //double width = _datePickerState!.context.size!.width;
    double width = MediaQuery.of(_datePickerState!.context).size.width;

    //margin: defaults to margin: EdgeInsets.all(3.0), remember it is on both sides
    double widgetMargin = _datePickerState!.widget.widgetMargin;

    //Find how many dates are showing, using with of widget
    double numInWidth =
        width / (_datePickerState!.widget.width + widgetMargin * 2);
    double numInWidthDecimal = numInWidth - numInWidth.toInt();
    int daysToEnd = _datePickerState!.widget.daysCount - offset;

    //Handle offset with right-hand
    if (offset > numInWidth.toInt() - 2) {
      //Offset corrected based on how many days are left
      offset = offset - (numInWidth.toInt() - 2);
      //Last day(s) we do not increase, stay put
      if (daysToEnd == 2) offset = offset - 1;
      if (daysToEnd == 1) offset = offset - 2;
      if (daysToEnd == 0) offset = offset - 3;
    } else {
      offset = 0;
    }

    return (offset * _datePickerState!.widget.width) +
        (offset *
            widgetMargin *
            2) + //- (daysToEnd < 1 ? widgetMargin : 0) + //-2 is here a small error of some sorts?
        (daysToEnd <= 2
            ? ((_datePickerState!.widget.width) * (1 - numInWidthDecimal)) +
                widgetMargin
            : widgetMargin); //Offset for the first item
  }
}
