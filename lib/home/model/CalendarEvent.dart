class CalendarEvent {
  CalendarEvent({
    this.kind,
    this.etag,
    this.summary,
    this.updated,
    this.timeZone,
    this.accessRole,
    this.defaultReminders,
    this.nextSyncToken,
    this.nextPageToken,
    this.items,
  });

  String kind;
  String etag;
  String summary;
  DateTime updated;
  String timeZone;
  String nextSyncToken;
  String accessRole;
  List<DefaultReminder> defaultReminders;
  String nextPageToken;
  List<EventItem> items;

  factory CalendarEvent.fromJson(Map<String, dynamic> json) => CalendarEvent(
    kind: json["kind"],
    etag: json["etag"],
    summary: json["summary"],
    updated: DateTime.parse(json["updated"]),
    timeZone: json["timeZone"],
    accessRole: json["accessRole"],
    defaultReminders: List<DefaultReminder>.from(json["defaultReminders"].map((x) => DefaultReminder.fromJson(x))),
    nextSyncToken: json["nextSyncToken"],
    items: List<EventItem>.from(json["items"].map((x) => EventItem.fromJson(x))),
    nextPageToken:  json['nextPageToken']
  );

  Map<String, dynamic> toJson() => {
    "kind": kind,
    "etag": etag,
    "summary": summary,
    "updated": updated.toIso8601String(),
    "timeZone": timeZone,
    "accessRole": accessRole,
    "defaultReminders": List<dynamic>.from(defaultReminders.map((x) => x.toJson())),
    "nextSyncToken": nextSyncToken,
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
    "nextPageToken" : nextPageToken
  };
}

class DefaultReminder {
  DefaultReminder({
    this.method,
    this.minutes,
  });

  String method;
  int minutes;

  factory DefaultReminder.fromJson(Map<String, dynamic> json) => DefaultReminder(
    method: json["method"],
    minutes: json["minutes"],
  );

  Map<String, dynamic> toJson() => {
    "method": method,
    "minutes": minutes,
  };
}

class EventItem {
  EventItem({
    this.kind,
    this.etag,
    this.id,
    this.status,
    this.htmlLink,
    this.created,
    this.updated,
    this.summary,
    this.description,
    this.location,
    this.creator,
    this.organizer,
    this.start,
    this.end,
    this.iCalUid,
    this.sequence,
    this.reminders,
  });

  String kind;
  String etag;
  String id;
  String status;
  String htmlLink;
  DateTime created;
  DateTime updated;
  String summary;
  String description;
  String location;
  Creator creator;
  Creator organizer;
  End start;
  End end;
  String iCalUid;
  int sequence;
  Reminders reminders;

  factory EventItem.fromJson(Map<String, dynamic> json) => EventItem(
    kind: json["kind"],
    etag: json["etag"],
    id: json["id"],
    status: json["status"],
    htmlLink: json["htmlLink"],
    created: DateTime.parse(json["created"]),
    updated: DateTime.parse(json["updated"]),
    summary: json["summary"],
    description: json['description'],
    location: json['location'],
    creator: Creator.fromJson(json["creator"]),
    organizer: Creator.fromJson(json["organizer"]),
    start: End.fromJson(json["start"]),
    end: End.fromJson(json["end"]),
    iCalUid: json["iCalUID"],
    sequence: json["sequence"],
    reminders: Reminders.fromJson(json["reminders"]),
  );

  Map<String, dynamic> toJson() => {
    "kind": kind,
    "etag": etag,
    "id": id,
    "status": status,
    "htmlLink": htmlLink,
    "created": created.toIso8601String(),
    "updated": updated.toIso8601String(),
    "summary": summary,
    "creator": creator.toJson(),
    "organizer": organizer.toJson(),
    "start": start.toJson(),
    "end": end.toJson(),
    "iCalUID": iCalUid,
    "sequence": sequence,
    "reminders": reminders.toJson(),
  };
}

class Creator {
  Creator({
    this.email,
    this.self,
  });

  String email;
  bool self;

  factory Creator.fromJson(Map<String, dynamic> json) => Creator(
    email: json["email"],
    self: json["self"],
  );

  Map<String, dynamic> toJson() => {
    "email": email,
    "self": self,
  };
}

class End {
  End({
    this.dateTime,
    this.timeZone,
  });

  DateTime dateTime;
  String timeZone;

  factory End.fromJson(Map<String, dynamic> json) => End(
    dateTime: DateTime.parse(json["dateTime"]),
    timeZone: json["timeZone"],
  );

  Map<String, dynamic> toJson() => {
    "dateTime": dateTime.toIso8601String(),
    "timeZone": timeZone,
  };
}

class Reminders {
  Reminders({
    this.useDefault,
  });

  bool useDefault;

  factory Reminders.fromJson(Map<String, dynamic> json) => Reminders(
    useDefault: json["useDefault"],
  );

  Map<String, dynamic> toJson() => {
    "useDefault": useDefault,
  };
}