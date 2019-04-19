// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subevents.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubEvent _$SubEventFromJson(Map<String, dynamic> json) {
  return SubEvent(
      seId: json['seId'] as String,
      name: json['name'] as String,
      venue: json['venue'] as String,
      dateTime: json['dateTime'] == null
          ? null
          : DateTime.parse(json['dateTime'] as String))
    ..organisers =
        (json['organisers'] as List)?.map((e) => e as String)?.toList();
}

Map<String, dynamic> _$SubEventToJson(SubEvent instance) => <String, dynamic>{
      'seId': instance.seId,
      'name': instance.name,
      'venue': instance.venue,
      'dateTime': instance.dateTime?.toIso8601String(),
      'organisers': instance.organisers
    };
