///Dart imports

import 'package:appointment/home/OnHomeView.dart';
import 'package:appointment/home/presenter/HomePresentor.dart';
import 'package:appointment/utils/Toast.dart';
import 'package:appointment/utils/values/Constant.dart';
///Package imports
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

///calendar import
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../sample.dart';
import 'model/CalendarEvent.dart';
import 'model/CalendarList.dart';


/// Widget of getting started calendar
class GettingStartedCalendar extends SampleView {
  GettingStartedCalendar();

  @override
  _GettingStartedCalendarState createState() => _GettingStartedCalendarState();
}

class _GettingStartedCalendarState extends SampleViewState implements OnHomeView{

  List<DateTime> _blackoutDates;
  _MeetingDataSource _events;
  CalendarController _calendarController;

  final List<CalendarView> _allowedViews = <CalendarView>[
    CalendarView.day,
    CalendarView.week,
    CalendarView.workWeek,
    CalendarView.month,
    CalendarView.schedule
  ];

  bool _showLeadingAndTrailingDates = true;
  bool _showDatePickerButton = true;
  bool _allowViewNavigation = true;

  ScrollController _controller;

  GlobalKey _globalKey;
  List<Item> _list = List.empty(growable: true);
  List<Item> itemList = List.empty(growable: true);
  List<EventItem> eventItem = List.empty(growable: true);
  // List<CalendarEvent> calendarEventList = List.empty(growable: true);

  HomePresenter _presenter;
  bool isVisible;
  SharedPreferences _sharedPreferences;
  
  
  @override
  void initState() {
    init();


    _showLeadingAndTrailingDates = true;
    _showDatePickerButton = true;
    _allowViewNavigation = true;
    _calendarController = CalendarController();
    _calendarController.view = CalendarView.day;
    _globalKey = GlobalKey();
    _controller = ScrollController();
    _blackoutDates = <DateTime>[];
    _events = _MeetingDataSource(<_Meeting>[]);
    super.initState();
  }

  init() async{
    _sharedPreferences = await SharedPreferences.getInstance();

    _presenter = new HomePresenter(this,token: Constant.token);

    _presenter.attachView(this);

    // print('ACCESS_TOKEN:::::${_sharedPreferences.getString(Constant.ACCESS_TOKEN)}');
    _presenter.getCalendar(_sharedPreferences.getString(Constant.ACCESS_TOKEN));
    _presenter.getCalendarEvent(_sharedPreferences.getString(Constant.ACCESS_TOKEN));
  }

  @override
  Widget build([BuildContext context]) {
    final Widget calendar = Theme(

      /// The key set here to maintain the state,
      ///  when we change the parent of the widget
        key: _globalKey,
        data: ThemeData(backgroundColor: Colors.grey),
        child: _getGettingStartedCalendar(_calendarController, _events,
            _onViewChanged, scheduleViewBuilder));

    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: isVisible == false ?Row(children: <Widget>[
          Expanded(
            flex: 1,
            child: _calendarController.view == CalendarView.month && model.isWeb && screenHeight < 800
                ? Scrollbar(
                isAlwaysShown: true,
                controller: _controller,
                child: ListView(
                  controller: _controller,
                  children: <Widget>[
                    Container(
                      color: Colors.grey,
                      height: 600,
                      child: calendar,
                    )
                  ],
                ))
                : Container(color: Colors.amber, child: calendar),
          )
        ]):Center(child: CircularProgressIndicator(),),
    );
  }

  /// The method called whenever the calendar view navigated to previous/next
  /// view or switched to different calendar view, based on the view changed
  /// details new appointment collection added to the calendar
  void _onViewChanged(ViewChangedDetails visibleDatesChangedDetails) {
    final List<_Meeting> appointment = <_Meeting>[];
    _events.appointments.clear();
    /// Creates new appointment collection based on
    /// the visible dates in calendar.
    if (_calendarController.view != CalendarView.schedule) {
        for (int j = 0; j < eventItem.length; j++) {
          appointment.add(_Meeting(
            eventName:eventItem[j].summary,
            from: eventItem[j].start.dateTime.toLocal(),
            to:eventItem[j].end.dateTime.toLocal(),
            background:Colors.blue,
            isAllDay:false,
          ));
        }
    }
    else {
        for (int j = 0; j < eventItem.length; j++) {
              appointment.add(_Meeting(
              eventName:eventItem[j].summary,
              from: eventItem[j].start.dateTime,
              to:eventItem[j].end.dateTime,
              background:Colors.blue,
              isAllDay:false,
          ));
        }
    }

    for (int i = 0; i < eventItem.length; i++) {
      _events.appointments.add(appointment[i]);
    }

    /// Resets the newly created appointment collection to render
    /// the appointments on the visible dates.
    // _events.notifyListeners(CalendarDataSourceAction.reset, appointment);
  }

  // @override
  // Widget buildSettings(BuildContext context) {
  //   return StatefulBuilder(
  //       builder: (BuildContext context, StateSetter stateSetter) {
  //         return ListView(
  //           shrinkWrap: true,
  //           children: <Widget>[
  //             Container(
  //               child: Row(
  //                 crossAxisAlignment: CrossAxisAlignment.center,
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 mainAxisSize: MainAxisSize.max,
  //                 children: <Widget>[
  //                   Text('Allow view navigation',
  //                       style: TextStyle(fontSize: 16.0, color: Colors.black)),
  //                   Container(
  //                     padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
  //                     child: Theme(
  //                       data: Theme.of(context).copyWith(
  //                           canvasColor: Colors.blueAccent),
  //                       child: Container(
  //                         alignment: Alignment.centerLeft,
  //                         child: Transform.scale(
  //                             scale: 0.8,
  //                             child: CupertinoSwitch(
  //                               activeColor: Colors.red,
  //                               value: _allowViewNavigation,
  //                               onChanged: (bool value) {
  //                                 setState(() {
  //                                   _allowViewNavigation = value;
  //                                   stateSetter(() {});
  //                                 });
  //                               },
  //                             )),
  //                       ),
  //                     ),
  //                   )
  //                 ],
  //               ),
  //             ),
  //             Container(
  //               child: Row(
  //                 crossAxisAlignment: CrossAxisAlignment.center,
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 mainAxisSize: MainAxisSize.max,
  //                 children: <Widget>[
  //                   Text('Show date picker button',
  //                       style: TextStyle(fontSize: 16.0, color: Colors.black)),
  //                   Container(
  //                     padding: const EdgeInsets.all(0),
  //                     child: Theme(
  //                       data: Theme.of(context).copyWith(
  //                           canvasColor: Colors.deepOrange),
  //                       child: Container(
  //                         alignment: Alignment.centerLeft,
  //                         child: Transform.scale(
  //                             scale: 0.8,
  //                             child: CupertinoSwitch(
  //                               activeColor: Colors.amber,
  //                               value: _showDatePickerButton,
  //                               onChanged: (bool value) {
  //                                 setState(() {
  //                                   _showDatePickerButton = value;
  //                                   stateSetter(() {});
  //                                 });
  //                               },
  //                             )),
  //                       ),
  //                     ),
  //                   )
  //                 ],
  //               ),
  //             ),
  //             Container(
  //               child: Row(
  //                 crossAxisAlignment: CrossAxisAlignment.center,
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 mainAxisSize: MainAxisSize.max,
  //                 children: <Widget>[
  //                   Expanded(
  //                       child: Text('Show trailing and leading dates',
  //                           style:
  //                           TextStyle(fontSize: 16.0, color: Colors.black))),
  //                   Container(
  //                     padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
  //                     child: Theme(
  //                       data: Theme.of(context).copyWith(
  //                           canvasColor: Colors.amber),
  //                       child: Container(
  //                           child: Align(
  //                             alignment: Alignment.centerLeft,
  //                             child: Transform.scale(
  //                                 scale: 0.8,
  //                                 child: CupertinoSwitch(
  //                                   activeColor: Colors.blue,
  //                                   value: _showLeadingAndTrailingDates,
  //                                   onChanged: (bool value) {
  //                                     setState(() {
  //                                       _showLeadingAndTrailingDates = value;
  //                                       stateSetter(() {});
  //                                     });
  //                                   },
  //                                 )),
  //                           )),
  //                     ),
  //                   )
  //                 ],
  //               ),
  //             ),
  //           ],
  //         );
  //       });
  // }

  /// Returns the calendar widget based on the properties passed.
  SfCalendar _getGettingStartedCalendar(
      [CalendarController _calendarController,
        CalendarDataSource _calendarDataSource,
        ViewChangedCallback viewChangedCallback,
        dynamic scheduleViewBuilder]) {
    return SfCalendar(
        controller: _calendarController,
        dataSource: _calendarDataSource,
        allowedViews: _allowedViews,
        scheduleViewMonthHeaderBuilder: scheduleViewBuilder,
        showNavigationArrow: false,
        showDatePickerButton: _showDatePickerButton,
        allowViewNavigation: _allowViewNavigation,
        onViewChanged: viewChangedCallback,
        blackoutDates: _blackoutDates,
        blackoutDatesTextStyle: TextStyle(
            decoration: false? null : TextDecoration.lineThrough,
            color: Colors.red),
        monthViewSettings: MonthViewSettings(
            appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
            showTrailingAndLeadingDates: _showLeadingAndTrailingDates,
            appointmentDisplayCount: 2,
        ),
       timeSlotViewSettings: TimeSlotViewSettings(
           minimumAppointmentDuration: const Duration(minutes: 60)),
      onTap: (val){
          print("clicked");
      },
    );
  }

  @override
  onShowLoader() {
    setState(() {
      isVisible = true;
    });
  }

  @override
  onHideLoader() {
    setState(() {
      isVisible = false;
    });
  }

  @override
  onErrorHandler(String message){
    Toast toast = Toast();
    toast.overLay = false;
    toast.showOverLay(message, Colors.white, Colors.black54, context);
    setState(() {
      isVisible = false;
    });
  }

  @override
  onSuccessRes(response) {
    setState(() {
      List<dynamic> data = response;
      _list.addAll(data.map((i) => Item.fromJson(i)).toList());

      for(int i=0;i<data.length;i++){
        if(data[i]['accessRole']=="owner"){
          itemList.add(Item.fromJson(data[i]));
        }
      }
    });
  }

  Map<String, dynamic> map;
  @override
  onEventSuccess(response,calendarResponse) {

    print("success ${response.runtimeType}");
    setState(() {
      eventItem.clear();
      map = calendarResponse;
      List<dynamic> data = response;
      eventItem.addAll(data.map((e)=> EventItem.fromJson(e)).toList());

    });
  }
}

/// Returns the month name based on the month value passed from date.
String _getMonthDate(int month) {
  if (month == 01) {
    return 'January';
  } else if (month == 02) {
    return 'February';
  } else if (month == 03) {
    return 'March';
  } else if (month == 04) {
    return 'April';
  } else if (month == 05) {
    return 'May';
  } else if (month == 06) {
    return 'June';
  } else if (month == 07) {
    return 'July';
  } else if (month == 08) {
    return 'August';
  } else if (month == 09) {
    return 'September';
  } else if (month == 10) {
    return 'October';
  } else if (month == 11) {
    return 'November';
  } else {
    return 'December';
  }
}

/// Returns the builder for schedule view.
Widget scheduleViewBuilder(
    BuildContext buildContext, ScheduleViewMonthHeaderDetails details) {
  final String monthName = _getMonthDate(details.date.month);
  return Stack(
    children: [
      Image(
          image: ExactAssetImage('images/' + monthName + '.png'),
          fit: BoxFit.cover,
          width: details.bounds.width,
          height: details.bounds.height),
      Positioned(
        left: 55,
        right: 0,
        top: 20,
        bottom: 0,
        child: Text(
          monthName + ' ' + details.date.year.toString(),
          style: TextStyle(fontSize: 18),
        ),
      )
    ],
  );
}

/// An object to set the appointment collection data source to collection, which
/// used to map the custom appointment data to the calendar appointment, and
/// allows to add, remove or reset the appointment collection.
class _MeetingDataSource extends CalendarDataSource {
  _MeetingDataSource(this.source);

  List<_Meeting> source;

  @override
  List<dynamic> get appointments => source;

  @override
  DateTime getStartTime(int index) {
    return source[index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return source[index].to;
  }

  @override
  bool isAllDay(int index) {
    return source[index].isAllDay;
  }

  @override
  String getSubject(int index) {
    return source[index].eventName;
  }

  @override
  Color getColor(int index) {
    return source[index].background;
  }
}

/// Custom business object class which contains properties to hold the detailed
/// information about the event data which will be rendered in calendar.
class _Meeting {
  _Meeting({this.eventName, this.from, this.to, this.background, this.isAllDay});

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}
