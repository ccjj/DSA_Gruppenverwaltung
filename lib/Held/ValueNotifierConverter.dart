import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

// Custom converter for ValueNotifier
class ValueNotifierConverter<T> implements JsonConverter<ValueNotifier<T>, T> {
  const ValueNotifierConverter();

  @override
  ValueNotifier<T> fromJson(T json) {
    return ValueNotifier<T>(json);
  }

  @override
  T toJson(ValueNotifier<T> object) {
    return object.value;
  }
}

/*
// Example usage in a model
@JsonSerializable()
class MyModel {
  @ValueNotifierConverter()
  final ValueNotifier<int> myValueNotifier;

  MyModel({required this.myValueNotifier});

  factory MyModel.fromJson(Map<String, dynamic> json) => _$MyModelFromJson(json);
  Map<String, dynamic> toJson() => _$MyModelToJson(this);
}


 */