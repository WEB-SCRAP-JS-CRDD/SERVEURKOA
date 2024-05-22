import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'compteur2status.dart';
import 'champions_page.dart';
import 'graph.dart';
import 'rankdata.dart';
import 'buffnerf.dart' as buff;
import 'dashboard_widget.dart' as dashboard;
import 'gauge.dart' as gauge;
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late VideoPlayerController _controller;
  Map<String, dynamic> data = {};
  bool _isVideoFinished = false;
  List<Champion> champions = [];
  List<Champion> top3Champions = [];
  List<Champion> bottom3Champions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/wall.mp4')
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.setLooping(false);
      });
    _controller.addListener(() {
      if (!_controller.value.isPlaying &&
          _controller.value.isInitialized &&
          (_controller.value.duration == _controller.value.position)) {
        setState(() {
          _isVideoFinished = true;
        });
      }
    });
    loadData();
    loadChampions();
    loadTopBottomChampions();
  }

  Future<void> loadData() async {
    final jsonString = await rootBundle.loadString('assets/data_import.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    setState(() {
      data = jsonMap;
    });
  }

  Future<void> loadChampions() async {
    setState(() => isLoading = true);
    try {
      final response =
          await http.get(Uri.parse('http://localhost:3000/tierlist'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        setState(() {
          champions = data
              .map((jsonChampion) =>
                  Champion.fromJson(jsonChampion as Map<String, dynamic>))
              .where((champion) => champion.role.toUpperCase() == 'SUPP')
              .take(5)
              .toList();
          isLoading = false;
        });
      } else {
        // Gérer les erreurs du serveur ici
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      // Gérer les erreurs de connexion ici
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loadTopBottomChampions() async {
    setState(() => isLoading = true);
    try {
      final response = await http
          .get(Uri.parse('http://localhost:3000/tierlist/top-bottom'));
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        setState(() {
          top3Champions = (result['top3'] as List)
              .map((jsonChampion) => Champion.fromJson(jsonChampion))
              .toList();
          bottom3Champions = (result['bottom3'] as List)
              .map((jsonChampion) => Champion.fromJson(jsonChampion))
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dashboard.Champion sampleChampion = dashboard.Champion(
      name: 'Blitzcrank',
      winRate: 'WR : 52.3%',
      matches: 'PLAYED : 235',
      role: 'SUPP',
    );
    return Scaffold(
      body: Stack(
        children: [
          _isVideoFinished
              ? Image.asset('assets/finvid.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity)
              : _controller.value.isInitialized
                  ? SizedBox.expand(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _controller.value.size.width,
                          height: _controller.value.size.height,
                          child: VideoPlayer(_controller),
                        ),
                      ),
                    )
                  : Center(child: CircularProgressIndicator()),
          if (data.isNotEmpty)
            Positioned(
              bottom: 10,
              right: 10,
              child: StatusBar(statusData: {
                "LIVE VIEWERS": data['LIVE VIEWERS'],
                "RANK": data['RANK'],
                "Players": data['Players'],
                "Server Capacity": data['Server Capacity'],
              }),
            ),
          Positioned(
            top: 205,
            left: 410,
            child: gauge.StatusBar(statusData: {
              "Server Capacity": data['Server Capacity'],
            }),
          ),
          Positioned(
            top: 10,
            left: 410,
            child: buff.StatusBar(buffNerfData: {
              for (var champ in top3Champions)
                'assets/champ/${champ.name}.webp': 'assets/up.png',
              for (var champ in bottom3Champions)
                'assets/champ/${champ.name}.webp': 'assets/down.png',
            }),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: dashboard.DashboardWidget(
              textContent: 'Emerald IV',
              textContent2: '\nMain : Blitzcrank !',
              textContent3: 'Gotaga #EUW',
              textContent4: '(16% of EUW)',
              imagePath: 'assets/iconrank/emeraude.webp',
              imagePath2: 'assets/pp.png',
              champion: sampleChampion,
            ),
          ),
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Positioned(
                  bottom: 10,
                  left: 410,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ChampionsPage(),
                        ),
                      );
                    },
                    child: ChampionsTable(champions: champions),
                  ),
                ),
          Positioned(
              bottom: 10,
              left: 10,
              child: isLoading
                  ? CircularProgressIndicator()
                  : GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => RankBarChart(),
                          ),
                        );
                      },
                      child: Container(
                        height: 400,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: const DecorationImage(
                            image: AssetImage('assets/pp.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )),
          Positioned(
              top: 12, // Ajuste selon le placement souhaité
              right: 10, // Ajuste pour aligner à droite
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => RankBarChart(),
                    ),
                  );
                },
                child: Container(
                  height: 485, // Hauteur de l'image
                  width: 665, // Largeur de l'image
                  decoration: BoxDecoration(
                    color: AppColors.back.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(width: 2, color: AppColors.front),
                    image: const DecorationImage(
                      image: AssetImage('assets/graph.PNG'), // Image cliquable
                    ),
                  ),
                ),
              ))
        ],
      ),
    );
  }

  Widget _buildBottomButton(String label, VoidCallback onPressed) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          child: Text(label, style: TextStyle(fontSize: 36)),
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(minimumSize: Size(0, 100)),
        ),
      ),
    );
  }
}

class Champion {
  final String name;
  final String winRate;
  final String banRate;
  final String matches;
  final String role;

  Champion({
    required this.name,
    required this.winRate,
    required this.banRate,
    required this.matches,
    required this.role,
  });

  factory Champion.fromJson(Map<String, dynamic> json) {
    return Champion(
      name: json['Champion Name'],
      winRate: json['Win rate'],
      banRate: json['Ban Rate'],
      matches: json['Matches'],
      role: json['Role'],
    );
  }
}

// ChampionsTable widget
class ChampionsTable extends StatelessWidget {
  final List<Champion> champions;
  ChampionsTable({Key? key, required this.champions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.back.withOpacity(0.7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 2, color: AppColors.front)),
      child: Column(
        children: [
          SingleChildScrollView(
            child: DataTable(
              dataRowHeight: 55.0,
              columns: [
                DataColumn(
                    label: Text('Champion',
                        style: GoogleFonts.tiroDevanagariHindi(
                            color: AppColors.front, fontSize: 22))),
                DataColumn(
                    label: Text('Win Rate',
                        style: GoogleFonts.tiroDevanagariHindi(
                            color: AppColors.front, fontSize: 22))),
                DataColumn(
                    label: Text('Ban Rate',
                        style: GoogleFonts.tiroDevanagariHindi(
                            color: AppColors.front, fontSize: 22))),
                DataColumn(
                    label: Text('Matches',
                        style: GoogleFonts.tiroDevanagariHindi(
                            color: AppColors.front, fontSize: 22))),
              ],
              rows: champions
                  .map(
                    (champion) => DataRow(
                      cells: [
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Image.asset('assets/champ/${champion.name}.webp',
                                  width: 32, height: 32),
                              SizedBox(width: 8),
                              Text(champion.name,
                                  style: GoogleFonts.tiroDevanagariHindi(
                                      color: AppColors.front, fontSize: 22))
                            ],
                          ),
                        ),
                        DataCell(Text(champion.winRate,
                            style: GoogleFonts.tiroDevanagariHindi(
                                color: AppColors.front, fontSize: 22))),
                        DataCell(Text(champion.banRate,
                            style: GoogleFonts.tiroDevanagariHindi(
                                color: AppColors.front, fontSize: 22))),
                        DataCell(Text(champion.matches,
                            style: GoogleFonts.tiroDevanagariHindi(
                                color: AppColors.front, fontSize: 22))),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class AppColors {
  static const Color back = Color(0xFF25232A);
  static const Color front = Color(0xFFd0bcff);
}
