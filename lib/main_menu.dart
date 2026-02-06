
import 'dart:io';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:my_app/about_us_page.dart';
import 'package:my_app/basic_information_page.dart';
import 'package:my_app/bluetooth_service.dart' as app_bluetooth_service;
import 'package:my_app/cry_behavior_testing_page.dart';
import 'package:my_app/cry_history_page.dart';
import 'package:my_app/cry_reason_details_page.dart';
import 'package:my_app/database_helper.dart';
import 'package:my_app/faq_page.dart';
import 'package:my_app/login_page.dart';
import 'package:my_app/terms_and_conditions_page.dart';
import 'package:my_app/bluetooth_page.dart';

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
  bool _isMusicPlaying = true;
  late Future<Map<String, int>> _cryCountsFuture;
  DateTime _selectedDate = DateTime.now();

  // Audio Players
  final AudioPlayer _bgmPlayer = AudioPlayer();

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

    _cryCountsFuture = DatabaseHelper.instance.getCryReasonCountsByDate(_user['id'], DateFormat.yMMMd().format(_selectedDate));
  }

  @override
  void dispose() {
    // Stop and release audio players to free resources
    _bgmPlayer.stop();
    _bgmPlayer.dispose();
    super.dispose();
  }

  void _toggleMusic() {
    if (_isMusicPlaying) {
      _bgmPlayer.pause();
    } else {
      _bgmPlayer.resume();
    }
    setState(() {
      _isMusicPlaying = !_isMusicPlaying;
    });
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

  void _refreshCryCounts() {
    setState(() {
      _cryCountsFuture = DatabaseHelper.instance.getCryReasonCountsByDate(_user['id'], DateFormat.yMMMd().format(_selectedDate));
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _refreshCryCounts();
      });
    }
  }

  void _changeDate(int days) {
    final newDate = _selectedDate.add(Duration(days: days));
    if (newDate.isAfter(DateTime.now()) && !DateUtils.isSameDay(newDate, DateTime.now())) {
      return;
    }
    setState(() {
      _selectedDate = newDate;
      _refreshCryCounts();
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
        actions: [
          IconButton(
            icon: Icon(_isMusicPlaying ? Icons.music_note : Icons.music_off),
            tooltip: 'Toggle Music',
            onPressed: _toggleMusic,
          ),
        ],
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
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CryBehaviorTestingPage(userId: _user['id'])),
                ).then((_) => _refreshCryCounts());
              },
            ),
            const Divider(),
            ExpansionTile(
              leading: const Icon(Icons.account_circle, color: Colors.lightBlue),
              title: const Text('Account'),
              children: <Widget>[
                ListTile(
                  title: const Text('Basic Information'),
                  onTap: () async {
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
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CryHistoryPage(userId: _user['id'], initialDate: _selectedDate)),
                    ).then((_) => _refreshCryCounts());
                  },
                ),
              ],
            ),
            ExpansionTile(
              leading: const Icon(Icons.help, color: Colors.lightBlue),
              title: const Text('FAQ and Resources'),
              children: <Widget>[
                ListTile(
                  title: const Text('Terms and Conditions'),
                  onTap: () {
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
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BluetoothPage()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Log Out', style: TextStyle(color: Colors.red)),
              onTap: () {
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
                _buildControlsSection(),
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
  
  Widget _buildControlsSection() {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow, color: Colors.white),
              label: const Text('Start', style: TextStyle(color: Colors.white)),
              onPressed: app_bluetooth_service.BluetoothService().connectedDevice != null ? () => app_bluetooth_service.BluetoothService().sendCommand('start') : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                disabledBackgroundColor: Colors.grey,
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.stop, color: Colors.white),
              label: const Text('End', style: TextStyle(color: Colors.white)),
              onPressed: app_bluetooth_service.BluetoothService().connectedDevice != null ? () => app_bluetooth_service.BluetoothService().sendCommand('end') : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                disabledBackgroundColor: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarGraphContent() {
    bool isToday = DateUtils.isSameDay(_selectedDate, DateTime.now());

    return FutureBuilder<Map<String, int>>(
      future: _cryCountsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return Column(
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
              const SizedBox(height: 24.0),
              const Center(child: Text('No cry data to display for this date.')),
            ],
          );
        }

        final cryCounts = snapshot.data!;
        final double maxCount = (cryCounts.values.isEmpty ? 0 : cryCounts.values.reduce(max)).toDouble();
        
        double getNiceMaxValue(double maxValue) {
            if (maxValue <= 0) return 10;
            final exponent = (log(maxValue) / ln10).floor();
            final powerOf10 = pow(10, exponent);
            final msd = (maxValue / powerOf10).ceil();
            if (msd > 5) return 10 * powerOf10.toDouble();
            if (msd > 2) return 5 * powerOf10.toDouble();
            return 2 * powerOf10.toDouble();
        }

        final double maxY = getNiceMaxValue(maxCount);
        final double interval = (maxY / 5);

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
                  maxY: maxY,
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
                        interval: interval,
                        getTitlesWidget: (value, meta) {
                          if (value > meta.max) {
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
                    horizontalInterval: interval,
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
                    _buildBarChartGroupData(0, cryCounts['Pain']?.toDouble() ?? 0, Colors.orange, maxY),
                    _buildBarChartGroupData(1, cryCounts['Hunger']?.toDouble() ?? 0, Colors.green, maxY),
                    _buildBarChartGroupData(2, cryCounts['Sleeping']?.toDouble() ?? 0, Colors.blue, maxY),
                    _buildBarChartGroupData(3, cryCounts['Discomfort']?.toDouble() ?? 0, Colors.purple, maxY),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  BarChartGroupData _buildBarChartGroupData(int x, double y, Color color, double maxY) {
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
            toY: maxY,
            color: Colors.grey[200],
          ),
        ),
      ],
    );
  }

  Widget _buildHistorySection() {
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CryHistoryPage(userId: _user['id'], initialDate: _selectedDate)),
          ).then((_) => _refreshCryCounts());
        },
        icon: const Icon(Icons.history, color: Colors.white),
        label: const Text('View Full History', style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
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
    ).then((_) => _refreshCryCounts());
  }
}
