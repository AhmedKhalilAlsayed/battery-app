import 'dart:async';
import 'dart:io';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:battery_app/shared/components.dart';
import 'package:battery_info/battery_info_plugin.dart';
import 'package:battery_info/enums/charging_status.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class BatteryScreen extends StatefulWidget {
  // const BatteryScreen({Key? key}) : super(key: key);

  @override
  _BatteryScreenState createState() => _BatteryScreenState();
}

class _BatteryScreenState extends State<BatteryScreen> {
  BatteryInfoPlugin _batteryInfoPlugin = BatteryInfoPlugin();


  @override
  Widget build(BuildContext context) {

    checkMyBattery();


    return Scaffold(
        appBar: AppBar(title: Center(child: Text('Battery'))),
        body: Container(
          width: double.infinity,
          child: Column(
            children: [
              Expanded(
                flex: 4,
                child: Stack(alignment: Alignment.center, children: [
                  Opacity(
                    opacity: .3,
                    child: Icon(
                      batteryIcon,
                      color: batteryIcon == Icons.battery_charging_full
                          ? Colors.green
                          : null,
                      size: 350,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$batteryHealth / $batteryTemp °C\n',
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                      SizedBox(
                        height: 100,
                      ),
                      Text(
                        '$batteryLevel %',
                        style: TextStyle(color: Colors.white, fontSize: 30),
                      )
                    ],
                  )
                ]),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Notification when battery ',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    '${currentValueSlider.round()} %',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Slider(
                  value: currentValueSlider,
                  divisions: 100,
                  min: 1,
                  max: 100,
                  onChanged: (current) {

                    setState(() {
                      currentValueSlider = current;
                    });
                  }),
              Expanded(
                flex: 1,
                child: IconButton(
                    onPressed: () {
                      print('press');

                      setState(() {
                        checkNotifIcon = !checkNotifIcon;
                      });
                    },
                    icon: Icon(
                      checkNotifIcon ? Icons.music_note : Icons.music_off,
                      size: 30,
                    )),
              )
            ],
          ),
        )) ;
  }

  void makeNotification() async {

    await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: 10,
            channelKey: 'basic_channel',
            title: 'Notification',
            body: 'Battery now : $batteryLevel %',
          displayOnBackground: true,
          displayOnForeground: true
        )
    );

  }


  void checkMyBattery() async {

    if (Platform.isAndroid) {

      Timer.periodic(Duration(seconds: 3), (timer) async {
        //get batteryData
        await _batteryInfoPlugin.androidBatteryInfo.then((value) {
          batteryLevel = value!.batteryLevel;
          batteryHealth = value.health;
          batteryTemp = value.temperature;

          //change UI values
          if (value.chargingStatus == ChargingStatus.Charging) {
            batteryIcon = Icons.battery_charging_full;
          } else if (value.chargingStatus == ChargingStatus.Full) {
            batteryIcon = Icons.battery_full;
          } else {
            batteryIcon = Icons.battery_unknown;
          }

          //check old values, to reBuild
          if (batteryHealthOld != batteryHealth ||
              batteryTempOld != batteryTemp ||
              batteryLevelOld != batteryLevel ||
              batteryIconOld != batteryIcon) {
            setState(() {
              print('in setState() ANDROID $batteryLevel %');

              batteryHealthOld = batteryHealth;
              batteryTempOld = batteryTemp;
              batteryLevelOld = batteryLevel;
              batteryIconOld = batteryIcon;
            });
          }
        });

        //will make notification when battery charging, batteryLevel = value of slider
        if(batteryIcon== Icons.battery_charging_full && checkNotifIcon && (currentValueSlider.round() == batteryLevel)){
          makeNotification();
        }


      });
    } else if (Platform.isIOS) {

      Fluttertoast.showToast(msg: 'Temperature not available in IOS');

      Timer.periodic(Duration(seconds: 3), (timer) async {
        await _batteryInfoPlugin.iosBatteryInfo.then((value) {
          batteryLevel = value!.batteryLevel;
          batteryHealth = 'good';
          batteryTemp = -1;

          if (value.chargingStatus == ChargingStatus.Charging) {
            batteryIcon = Icons.battery_charging_full;
          } else if (value.chargingStatus == ChargingStatus.Full)
            batteryIcon = Icons.battery_full;
          else
            batteryIcon = Icons.battery_unknown;
        });

        if (batteryHealthOld != batteryHealth ||
            batteryTempOld != batteryTemp ||
            batteryLevelOld != batteryLevel ||
            batteryIconOld != batteryIcon) {
          setState(() {
            print('in setState() IOS');

            batteryHealthOld = batteryHealth;
            batteryTempOld = batteryTemp;
            batteryLevelOld = batteryLevel;
            batteryIconOld = batteryIcon;
          });
        }

        //will make notification when battery charging, batteryLevel = value of slider
        if(batteryIcon == Icons.battery_charging_full && checkNotifIcon && (currentValueSlider.round() == batteryLevel)){
          makeNotification();
        }

      });
    }
  }
}
