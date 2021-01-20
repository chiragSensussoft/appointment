class CalendarList {
  CalendarList({
    this.kind,
    this.etag,
    this.nextSyncToken,
    this.items,
  });

  String kind;
  String etag;
  String nextSyncToken;
  List<Item> items;

  factory CalendarList.fromJson(Map<String, dynamic> json) => CalendarList(
    kind: json["kind"],
    etag: json["etag"],
    nextSyncToken: json["nextSyncToken"],
    items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "kind": kind,
    "etag": etag,
    "nextSyncToken": nextSyncToken,
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
  };
}

class Item {
  Item({
    this.kind,
    this.etag,
    this.id,
    this.summary,
    this.timeZone,
    this.colorId,
    this.backgroundColor,
    this.foregroundColor,
    this.selected,
    this.accessRole,
    this.defaultReminders,
    this.notificationSettings,
    this.primary,
    this.conferenceProperties,
    this.description,
  });

  String kind;
  String etag;
  String id;
  String summary;
  String timeZone;
  String colorId;
  String backgroundColor;
  String foregroundColor;
  bool selected;
  String accessRole;
  List<DefaultReminder> defaultReminders;
  NotificationSettings notificationSettings;
  bool primary;
  ConferenceProperties conferenceProperties;
  String description;

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    kind: json["kind"],
    etag: json["etag"],
    id: json["id"],
    summary: json["summary"],
    timeZone: json["timeZone"],
    colorId: json["colorId"],
    backgroundColor: json["backgroundColor"],
    foregroundColor: json["foregroundColor"],
    selected: json["selected"] == null ? null : json["selected"],
    accessRole: json["accessRole"],
    defaultReminders: List<DefaultReminder>.from(json["defaultReminders"].map((x) => DefaultReminder.fromJson(x))),
    notificationSettings: json["notificationSettings"] == null ? null : NotificationSettings.fromJson(json["notificationSettings"]),
    primary: json["primary"] == null ? null : json["primary"],
    conferenceProperties: ConferenceProperties.fromJson(json["conferenceProperties"]),
    description: json["description"] == null ? null : json["description"],
  );

  Map<String, dynamic> toJson() => {
    "kind": kind,
    "etag": etag,
    "id": id,
    "summary": summary,
    "timeZone": timeZone,
    "colorId": colorId,
    "backgroundColor": backgroundColor,
    "foregroundColor": foregroundColor,
    "selected": selected == null ? null : selected,
    "accessRole": accessRole,
    "defaultReminders": List<dynamic>.from(defaultReminders.map((x) => x.toJson())),
    "notificationSettings": notificationSettings == null ? null : notificationSettings.toJson(),
    "primary": primary == null ? null : primary,
    "conferenceProperties": conferenceProperties.toJson(),
    "description": description == null ? null : description,
  };
}

class ConferenceProperties {
  ConferenceProperties({
    this.allowedConferenceSolutionTypes,
  });

  List<String> allowedConferenceSolutionTypes;

  factory ConferenceProperties.fromJson(Map<String, dynamic> json) => ConferenceProperties(
    allowedConferenceSolutionTypes: List<String>.from(json["allowedConferenceSolutionTypes"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "allowedConferenceSolutionTypes": List<dynamic>.from(allowedConferenceSolutionTypes.map((x) => x)),
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

class NotificationSettings {
  NotificationSettings({
    this.notifications,
  });

  List<Notification> notifications;

  factory NotificationSettings.fromJson(Map<String, dynamic> json) => NotificationSettings(
    notifications: List<Notification>.from(json["notifications"].map((x) => Notification.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "notifications": List<dynamic>.from(notifications.map((x) => x.toJson())),
  };
}

class Notification {
  Notification({
    this.type,
    this.method,
  });

  String type;
  String method;

  factory Notification.fromJson(Map<String, dynamic> json) => Notification(
    type: json["type"],
    method: json["method"],
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "method": method,
  };
}
