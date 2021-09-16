import 'package:flutter/material.dart';

var currentValueSlider = 95.0;

IconData? batteryIcon = Icons.battery_unknown;
String? batteryHealth = 'good';
int? batteryTemp = -1;
int? batteryLevel = -1;

IconData? batteryIconOld = Icons.battery_unknown;
String? batteryHealthOld = 'good';
int? batteryTempOld = -1;
int? batteryLevelOld = -1;

bool checkNotifIcon = true;