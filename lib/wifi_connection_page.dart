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
  final CryAnalyzer _api = CryAnalyzer(baseUrl: 'http://192.168.1.46:5000');
  String _status = "Select a mode to start";
  bool _isLoading = false;

  String _selectedCategory = "hunger";
  final List<String> _categories = ["discomfort", "hunger", "pain", "sleepiness"];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _callApi(Map<String, dynamic> payload) async {
    setState(() {
      _isLoading = true;
      _status = 'Processing...';
    });

    try {
      Map<String, dynamic> result;
      String mode = payload['mode'] ?? '0';

      switch (mode) {
        case '1':
          result = await _api.analyzeMode1();
          break;
        case '3':
          result = await _api.analyzeMode3(payload['category'] ?? '');
          break;
        default:
          throw Exception("Invalid mode");
      }

      if (result.containsKey('error')) {
        throw Exception(result['error']);
      }

      final prediction = result['prediction'] ?? 'N/A';
      widget.onPredictionReceived(prediction);
      
      setState(() {
        JsonEncoder encoder = const JsonEncoder.withIndent('  ');
        _status = encoder.convert(result);
      });

    } catch (e) {
      setState(() {
        _status = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wi-Fi Cry Analyzer'),
        backgroundColor: Colors.lightBlue[400],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Mic Test', icon: Icon(Icons.mic)),
            Tab(text: 'WAV File Test', icon: Icon(Icons.audiotrack)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMode1View(),
          _buildMode3View(),
        ],
      ),
    );
  }

  Widget _buildMode1View() {
    return _buildCenteredCard(
      children: [
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
                onPressed: () => _callApi({'mode': '1'}),
                icon: const Icon(Icons.play_arrow, color: Colors.white),
                label: const Text('Start Analysis', style: TextStyle(color: Colors.white, fontSize: 16)),
                style: _buttonStyle(),
              ),
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
              _selectedCategory = newValue!;
            });
          },
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        const SizedBox(height: 16.0),
        _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(onPressed: () => _callApi({'mode': '3', 'category': _selectedCategory}), child: const Text("Analyze Category"), style: _buttonStyle()),
        _buildResultsCard(),
      ],
    );
  }
  
  Widget _buildCenteredCard({required List<Widget> children}) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [ 
            Card(
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
          ]
        ),
      ),
    );
  }

  Widget _buildResultsCard() {
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
              _isLoading 
                ? const Center(child: CircularProgressIndicator()) 
                : Text(_status, style: const TextStyle(fontFamily: 'monospace', fontSize: 12.0)),
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
