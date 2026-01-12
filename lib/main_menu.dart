
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:my_app/about_us_page.dart';
import 'package:my_app/basic_information_page.dart';
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

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    if (_user['imagePath'] != null) {
      _image = File(_user['imagePath']);
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4.0,
        backgroundColor: Colors.lightBlue[400],
        title: Row(
          children: [
            Image.asset(
              'assets/LOGO.png',
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
              accountName: Text(_user['fullName'] ?? 'User Name', style: const TextStyle(fontWeight: FontWeight.bold)),
              accountEmail: Text(_user['email']),
              currentAccountPicture: CircleAvatar(
                backgroundImage: _image != null ? FileImage(_image!) : null,
                backgroundColor: Colors.white,
                child: _image == null
                    ? Text(
                        _user['fullName'] != null ? _user['fullName'][0].toUpperCase() : 'U',
                        style: TextStyle(fontSize: 40.0, color: Colors.lightBlue[800]),
                      )
                    : null,
              ),
              decoration: BoxDecoration(
                color: Colors.lightBlue[400],
              ),
            ),
            ExpansionTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Account'),
              children: <Widget>[
                ListTile(
                  title: const Text('Basic Information'),
                  onTap: () async {
                    Navigator.pop(context); // Close the drawer
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
                  },
                ),
              ],
            ),
            ExpansionTile(
              leading: const Icon(Icons.help),
              title: const Text('Faq and Resources'),
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
                ListTile(
                  title: const Text('Contact Us'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            ListTile(
              leading: const Icon(Icons.bluetooth),
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
              leading: const Icon(Icons.logout),
              title: const Text('Log Out'),
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
        color: Colors.lightBlue[100],
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 8.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildNotificationContent(),
                    const SizedBox(height: 24.0),
                    _buildBarGraphContent(),
                    const SizedBox(height: 24.0),
                    _buildHistoryListContent(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationContent() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red[100],
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: ExpansionTile(
        leading: Icon(Icons.notifications_active, color: Colors.red[800], size: 40.0),
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
          // TODO: Replace with actual segment data
          ListTile(title: Text('Segment: ')),
          ListTile(title: Text('Segment: ')),
          ListTile(title: Text('Segment: ')),
          ListTile(title: Text('Segment: ')),
        ],
      ),
    );
  }

  Widget _buildBarGraphContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Text(
            'Cry Analysis',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[800],
            ),
          ),
        ),
        const SizedBox(height: 24.0),
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
                    reservedSize: 32,
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
                _buildBarChartGroupData(0, 8),
                _buildBarChartGroupData(1, 15),
                _buildBarChartGroupData(2, 10),
                _buildBarChartGroupData(3, 5),
              ],
            ),
          ),
        ),
      ],
    );
  }

  BarChartGroupData _buildBarChartGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 22,
          color: Colors.lightBlue[400],
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

  Widget _buildHistoryListContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cry History',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.lightBlue[800],
          ),
        ),
        const SizedBox(height: 8.0),
        _buildHistoryItem('Hunger', '10:30 AM'),
        const Divider(),
        _buildHistoryItem('Pain', '9:15 AM'),
        const Divider(),
        _buildHistoryItem('Sleep', 'Yesterday'),
      ],
    );
  }

  Widget _buildHistoryItem(String reason, String time) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.history, color: Colors.lightBlue[800]),
      title: Text(reason),
      subtitle: Text(time),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {},
    );
  }
}
