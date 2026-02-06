
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:my_app/bluetooth_service.dart' as app_bluetooth_service;
import 'package:permission_handler/permission_handler.dart';

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({super.key});

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;

  @override
  void initState() {
    super.initState();
    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      if (mounted) {
        setState(() {
          _scanResults = results;
        });
      }
    }, onError: (e) {
      _showErrorDialog("Scan Error", e.toString());
    });
  }

  @override
  void dispose() {
    FlutterBluePlus.stopScan();
    _scanResultsSubscription.cancel();
    super.dispose();
  }

  Future<bool> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    bool allGranted = statuses.values.every((status) => status.isGranted);

    if (!allGranted) {
      _showErrorDialog(
          "Permissions Required",
          "Bluetooth Scan, Connect, and Location permissions are all required. Please grant them in your phone's settings for this app.");
    }
    return allGranted;
  }

  void _startScan() async {
    if (await FlutterBluePlus.isSupported == false) {
      _showErrorDialog("Unsupported", "Bluetooth is not supported on this device.");
      return;
    }

    bool permissionsGranted = await _requestPermissions();
    if (!permissionsGranted) return;

    var locationStatus = await Permission.location.serviceStatus;
    if (locationStatus.isDisabled) {
      _showErrorDialog(
          "Location Services Disabled",
          "Please turn on location services in your phone's settings to find nearby devices."
      );
      return;
    }

    await FlutterBluePlus.turnOn();

    setState(() => _isScanning = true);

    try {
      if (mounted) {
        setState(() { _scanResults = []; });
      }
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
    } catch (e) {
      _showErrorDialog("Scan Error", e.toString());
    }

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _isScanning) {
        FlutterBluePlus.stopScan();
        setState(() => _isScanning = false);
      }
    });
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    if (_isScanning) {
      await FlutterBluePlus.stopScan();
      setState(() => _isScanning = false);
    }

    try {
      await app_bluetooth_service.BluetoothService().connect(device);
    } catch (e) {
      _showErrorDialog("Connection Error", e.toString());
    }
  }

  void _showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () { Navigator.of(context).pop(); },
            ),
          ],
        );
      },
    );
  }

  Widget _buildScanButton() {
    return ElevatedButton.icon(
      icon: Icon(_isScanning ? Icons.stop : Icons.bluetooth_searching),
      label: Text(_isScanning ? 'Scanning...' : 'Scan for Devices'),
      onPressed: app_bluetooth_service.BluetoothService().connectedDevice != null ? null : _startScan,
      style: ElevatedButton.styleFrom(
        backgroundColor: _isScanning ? Colors.grey : Colors.lightBlue[400],
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildBody() {
    return StreamBuilder<BluetoothDevice?>(
      stream: app_bluetooth_service.BluetoothService().connectedDeviceStream,
      initialData: app_bluetooth_service.BluetoothService().connectedDevice,
      builder: (context, snapshot) {
        final connectedDevice = snapshot.data;
        if (connectedDevice != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.bluetooth_connected, size: 80, color: Colors.blue),
                const SizedBox(height: 20),
                Text('Connected to:', style: Theme.of(context).textTheme.headlineSmall),
                Text(connectedDevice.platformName.isNotEmpty ? connectedDevice.platformName : "Unnamed Device", style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => app_bluetooth_service.BluetoothService().disconnect(),
                  child: const Text('Disconnect'),
                )
              ],
            ),
          );
        } else {
          return _buildScanResultsList();
        }
      },
    );
  }

  Widget _buildScanResultsList() {
    return _scanResults.isEmpty
        ? Center(
      child: Text(
        _isScanning ? 'Searching for devices...' : 'No devices found. Press "Scan" to start.',
        textAlign: TextAlign.center,
      ),
    )
        : ListView.builder(
      itemCount: _scanResults.length,
      itemBuilder: (context, index) {
        final result = _scanResults[index];
        return Card(
          child: ListTile(
            title: Text(result.device.platformName.isNotEmpty ? result.device.platformName : "Unnamed Device"),
            subtitle: Text(result.device.remoteId.toString()),
            trailing: ElevatedButton(
              child: const Text('Connect'),
              onPressed: () => _connectToDevice(result.device),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Connection'),
        elevation: 4.0,
        backgroundColor: Colors.lightBlue[400],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            _buildScanButton(),
            const SizedBox(height: 12),
            const Divider(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }
}
