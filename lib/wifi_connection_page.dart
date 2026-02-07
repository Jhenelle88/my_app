import 'package:flutter/material.dart';
import 'package:my_app/cry_analyzer_api.dart';
import 'dart:convert';

class WifiConnectionPage extends StatefulWidget {
  final Function(String) onPredictionReceived;

  const WifiConnectionPage({super.key, required this.onPredictionReceived});

  @override
  State<WifiConnectionPage> createState() => _WifiConnectionPageState();
}

class _WifiConnectionPageState extends State<WifiConnectionPage> with SingleTickerProviderStateMixin {
  final CryAnalyzer _api = CryAnalyzer(baseUrl: 'http://192.168.100.186:5000');
  String _status = 'Not connected';
  String _results = '';
  bool _isLoading = false;

  late TabController _tabController;
  final _filePathController = TextEditingController();
  final _nFilesController = TextEditingController(text: '1');
  String? _selectedCategory = "hunger";
  final List<String> _categories = ["discomfort", "hunger", "pain", "sleepiness"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _filePathController.dispose();
    _nFilesController.dispose();
    super.dispose();
  }

  Future<void> _callApi(int mode) async {
    setState(() {
      _isLoading = true;
      _status = 'Analyzing...';
      _results = '';
    });

    try {
      Map<String, dynamic> result;
      switch (mode) {
        case 1:
          result = await _api.analyzeMode1();
          break;
        case 2:
          result = await _api.analyzeMode2(_filePathController.text);
          break;
        case 3:
          result = await _api.analyzeMode3(_selectedCategory!);
          break;
        case 4:
          result = await _api.analyzeMode4(int.tryParse(_nFilesController.text) ?? 1);
          break;
        default:
          throw Exception("Invalid mode");
      }

      if (result.containsKey('error')) {
        throw Exception(result['error']);
      }
      
      if (mode != 4) {
        final prediction = result['prediction'] ?? 'N/A';
        widget.onPredictionReceived(prediction);
      }
      
      setState(() {
        _status = 'Success';
        JsonEncoder encoder = const JsonEncoder.withIndent('  ');
        _results = encoder.convert(result);
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _status = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wi-Fi Connection'),
        backgroundColor: Colors.lightBlue[400],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Mic', icon: Icon(Icons.mic)),
            Tab(text: 'File', icon: Icon(Icons.insert_drive_file)),
            Tab(text: 'Category', icon: Icon(Icons.category)),
            Tab(text: 'Batch', icon: Icon(Icons.science)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMode1View(),
          _buildMode2View(),
          _buildMode3View(),
          _buildMode4View(),
        ],
      ),
    );
  }

  Widget _buildMode1View() {
    return _buildCenteredCard(
      children: [
        const Icon(Icons.wifi, size: 64, color: Colors.lightBlue),
        const SizedBox(height: 16.0),
        const Text(
          'Analyze a live recording from the Raspberry Pi microphone.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16.0, color: Colors.blueGrey),
        ),
        const SizedBox(height: 24.0),
        _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton.icon(
                onPressed: () => _callApi(1),
                icon: const Icon(Icons.play_arrow, color: Colors.white),
                label: const Text('Start Analysis', style: TextStyle(color: Colors.white, fontSize: 16)),
                style: _buttonStyle(),
              ),
        _buildResultsCard(),
      ],
    );
  }
  
  Widget _buildMode2View() {
    return _buildCenteredCard(
      children: [
        const Text('Analyze a specific WAV file on the Pi.', textAlign: TextAlign.center),
        const SizedBox(height: 16.0),
        TextField(
          controller: _filePathController,
          decoration: const InputDecoration(labelText: 'Enter file path', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 16.0),
        _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(onPressed: () => _callApi(2), child: const Text("Analyze File"), style: _buttonStyle()),
        _buildResultsCard(),
      ],
    );
  }

  Widget _buildMode3View() {
    return _buildCenteredCard(
      children: [
        const Text('Analyze a random WAV file from a category.', textAlign: TextAlign.center),
        const SizedBox(height: 16.0),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          items: _categories.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedCategory = newValue;
            });
          },
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        const SizedBox(height: 16.0),
        _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(onPressed: () => _callApi(3), child: const Text("Analyze Category"), style: _buttonStyle()),
        _buildResultsCard(),
      ],
    );
  }
  
  Widget _buildMode4View() {
    return _buildCenteredCard(
      children: [
        const Text('Run a batch test with N files from each category.', textAlign: TextAlign.center),
        const SizedBox(height: 16.0),
        TextField(
          controller: _nFilesController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Number of files per category', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 16.0),
        _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(onPressed: () => _callApi(4), child: const Text("Run Batch Test"), style: _buttonStyle()),
        _buildResultsCard(),
      ],
    );
  }

  Widget _buildCenteredCard({required List<Widget> children}) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsCard() {
    if (_results.isEmpty && !_isLoading) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Results', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              const Divider(),
              const SizedBox(height: 8.0),
              Text('Status: $_status', style: const TextStyle(fontSize: 14.0)),
              const SizedBox(height: 8.0),
              if (_results.isNotEmpty)
                Text(_results, style: const TextStyle(fontFamily: 'monospace', fontSize: 12.0)),
            ],
          ),
        ),
      ),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.lightBlue[400],
       foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
    );
  }
}
