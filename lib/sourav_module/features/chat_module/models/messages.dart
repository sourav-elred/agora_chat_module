import 'dart:convert';
import 'dart:developer';

import 'package:fluttercontactpicker/fluttercontactpicker.dart';

// ignore: constant_identifier_names
enum MessageType { TEXT, IMAGE, FILE, CONTACT, AUDIO, LOCATION }

class Message {
  final String id;
  final String text;
  final int sentAt;
  final List<String> seenBy;
  final String sentBy;
  final bool isSender;
  final MessageType type;
  final String? imageUrl;
  final String? audioUrl;
  final String? fileUrl;
  final PhoneContact? contactInfo;
  final LocationData? location;

  Message({
    required this.id,
    required this.text,
    required this.sentAt,
    required this.seenBy,
    required this.sentBy,
    this.isSender = false,
    required this.type,
    this.imageUrl,
    this.audioUrl,
    this.fileUrl,
    this.contactInfo,
    this.location,
  });

  Message copyWith(
          {String? id,
          String? text,
          int? sentAt,
          List<String>? seenBy,
          String? sentBy,
          bool? isSender,
          MessageType? type,
          String? imageUrl,
          String? audioUrl,
          String? fileUrl,
          PhoneContact? contactInfo,
          LocationData? location}) =>
      Message(
        id: id ?? this.id,
        text: text ?? this.text,
        sentAt: sentAt ?? this.sentAt,
        seenBy: seenBy ?? this.seenBy,
        sentBy: sentBy ?? this.sentBy,
        isSender: isSender ?? this.isSender,
        type: type ?? this.type,
        imageUrl: imageUrl ?? this.imageUrl,
        audioUrl: audioUrl ?? this.audioUrl,
        fileUrl: fileUrl ?? this.fileUrl,
        contactInfo: contactInfo ?? this.contactInfo,
        location: location ?? this.location,
      );

  factory Message.fromRawJson(String str) => Message.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json["id"],
        text: json["text"],
        sentAt: json["sentAt"],
        seenBy: json["seenBy"] != null ? List<String>.from(json["seenBy"]) : [],
        sentBy: json["sentBy"],
        type: valueToEnum(json["type"]),
        imageUrl: json["imageUrl"],
        audioUrl: json["audioUrl"],
        fileUrl: json["fileUrl"],
        contactInfo: json["contactInfo"] != null
            ? PhoneContact.fromMap({
                "fullName": json["contactInfo"]["fullName"],
                "phoneNumber": {
                  "phoneNumber": json["contactInfo"]["phoneNumber"],
                  "label": null
                }
              })
            : null,
        location: json["location"] != null
            ? LocationData.fromJson(json["location"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "text": text,
        "sentAt": sentAt,
        "seenBy": seenBy,
        "sentBy": sentBy,
        "type": type.name,
        "imageUrl": imageUrl,
        "audioUrl": audioUrl,
        "fileUrl": fileUrl,
        "contactInfo": {
          "fullName": contactInfo?.fullName,
          "phoneNumber": contactInfo?.phoneNumber?.number,
        },
        "location": location?.toJson(),
      };
}

MessageType valueToEnum(String value) {
  switch (value) {
    case 'TEXT':
      return MessageType.TEXT;
    case 'IMAGE':
      return MessageType.IMAGE;
    case 'FILE':
      return MessageType.FILE;
    case 'CONTACT':
      return MessageType.CONTACT;
    case 'AUDIO':
      return MessageType.AUDIO;
    case 'LOCATION':
      return MessageType.LOCATION;
    default:
      return MessageType.TEXT;
  }
}

class LocationData {
  final double latitude;
  final double longitude;

  LocationData({required this.latitude, required this.longitude});

  factory LocationData.fromJson(Map json) => LocationData(
        latitude: json["latitude"],
        longitude: json["longitude"],
      );

  Map<String, dynamic> toJson() => {
        "latitude": latitude,
        "longitude": longitude,
      };
}
