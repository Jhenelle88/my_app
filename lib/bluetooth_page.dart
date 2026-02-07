
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:my_app/bluetooth_service.dart' as app_bluetooth_service;
import 'package:permission_handler/permission_handler.dart';

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({super.key});

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  List<fbp.ScanResult> _scanResults = [];
  bool _isScanning = false;
  late StreamSubscription<List<fbp.ScanResult>> _scanResultsSubscription;

  @override
  void initState() {
    super.initState();
    _scanResultsSubscription = fbp.FlutterBluePlus.scanResults.listen((results) {
      if (mounted) {
        // Filter out devices with empty names
        final filteredResults = results.where((r) => r.device.platformName.isNotEmpty).toList();
        setState(() {
          _scanResults = filteredResults;
        });
      }
    }, onError: (e) {
      _showErrorDialog("Scan Error", e.toString());
    });
  }

  @override
  void dispose() {
    fbp.FlutterBluePlus.stopScan();
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
    if (await fbp.FlutterBluePlus.isSupported == false) {
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

    await fbp.FlutterBluePlus.turnOn();

    setState(() => _isScanning = true);

    try {
      if (mounted) {
        setState(() { _scanResults = []; });
      }
      await fbp.FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
    } catch (e) {
      _showErrorDialog("Scan Error", e.toString());
    }

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _isScanning) {
        fbp.FlutterBluePlus.stopScan();
        setState(() => _isScanning = false);
      }
    });
  }

  Future<void> _connectToDevice(fbp.BluetoothDevice device) async {
    if (_isScanning) {
      await fbp.FlutterBluePlus.stopScan();
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
          title: Text(title, style: TextStyle(color: Colors.lightBlue[800], fontWeight: FontWeight.bold)),
          content: Text(content),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          actions: <Widget>[
            TextButton(
              child: Text("OK", style: TextStyle(color: Colors.lightBlue[800])),
              onPressed: () { Navigator.of(context).pop(); },
            ),
          ],
        );
      },
    );
  }

  Widget _buildScanButton() {
    return FloatingActionButton.extended(
      onPressed: app_bluetooth_service.BluetoothService().connectedDevice != null ? null : _startScan,
      label: Text(_isScanning ? 'Scanning...' : 'Scan for Devices'),
      icon: _isScanning ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)) : const Icon(Icons.bluetooth_searching),
      backgroundColor: _isScanning ? Colors.grey : Colors.lightBlue[400],
      foregroundColor: Colors.white,
    );
  }

  Widget _buildBody() {
    return StreamBuilder<fbp.BluetoothDevice?>(
      stream: app_bluetooth_service.BluetoothService().connectedDeviceStream,
      initialData: app_bluetooth_service.BluetoothService().connectedDevice,
      builder: (context, snapshot) {
        final connectedDevice = snapshot.data;
        if (connectedDevice != null) {
          return _buildConnectedDeviceView(connectedDevice);
        } else {
          return _buildScanView();
        }
      },
    );
  }

  Widget _buildConnectedDeviceView(fbp.BluetoothDevice device) {
    return Center(
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bluetooth_connected, size: 80, color: Colors.blue),
              const SizedBox(height: 20),
              Text('Connected to:', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.blueGrey)),
              const SizedBox(height: 8),
              Text(device.platformName.isNotEmpty ? device.platformName : "Unnamed Device", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.close, color: Colors.white),
                label: const Text('Disconnect', style: TextStyle(color: Colors.white)),
                onPressed: () => app_bluetooth_service.BluetoothService().disconnect(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildScanButton(),
        ),
        const Divider(),
        Expanded(child: _buildScanResultsList()),
      ],
    );
  }

  Widget _buildScanResultsList() {
    if (_isScanning && _scanResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Searching for devices...'),
          ],
        ),
      );
    }

    if (!_isScanning && _scanResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bluetooth_disabled, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text('No devices found.', style: TextStyle(fontSize: 16, color: Colors.grey)),
            Text('Press "Scan" to start searching.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _scanResults.length,
      itemBuilder: (context, index) {
        final result = _scanResults[index];
        return Card(
          elevation: 2.0,
          margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: ListTile(
            leading: const Icon(Icons.bluetooth, color: Colors.blue),
            title: Text(result.device.platformName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(result.device.remoteId.toString()),
            trailing: ElevatedButton(
              child: const Text('Connect'),
              onPressed: () => _connectToDevice(result.device),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue[400],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
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
        title: const Text('Bluetooth Connection', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 4.0,
        backgroundColor: Colors.lightBlue[400],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _buildBody(),
    );
  }
}
