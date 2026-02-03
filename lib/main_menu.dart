
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:my_app/about_us_page.dart';
import 'package:my_app/basic_information_page.dart';
import 'package:my_app/cry_behavior_testing_page.dart';
import 'package:my_app/cry_history_page.dart';
import 'package:my_app/cry_reason_details_page.dart';
import 'package:my_app/faq_page.dart';
import 'package:my_app/login_page.dart';
import 'package:my_app/terms_and_conditions_page.dart';
import 'package:my_app/bluetooth_page.dart';
import 'package:my_app/wifi_connection_page.dart';

// Represents the data for a single day's cry analysis
class CryData {
  final double pain;
  final double hunger;
  final double sleep;
  final double discomfort;

  CryData({this.pain = 0, this.hunger = 0, this.sleep = 0, this.discomfort = 0});
}

class MainMenu extends StatefulWidget {
  final Map<String, dynamic> user;

  const MainMenu({super.key, required this.user});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  late Map<String, dynamic> _user;
  File? _image;
  bool _isNotificationExpanded = false;
  DateTime _selectedDate = DateTime.now();

  // Audio Players
  final AudioPlayer _bgmPlayer = AudioPlayer();

  // --- Simulated Database ---
  final Map<String, CryData> _cryDataDatabase = {
    DateFormat.yMMMd().format(DateTime.now()): CryData(pain: 8, hunger: 15, sleep: 10, discomfort: 5),
    DateFormat.yMMMd().format(DateTime.now().subtract(const Duration(days: 1))): CryData(pain: 4, hunger: 18, sleep: 7, discomfort: 9),
    DateFormat.yMMMd().format(DateTime.now().subtract(const Duration(days: 2))): CryData(pain: 12, hunger: 9, sleep: 14, discomfort: 3),
    DateFormat.yMMMd().format(DateTime.now().subtract(const Duration(days: 5))): CryData(pain: 7, hunger: 7, sleep: 7, discomfort: 7),
  };
  // --- End Simulated Database ---

  CryData _getCurrentCryData() {
    final formattedDate = DateFormat.yMMMd().format(_selectedDate);
    return _cryDataDatabase[formattedDate] ?? CryData();
  }

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    if (_user['imagePath'] != null) {
      _image = File(_user['imagePath']);
    }
    // Start background music on loop
    _bgmPlayer.play(AssetSource('audio/graduation_march.mp3'));
    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
  }

  @override
  void dispose() {
    // Stop and release audio players to free resources
    _bgmPlayer.stop();
    _bgmPlayer.dispose();
    super.dispose();
  }

  void _playClickSound() {
    // Create a new player for each click to allow for rapid, overlapping sounds.
    final player = AudioPlayer();
    player.play(AssetSource('audio/button_click.mp3'));
    // The player will release itself after it finishes playing.
  }

  void _updateUser(Map<String, dynamic> newUser) {
    setState(() {
      _user = newUser;
      if (_user['imagePath'] != null) {
        _image = File(_user['imagePath']);
      } else {
        _image = null;
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    _playClickSound();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _changeDate(int days) {
    _playClickSound();
    final newDate = _selectedDate.add(Duration(days: days));
    if (newDate.isAfter(DateTime.now()) && !DateUtils.isSameDay(newDate, DateTime.now())) {
      return;
    }
    setState(() {
      _selectedDate = newDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4.0,
        backgroundColor: Colors.lightBlue[400],
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            Image.asset(
              'assets/APP.png',
              height: 40,
            ),
            const SizedBox(width: 8),
            const Text(
              'CRYCOM',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(_user['fullName'] ?? 'User Name', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              accountEmail: Text(_user['email'] ?? '', style: const TextStyle(fontSize: 14)),
              currentAccountPicture: CircleAvatar(
                backgroundImage: _image != null ? FileImage(_image!) : null,
                backgroundColor: Colors.white,
                child: _image == null
                    ? Text(
                        _user['fullName'] != null && _user['fullName'].isNotEmpty
                            ? _user['fullName'][0].toUpperCase()
                            : 'U',
                        style: TextStyle(fontSize: 40.0, color: Colors.lightBlue[800]),
                      )
                    : null,
              ),
              decoration: BoxDecoration(
                color: Colors.lightBlue[400],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.science_outlined, color: Colors.lightBlue),
              title: const Text('Cry Behavior (Testing)'),
              onTap: () {
                _playClickSound();
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CryBehaviorTestingPage(userId: _user['id'])),
                );
              },
            ),
            const Divider(),
            ExpansionTile(
              leading: const Icon(Icons.account_circle, color: Colors.lightBlue),
              title: const Text('Account'),
              onExpansionChanged: (expanded) => _playClickSound(),
              children: <Widget>[
                ListTile(
                  title: const Text('Basic Information'),
                  onTap: () async {
                    _playClickSound();
                    Navigator.pop(context);
                    final updatedUser = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BasicInformationPage(user: _user),
                      ),
                    );
                    if (updatedUser != null) {
                      _updateUser(updatedUser);
                    }
                  },
                ),
                ListTile(
                  title: const Text('Cry History'),
                  onTap: () {
                    _playClickSound();
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CryHistoryPage(userId: _user['id'])),
                    );
                  },
                ),
              ],
            ),
            ExpansionTile(
              leading: const Icon(Icons.help, color: Colors.lightBlue),
              title: const Text('FAQ and Resources'),
              onExpansionChanged: (expanded) => _playClickSound(),
              children: <Widget>[
                ListTile(
                  title: const Text('Terms and Conditions'),
                  onTap: () {
                    _playClickSound();
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TermsAndConditionsPage()),
                    );
                  },
                ),
                ListTile(
                  title: const Text('About Us'),
                  onTap: () {
                    _playClickSound();
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AboutUsPage()),
                    );
                  },
                ),
                ListTile(
                  title: const Text('FAQs'),
                  onTap: () {
                    _playClickSound();
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FaqPage()),
                    );
                  },
                ),
              ],
            ),
            ListTile(
              leading: const Icon(Icons.bluetooth, color: Colors.lightBlue),
              title: const Text('Bluetooth Connection'),
              onTap: () {
                _playClickSound();
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BluetoothPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.wifi, color: Colors.lightBlue),
              title: const Text('Wi-Fi Connection'),
              onTap: () {
                _playClickSound();
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WifiConnectionPage()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Log Out', style: TextStyle(color: Colors.red)),
              onTap: () {
                _playClickSound();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.lightBlue[50],
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildNotificationContent(),
                const SizedBox(height: 24.0),
                Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildBarGraphContent(),
                        const SizedBox(height: 16.0),
                        const Divider(),
                        const SizedBox(height: 16.0),
                        _buildHistorySection(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildReasonForCrySection(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationContent() {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: Colors.red[100],
      child: ExpansionTile(
        leading: Icon(Icons.notifications_active, color: Colors.red[800], size: 32.0),
        title: Text(
          'Baby is Crying!',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.red[800],
          ),
        ),
        subtitle: Text(
          'Reason: Hunger',
          style: TextStyle(fontSize: 16.0, color: Colors.red[700]),
        ),
        trailing: Icon(
          _isNotificationExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
          color: Colors.red[800],
        ),
        onExpansionChanged: (bool expanded) {
          _playClickSound();
          setState(() {
            _isNotificationExpanded = expanded;
          });
        },
        children: const <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                ListTile(title: Text('Segment: ')),
                ListTile(title: Text('Segment: ')),
                ListTile(title: Text('Segment: ')),
                ListTile(title: Text('Segment: ')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarGraphContent() {
    bool isToday = DateUtils.isSameDay(_selectedDate, DateTime.now());
    final currentData = _getCurrentCryData();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Cry Analysis',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey[800],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_left),
              onPressed: () => _changeDate(-1),
            ),
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isToday ? 'Today' : DateFormat.yMMMd().format(_selectedDate),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[700],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.calendar_today, color: Colors.lightBlue, size: 20),
                  ],
                ),
              ),
            ),
            Opacity(
              opacity: isToday ? 0.0 : 1.0,
              child: IconButton(
                icon: const Icon(Icons.arrow_right),
                onPressed: isToday ? null : () => _changeDate(1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        AspectRatio(
          aspectRatio: 1.6,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 20,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (group) => Colors.blueGrey[800]!,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${rod.toY.round()}',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      final style = TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      );
                      String text;
                      switch (value.toInt()) {
                        case 0:
                          text = 'Pain';
                          break;
                        case 1:
                          text = 'Hunger';
                          break;
                        case 2:
                          text = 'Sleep';
                          break;
                        case 3:
                          text = 'Discomfort';
                          break;
                        default:
                          text = '';
                          break;
                      }
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        space: 8.0,
                        child: Text(text, style: style),
                      );
                    },
                    reservedSize: 38,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 5,
                    getTitlesWidget: (value, meta) {
                      if (value == 0 || value == meta.max) {
                        return Container();
                      }
                      return Text(
                        value.toInt().toString(),
                        style: TextStyle(color: Colors.grey[700], fontSize: 10),
                        textAlign: TextAlign.left,
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 5,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey[300]!,
                    strokeWidth: 1,
                  );
                },
              ),
              borderData: FlBorderData(
                show: false,
              ),
              barGroups: [
                _buildBarChartGroupData(0, currentData.pain, Colors.orange),
                _buildBarChartGroupData(1, currentData.hunger, Colors.green),
                _buildBarChartGroupData(2, currentData.sleep, Colors.blue),
                _buildBarChartGroupData(3, currentData.discomfort, Colors.purple),
              ],
            ),
          ),
        ),
      ],
    );
  }

  BarChartGroupData _buildBarChartGroupData(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 22,
          color: color.withOpacity(0.8),
          borderRadius: const BorderRadius.all(Radius.circular(6)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 20,
            color: Colors.grey[200],
          ),
        ),
      ],
    );
  }

  Widget _buildHistorySection() {
    bool isToday = DateUtils.isSameDay(_selectedDate, DateTime.now());

    if (isToday) {
      return Center(
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlue[400],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          ),
          onPressed: () {
            _playClickSound();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CryHistoryPage(userId: _user['id'])),
            );
          },
          icon: const Icon(Icons.history, color: Colors.white),
          label: const Text('View Full Cry History', style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      );
    } else {
      final pastData = _getCurrentCryData();
      final hasData = pastData.pain > 0 || pastData.hunger > 0 || pastData.sleep > 0 || pastData.discomfort > 0;

      if (!hasData) {
        return Center(
          child: Text(
            'No cry data recorded for ${DateFormat.yMMMd().format(_selectedDate)}.',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Summary for ${DateFormat.yMMMd().format(_selectedDate)}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey[700]),
          ),
          const SizedBox(height: 12),
          _buildSummaryRow('Hunger', pastData.hunger, Colors.green),
          const SizedBox(height: 8),
          _buildSummaryRow('Pain', pastData.pain, Colors.orange),
          const SizedBox(height: 8),
          _buildSummaryRow('Sleep', pastData.sleep, Colors.blue),
          const SizedBox(height: 8),
          _buildSummaryRow('Discomfort', pastData.discomfort, Colors.purple),
        ],
      );
    }
  }

  Widget _buildSummaryRow(String reason, double value, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$reason:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey[600]),
        ),
        const Spacer(),
        Text(
          '${value.round()} events',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
        ),
      ],
    );
  }

  Widget _buildReasonForCrySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Reason for Cry',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey[800],
          ),
        ),
        const SizedBox(height: 16.0),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            _buildReasonButton('Sleeping', Icons.nightlight_round, Colors.blue),
            _buildReasonButton('Hunger', Icons.restaurant_menu, Colors.green),
            _buildReasonButton('Pain', Icons.healing, Colors.orange),
            _buildReasonButton('Discomfort', Icons.thermostat, Colors.purple),
          ],
        ),
      ],
    );
  }

  Widget _buildReasonButton(String reason, IconData icon, Color color) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: () => _showReasonDetails(reason),
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8.0),
              Text(
                reason,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.blueGrey[800],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReasonDetails(String reason) {
    _playClickSound();
    Map<String, String> details;
    switch (reason) {
      case 'Sleeping':
        details = {
          'Cry Pattern': 'Soft, rhythmic, low intensity',
          'Detected By':
              'Low audio frequency\nShort cry duration\nMinimal body movement (motion sensor)',
          'Indicator': 'Baby is drowsy or transitioning to sleep',
          'What to Do':
              'Dim lights and reduce noise\nGently rock or swaddle the baby\nPlace the baby in a comfortable sleeping position',
        };
        break;
      case 'Hunger':
        details = {
          'Cry Pattern': 'Repetitive, rising pitch, rhythmic',
          'Detected By':
              'Increasing cry intensity over time\nRegular intervals between cries\nTime elapsed since last feeding (timer/log data)',
          'Indicator': 'Feeding likely needed',
          'What to Do':
              'Feed the baby immediately\nEnsure proper feeding position\nBurp the baby after feeding',
        };
        break;
      case 'Discomfort':
        details = {
          'Cry Pattern': 'Irregular, fussy, moderate pitch',
          'Detected By':
              'Sudden cry onset\nTemperature sensor (too hot/cold)\nMoisture sensor (wet diaper)\nIncreased body movement',
          'Indicator': 'Environmental or physical discomfort',
          'What to Do':
              'Check and change diaper if needed\nAdjust clothing or room temperature\nReposition the baby for comfort',
        };
        break;
      case 'Pain':
        details = {
          'Cry Pattern': 'Loud, sharp, high-pitched, continuous',
          'Detected By':
              'High audio frequency and amplitude\nProlonged crying with no pauses\nStrong, erratic movements (motion sensor)',
          'Indicator': 'Possible pain, illness, or distress',
          'What to Do':
              'Check for signs of pain (teething, gas, fever)\nComfort and soothe the baby\nSeek medical attention if crying continues',
        };
        break;
      default:
        details = {};
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CryReasonDetailsPage(
          reason: reason,
          details: details,
          userId: _user['id'],
        ),
      ),
    );
  }
}
