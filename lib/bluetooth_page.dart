
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({super.key});

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  BluetoothDevice? _connectedDevice;
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;

  @override
  void initState() {
    super.initState();

    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      // Now showing all devices, even those without a name.
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
    _connectionStateSubscription?.cancel();
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

    _connectionStateSubscription = device.connectionState.listen((state) {
      if (mounted) {
        if (state == BluetoothConnectionState.connected) {
          setState(() { _connectedDevice = device; });
        } else if (state == BluetoothConnectionState.disconnected) {
          setState(() { _connectedDevice = null; });
        }
      }
    });

    try {
      await device.connect(timeout: const Duration(seconds: 10));
    } catch (e) {
      _showErrorDialog("Connection Error", e.toString());
    }
  }

  void _disconnectFromDevice() {
    _connectionStateSubscription?.cancel();
    _connectedDevice?.disconnect();
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
      onPressed: _connectedDevice != null ? null : _startScan,
      style: ElevatedButton.styleFrom(
        backgroundColor: _isScanning ? Colors.grey : Colors.lightBlue[400],
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildBody() {
    if (_connectedDevice != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bluetooth_connected, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            Text('Connected to:', style: Theme.of(context).textTheme.headlineSmall),
            Text(_connectedDevice!.platformName.isNotEmpty ? _connectedDevice!.platformName : "Unnamed Device", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _disconnectFromDevice,
              child: const Text('Disconnect'),
            )
          ],
        ),
      );
    } else {
      return _buildScanResultsList();
    }
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