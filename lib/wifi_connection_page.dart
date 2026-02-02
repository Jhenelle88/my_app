
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:permission_handler/permission_handler.dart';

class WifiConnectionPage extends StatefulWidget {
  const WifiConnectionPage({super.key});

  @override
  State<WifiConnectionPage> createState() => _WifiConnectionPageState();
}

class _WifiConnectionPageState extends State<WifiConnectionPage> {
  bool _isScanning = false;
  List<WiFiAccessPoint> _wifiNetworks = [];
  String? _connectedSSID;
  final TextEditingController _passwordController = TextEditingController();
  StreamSubscription<List<WiFiAccessPoint>>? _scanSubscription;

  @override
  void initState() {
    super.initState();
    _checkConnection();
    _startListeningToScans();
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    super.dispose();
  }

  void _startListeningToScans() {
    _scanSubscription = WiFiScan.instance.onScannedResultsAvailable.listen(
      (results) {
        if (mounted) {
          setState(() {
            _wifiNetworks = results;
            _isScanning = false;
          });
        }
      },
      onError: (e) {
        if (mounted) {
          _showErrorDialog("Scan Error", "Error receiving scan results: $e");
          setState(() => _isScanning = false);
        }
      },
    );
  }

  Future<void> _checkConnection() async {
    try {
      final connected = await WiFiForIoTPlugin.getSSID();
      if (mounted) {
        setState(() {
          _connectedSSID = (connected != null && connected.isNotEmpty) ? connected : null;
        });
      }
    } catch (e) {
      // This can fail if Wi-Fi is off, which is okay.
    }
  }

  Future<void> _scanForNetworks() async {
    setState(() => _isScanning = true);
    await WiFiScan.instance.startScan();
    Future.delayed(const Duration(seconds: 12), () {
      if (mounted && _isScanning) {
        setState(() => _isScanning = false);
      }
    });
  }

  bool _isNetworkSecure(WiFiAccessPoint network) {
    return network.capabilities.contains('WPA') || network.capabilities.contains('WEP');
  }

  Future<void> _connectToNetwork(WiFiAccessPoint network) async {
    if (network.ssid.isEmpty) return;

    String? password;
    if (_isNetworkSecure(network)) {
      password = await _showPasswordDialog();
      if (password == null) return; // User cancelled
    }

    try {
      // CORRECTED: The 'security' parameter which caused the build error has been removed.
      await WiFiForIoTPlugin.connect(network.ssid, password: password);
    } catch (e) {
      _showErrorDialog("Connection Failed", "Could not connect to ${network.ssid}.\n\nError: ${e.toString()}");
    } finally {
      await Future.delayed(const Duration(seconds: 5));
      _checkConnection();
    }
  }

  Future<String?> _showPasswordDialog() {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Password'),
          content: TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(hintText: 'Password'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, _passwordController.text);
                _passwordController.clear();
              },
              child: const Text('Connect'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String title, String content) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _disconnectFromNetwork() async {
    await WiFiForIoTPlugin.disconnect();
    _checkConnection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wi-Fi Connection'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _isScanning ? null : _scanForNetworks,
              child: Text(_isScanning ? 'Scanning...' : 'Scan for Networks'),
            ),
          ),
          const Divider(),
          Expanded(
            child: _connectedSSID != null
                ? _buildConnectedView()
                : _buildScanView(),
          ),
        ],
      ),
    );
  }

  Widget _buildScanView() {
    if (_isScanning && _wifiNetworks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_wifiNetworks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            "No Wi-Fi networks found.\n\n- Make sure you are running on a real Android device, not an emulator.\n- Press 'Scan' to search for nearby networks.",
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    final sortedNetworks = _wifiNetworks.toList()..sort((a, b) => b.level.compareTo(a.level));
    return ListView.builder(
      itemCount: sortedNetworks.length,
      itemBuilder: (context, index) {
        final network = sortedNetworks[index];
        if (network.ssid.isEmpty) {
          return const SizedBox.shrink();
        }
        return ListTile(
          title: Text(network.ssid),
          subtitle: Text("Signal: ${network.level} dBm - ${network.capabilities}"),
          trailing: Icon(_isNetworkSecure(network) ? Icons.lock : null),
          onTap: () => _connectToNetwork(network),
        );
      },
    );
  }

  Widget _buildConnectedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Connected to $_connectedSSID', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _disconnectFromNetwork,
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
  }
}
