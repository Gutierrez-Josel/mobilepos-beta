import 'dart:async';
import 'dart:convert';

import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class bluetoothPrint extends StatefulWidget {
  @override
  _bluetoothPrintState createState() => _bluetoothPrintState();
}

class _bluetoothPrintState extends State<bluetoothPrint> {
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;

  bool _connected = false;
  BluetoothDevice? _device;
  String tips = 'no device connect';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => initBluetooth());
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initBluetooth() async {
    bluetoothPrint.startScan(timeout: Duration(seconds: 4));

    bool isConnected=await bluetoothPrint.isConnected??false;

    bluetoothPrint.state.listen((state) {
      print('******************* cur device status: $state');

      switch (state) {
        case BluetoothPrint.CONNECTED:
          setState(() {
            _connected = true;
            tips = 'connect success';
          });
          break;
        case BluetoothPrint.DISCONNECTED:
          setState(() {
            _connected = false;
            tips = 'disconnect success';
          });
          break;
        default:
          break;
      }
    });

    if (!mounted) return;

    if(isConnected) {
      setState(() {
        _connected=true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('BluetoothPrint example app'),
        ),
        body: RefreshIndicator(
          onRefresh: () =>
              bluetoothPrint.startScan(timeout: Duration(seconds: 4)),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      child: Text(tips),
                    ),
                  ],
                ),
                Divider(),
                StreamBuilder<List<BluetoothDevice>>(
                  stream: bluetoothPrint.scanResults,
                  initialData: [],
                  builder: (c, snapshot) => Column(
                    children: snapshot.data!.map((d) => ListTile(
                      title: Text(d.name??''),
                      subtitle: Text(d.address??''),
                      onTap: () async {
                        setState(() {
                          _device = d;
                        });
                      },
                      trailing: _device!=null && _device!.address == d.address?Icon(
                        Icons.check,
                        color: Colors.green,
                      ):null,
                    )).toList(),
                  ),
                ),
                Divider(),
                Container(
                  padding: EdgeInsets.fromLTRB(20, 5, 20, 10),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          OutlinedButton(
                            child: Text('connect'),
                            onPressed:  _connected?null:() async {
                              if(_device!=null && _device!.address !=null){
                                setState(() {
                                  tips = 'connecting...';
                                });
                                await bluetoothPrint.connect(_device!);
                              }else{
                                setState(() {
                                  tips = 'please select device';
                                });
                                print('please select device');
                              }
                            },
                          ),
                          SizedBox(width: 10.0),
                          OutlinedButton(
                            child: Text('disconnect'),
                            onPressed:  _connected?() async {
                              setState(() {
                                tips = 'disconnecting...';
                              });
                              await bluetoothPrint.disconnect();
                            }:null,
                          ),
                        ],
                      ),
                      Divider(),
                      OutlinedButton(
                        child: Text('print receipt(esc)'),
                        onPressed:  _connected?() async {
                          Map<String, dynamic> config = Map();


                          List<LineText> list = [];

                          list.add(LineText(type: LineText.TYPE_TEXT, content: 'PARKING TICKET', weight: 1, align: LineText.ALIGN_CENTER,linefeed: 1, fontZoom: 2));
                          list.add(LineText(type: LineText.TYPE_TEXT, content: 'CHEKWA Corp.', weight: 0, align: LineText.ALIGN_CENTER, linefeed: 1));
                          list.add(LineText(type: LineText.TYPE_TEXT, content: '1234 West Philippine Sea', weight: 0, align: LineText.ALIGN_CENTER,linefeed: 1));
                          list.add(LineText(linefeed: 1));

                          list.add(LineText(type: LineText.TYPE_TEXT, content: '--------OFFICIAL RECEIPT--------', weight: 1, align: LineText.ALIGN_CENTER, linefeed: 1));
                          list.add(LineText(type: LineText.TYPE_TEXT, content: 'TICKET NO: 139477984', weight: 0, align: LineText.ALIGN_CENTER, linefeed: 1));
                          list.add(LineText(type: LineText.TYPE_TEXT, content: 'PLATE NO: HCN879', weight: 0, align: LineText.ALIGN_CENTER, linefeed: 1));
                          list.add(LineText(type: LineText.TYPE_TEXT, content: 'DATE: JUNE 24 2024', weight: 0, align: LineText.ALIGN_CENTER, linefeed: 1));
                          list.add(LineText(type: LineText.TYPE_TEXT, content: '--------------------------------', weight: 1, align: LineText.ALIGN_CENTER,linefeed: 1));
                          list.add(LineText(type: LineText.TYPE_TEXT, content: '', weight: 1, align: LineText.ALIGN_CENTER,linefeed: 1));
                          list.add(LineText(type: LineText.TYPE_TEXT, content: 'TIME IN : ', align: LineText.ALIGN_LEFT, linefeed: 1));
                          list.add(LineText(type: LineText.TYPE_TEXT, content: 'TIME OUT : ', align: LineText.ALIGN_LEFT,linefeed: 1));
                          list.add(LineText(type: LineText.TYPE_TEXT, content: '------------------------------', weight: 1, align: LineText.ALIGN_CENTER,linefeed: 1));
                          list.add(LineText(type: LineText.TYPE_TEXT, content: 'PRICE : ', align: LineText.ALIGN_LEFT,linefeed: 1));
                          list.add(LineText(type: LineText.TYPE_TEXT, content: '', weight: 1, align: LineText.ALIGN_CENTER,linefeed: 1));
                          list.add(LineText(type: LineText.TYPE_TEXT, content: '------------------------------', weight: 1, align: LineText.ALIGN_CENTER,linefeed: 1));
                          list.add(LineText(type: LineText.TYPE_TEXT, content: '', weight: 1, align: LineText.ALIGN_CENTER,linefeed: 1));
                          list.add(LineText(type: LineText.TYPE_TEXT, content: '', weight: 1, align: LineText.ALIGN_CENTER,linefeed: 1));
                          list.add(LineText(type: LineText.TYPE_TEXT, content: 'This ticket is non-refundable', weight: 0, align: LineText.ALIGN_CENTER, linefeed: 1));
                          list.add(LineText(type: LineText.TYPE_TEXT, content: 'It is subject to the rules and', weight: 0, align: LineText.ALIGN_CENTER, linefeed: 1));
                          list.add(LineText(type: LineText.TYPE_TEXT, content: 'regulation of carpark management', weight: 0, align: LineText.ALIGN_CENTER, linefeed: 1));
                          list.add(LineText(type: LineText.TYPE_TEXT, content: '', weight: 1, align: LineText.ALIGN_CENTER,linefeed: 1));
                          list.add(LineText(type: LineText.TYPE_TEXT, content: '', weight: 1, align: LineText.ALIGN_CENTER,linefeed: 1));
                          list.add(LineText(type: LineText.TYPE_QRCODE, content: 'HCN879', size: 60, align: LineText.ALIGN_CENTER, linefeed: 1, fontZoom: 2));
                          list.add(LineText(type: LineText.TYPE_TEXT, content: 'Scan me', weight: 0, align: LineText.ALIGN_CENTER, linefeed: 1));
                          list.add(LineText(linefeed: 1));

                          await bluetoothPrint.printReceipt(config, list);
                        }:null,
                      ),
                      OutlinedButton(
                        child: Text('print label(tsc)'),
                        onPressed:  _connected?() async {
                          Map<String, dynamic> config = Map();
                          config['width'] = 40; // 标签宽度，单位mm
                          config['height'] = 70; // 标签高度，单位mm
                          config['gap'] = 2; // 标签间隔，单位mm

                          // x、y坐标位置，单位dpi，1mm=8dpi
                          List<LineText> list = [];
                          list.add(LineText(type: LineText.TYPE_TEXT, content: 'A Title', weight: 1, align: LineText.ALIGN_CENTER,linefeed: 1));
                          list.add(LineText(type: LineText.TYPE_TEXT, content: 'this is conent left', weight: 0, align: LineText.ALIGN_LEFT,linefeed: 1));
                          list.add(LineText(type: LineText.TYPE_TEXT, content: 'this is conent right', align: LineText.ALIGN_RIGHT,linefeed: 1));
                          list.add(LineText(linefeed: 1));
                          list.add(LineText(type: LineText.TYPE_BARCODE, content: 'A12312112', size:10, align: LineText.ALIGN_CENTER, linefeed: 1));
                          list.add(LineText(linefeed: 1));
                          list.add(LineText(type: LineText.TYPE_QRCODE, content: 'qrcode i', size:10, align: LineText.ALIGN_CENTER, linefeed: 1));
                          list.add(LineText(linefeed: 1));

                          List<LineText> list1 = [];

                          await bluetoothPrint.printLabel(config, list);
                          await bluetoothPrint.printLabel(config, list1);
                        }:null,
                      ),
                      OutlinedButton(
                        child: Text('print selftest'),
                        onPressed:  _connected?() async {
                          await bluetoothPrint.printTest();
                        }:null,
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        floatingActionButton: StreamBuilder<bool>(
          stream: bluetoothPrint.isScanning,
          initialData: false,
          builder: (c, snapshot) {
            if (snapshot.data == true) {
              return FloatingActionButton(
                child: Icon(Icons.stop),
                onPressed: () => bluetoothPrint.stopScan(),
                backgroundColor: Colors.red,
              );
            } else {
              return FloatingActionButton(
                  child: Icon(Icons.search),
                  onPressed: () => bluetoothPrint.startScan(timeout: Duration(seconds: 4)));
            }
          },
        ),
      ),
    );
  }
}