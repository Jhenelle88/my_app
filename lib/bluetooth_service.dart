import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothService {
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? _txCharacteristic;

  final StreamController<BluetoothDevice?> _connectedDeviceController = StreamController.broadcast();
  Stream<BluetoothDevice?> get connectedDeviceStream => _connectedDeviceController.stream;

  static final Guid _uartServiceGuid = Guid('6E400001-B5A3-F393-E0A9-E50E24DCCA9E');
  static final Guid _txCharacteristicGuid = Guid('6E400002-B5A3-F393-E0A9-E50E24DCCA9E');

  Future<void> connect(BluetoothDevice device) async {
    await device.connect(autoConnect: false);
    connectedDevice = device;
    _connectedDeviceController.add(device);

    try {
      var services = await device.discoverServices();
      for (var service in services) {
        if (service.uuid == _uartServiceGuid) {
          for (var char in service.characteristics) {
            if (char.uuid == _txCharacteristicGuid) {
              _txCharacteristic = char;
              break;
            }
          }
        }
      }
    } catch (e) {
      // Handle discovery error
    }

    device.connectionState.listen((state) {
      if (state == BluetoothConnectionState.disconnected) {
        disconnect();
      }
    });
  }

  void disconnect() {
    connectedDevice?.disconnect();
    connectedDevice = null;
    _txCharacteristic = null;
    _connectedDeviceController.add(null);
  }

  Future<void> sendCommand(String command) async {
    if (_txCharacteristic != null) {
      await _txCharacteristic!.write(command.codeUnits, withoutResponse: true);
    }
  }
}
