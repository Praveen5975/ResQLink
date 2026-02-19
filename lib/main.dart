import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: ResQCommand(),
    ));

class ResQCommand extends StatefulWidget {
  @override
  _ResQCommandState createState() => _ResQCommandState();
}

class _ResQCommandState extends State<ResQCommand> {
  final List<String> victimNodes = ["Victim_Alpha", "Victim_Beta", "Victim_Gamma"];
  String status = "SYSTEM READY - STANDBY";
  bool isLoading = false;
  int _currentIndex = 0; // 0: Home, 1: Map, 2: Security

  final String masterIP = "192.168.4.2";

  // Updated logic to handle Triage Type
  Future<void> sendSosToMaster(String nodeName, String type) async {
    setState(() {
      isLoading = true;
      status = "ENCAPSULATING ${type.toUpperCase()} PACKET...";
    });

    try {
      String victimID = "PHN-${nodeName.split('_').last}";
      String mockGPS = "12.9716,77.5946";
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      // Added &type= parameter for the ESP32 logic
      final url = 'http://$masterIP/sos?'
          'id=$victimID&'
          'relay=$nodeName&'
          'gps=$mockGPS&'
          'type=$type&'
          't=$timestamp';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() => status = type == "safe" 
            ? "✅ CHECK-IN SUCCESS: $victimID is SAFE" 
            : "🚨 SOS TUNNELED: $victimID -> GATEWAY");
      } else {
        setState(() => status = "⚠️ GATEWAY DROPPED PACKET");
      }
    } catch (e) {
      setState(() => status = "❌ MESH RELAY FAILED: CHECK NODE (.2)");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF020617),
      appBar: AppBar(
        title: Text("RESCUEMESH CORE", style: TextStyle(letterSpacing: 2, fontSize: 16)),
        backgroundColor: Color(0xFF0F172A),
        elevation: 4,
      ),
      // --- HAMBURGER MENU ---
      drawer: Drawer(
        child: Container(
          color: Color(0xFF0F172A),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: Color(0xFF1E3A8A)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.hub, size: 40, color: Colors.white),
                    SizedBox(height: 10),
                    Text("ResQLink v2.0", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.warning_amber, color: Colors.redAccent),
                title: Text("Emergency Panel"),
                onTap: () { setState(() => _currentIndex = 0); Navigator.pop(context); },
              ),
              ListTile(
                leading: Icon(Icons.map_outlined, color: Colors.blueAccent),
                title: Text("Mesh Topology Map"),
                onTap: () { setState(() => _currentIndex = 1); Navigator.pop(context); },
              ),
              ListTile(
                leading: Icon(Icons.security, color: Colors.greenAccent),
                title: Text("Security Dashboard"),
                onTap: () { setState(() => _currentIndex = 2); Navigator.pop(context); },
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildEmergencyList(),
          _buildMeshMap(),
          _buildSecurityPage(),
        ],
      ),
    );
  }

  // PAGE 0: YOUR ORIGINAL LIST WITH TRIAGE ADDED
  Widget _buildEmergencyList() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(15),
          color: status.contains("✅") ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.05),
          child: Text(status, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.blueAccent, fontWeight: FontWeight.bold)),
        ),
        if (isLoading) LinearProgressIndicator(color: Colors.red, backgroundColor: Colors.transparent),
        Expanded(
          child: ListView.builder(
            itemCount: victimNodes.length,
            itemBuilder: (context, index) {
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Color(0xFF1E293B),
                child: ExpansionTile(
                  leading: CircleAvatar(backgroundColor: Colors.blueGrey, child: Icon(Icons.person, color: Colors.white)),
                  title: Text(victimNodes[index], style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Relay Path: -> $masterIP"),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _triageBtn("MEDICAL", Colors.red, () => sendSosToMaster(victimNodes[index], "medical")),
                          _triageBtn("TRAPPED", Colors.orange, () => sendSosToMaster(victimNodes[index], "trapped")),
                          _triageBtn("SAFE", Colors.green, () => sendSosToMaster(victimNodes[index], "safe")),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _triageBtn(String label, Color col, VoidCallback press) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: col, padding: EdgeInsets.symmetric(horizontal: 10), textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
      onPressed: isLoading ? null : press,
      child: Text(label),
    );
  }

  // PAGE 1: DUMMY MESH MAP
  Widget _buildMeshMap() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("LIVE TOPOLOGY VIEW", style: TextStyle(letterSpacing: 2, color: Colors.blueGrey)),
        SizedBox(height: 20),
        Container(
          height: 300,
          margin: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blueAccent.withOpacity(0.3))
          ),
          child: Stack(
            children: [
              Center(child: Icon(Icons.router, color: Colors.blue, size: 40)), // Gateway
              Positioned(top: 50, left: 60, child: _dummyNode(Colors.red)),
              Positioned(bottom: 80, right: 40, child: _dummyNode(Colors.green)),
              Positioned(top: 150, right: 70, child: _dummyNode(Colors.orange)),
            ],
          ),
        ),
        Text("Mesh Protocol: Multi-Hop 802.11", style: TextStyle(fontSize: 10, color: Colors.white24)),
      ],
    );
  }

  Widget _dummyNode(Color c) => Icon(Icons.radio_button_checked, color: c, size: 20);

  // PAGE 2: SECURITY DASHBOARD
  Widget _buildSecurityPage() {
    return Padding(
      padding: EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shield, size: 80, color: Colors.blueAccent),
          SizedBox(height: 20),
          Text("124", style: TextStyle(fontSize: 60, fontWeight: FontWeight.w900, color: Colors.blueAccent)),
          Text("FALSE REQUESTS DROPPED", style: TextStyle(letterSpacing: 2, fontSize: 12)),
          SizedBox(height: 40),
          _secInfo("RATE LIMITING", "ACTIVE"),
          _secInfo("ENCRYPTION", "AES-128"),
          _secInfo("MAC FILTER", "ENABLED"),
        ],
      ),
    );
  }

  Widget _secInfo(String t, String s) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(t), Text(s, style: TextStyle(color: Colors.green))]),
  );
}