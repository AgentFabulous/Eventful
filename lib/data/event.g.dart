// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Event _$EventFromJson(Map<String, dynamic> json) {
  return Event(
      eid: json['eid'] as String,
      name: json['name'] as String,
      password: json['password'] as String,
      ownerId: json['ownerId'] as String)
    ..subEvents =
        (json['subEvents'] as List)?.map((e) => e as String)?.toList();
}

Map<String, dynamic> _$EventToJson(Event instance) => <String, dynamic>{
      'eid': instance.eid,
      'name': instance.name,
      'password': instance.password,
      'ownerId': instance.ownerId,
      'subEvents': instance.subEvents
    };
