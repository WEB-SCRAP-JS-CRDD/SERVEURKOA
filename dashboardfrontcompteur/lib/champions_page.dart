import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http; // Importez le package http

String getIconName(String role) {
  switch (role.toUpperCase()) {
    case 'ADC':
      return 'ADC';
    case 'SUPP':
      return 'SUPP';
    case 'MID':
      return 'MID';
    case 'JUNGLE':
      return 'JUNGLE';
    case 'TOP':
      return 'TOP';
    default:
      return 'ALL';
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

class ChampionsPage extends StatefulWidget {
  @override
  _ChampionsPageState createState() => _ChampionsPageState();
}

class _ChampionsPageState extends State<ChampionsPage> {
  List<Champion> champions = [];
  List<Champion> filteredChampions = [];
  bool isAscending = false;
  int? sortColumnIndex;
  String selectedRole = 'All';
  bool isLoading = false;
  double _opacity = 1.0;
  final double iconSize = 32.0;
  final TextStyle textStyle = TextStyle(fontSize: 22);
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _initialSearchDone = false;

  @override
  void initState() {
    super.initState();
    loadChampions();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> loadChampions() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse(
          'http://localhost:3000/tierlist?role=${selectedRole != 'All' ? selectedRole : ''}&sortColumn=${sortColumnIndex != null ? _getSortColumnName(sortColumnIndex!) : ''}&sortOrder=${isAscending ? 'asc' : 'desc'}&searchQuery=${_searchController.text}'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        setState(() {
          champions = data
              .map((jsonChampion) =>
                  Champion.fromJson(jsonChampion as Map<String, dynamic>))
              .toList();
          filteredChampions = champions;
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

  void _onSearchChanged() {
    if (_initialSearchDone) {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        loadChampions();
      });
    } else {
      _initialSearchDone = true;
      loadChampions();
    }
  }

  String _getSortColumnName(int columnIndex) {
    switch (columnIndex) {
      case 0:
        return 'Champion Name';
      case 1:
        return 'Win rate';
      case 2:
        return 'Ban Rate';
      case 3:
        return 'Matches';
      default:
        return '';
    }
  }

  void onSort(int columnIndex, bool ascending) {
    setState(() {
      sortColumnIndex = columnIndex;
      isAscending = ascending;
      loadChampions();
    });
  }

  void filterChampions(String role) {
    setState(() {
      selectedRole = role;
      loadChampions();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  List<Champion> getVisibleChampions() {
    return filteredChampions.take(8).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/tabtitle.png',
          width: 300,
          height: 50,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/finvid2.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: isLoading
            ? Center(
                child: AnimatedOpacity(
                  opacity: _opacity,
                  duration: Duration(milliseconds: 500),
                  child: Image.asset('assets/logo.jpg'),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (var role in [
                          'ALL',
                          'ADC',
                          'SUPP',
                          'MID',
                          'JUNGLE',
                          'TOP'
                        ])
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedRole = role == 'ALL' ? 'All' : role;
                              });
                              filterChampions(selectedRole);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: selectedRole ==
                                        (role == 'ALL' ? 'All' : role)
                                    ? AppColors.back
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: SvgPicture.asset(
                                'assets/icons/$role.svg',
                                width: iconSize,
                                height: iconSize,
                                color: selectedRole ==
                                        (role == 'ALL' ? 'All' : role)
                                    ? AppColors.front
                                    : null,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Search Champion',
                        suffixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          width: 1500,
                          decoration: BoxDecoration(
                            color: AppColors.back.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: DataTable(
                            dataRowHeight: 60.0,
                            sortAscending: isAscending,
                            sortColumnIndex: sortColumnIndex,
                            columnSpacing: 200,
                            horizontalMargin: 10,
                            columns: <DataColumn>[
                              DataColumn(
                                label: Container(
                                  width: 200,
                                  child: Text('Champion',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                onSort: onSort,
                              ),
                              DataColumn(
                                label: Container(
                                  width: 100,
                                  child: Text('Win Rate',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                onSort: onSort,
                              ),
                              DataColumn(
                                label: Container(
                                  width: 100,
                                  child: Text('Ban Rate',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                onSort: onSort,
                              ),
                              DataColumn(
                                label: Container(
                                  width: 100,
                                  child: Text('Matches',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                onSort: onSort,
                              ),
                              DataColumn(
                                label: Container(
                                  width: 100,
                                  child: Text('Role',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                            rows: getVisibleChampions()
                                .map((champion) => DataRow(
                                      cells: [
                                        DataCell(
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Image.asset(
                                                  'assets/champ/${champion.name}.webp',
                                                  width: iconSize,
                                                  height: iconSize),
                                              SizedBox(width: 8),
                                              Text(champion.name,
                                                  style: textStyle),
                                            ],
                                          ),
                                        ),
                                        DataCell(Text(champion.winRate,
                                            style: textStyle)),
                                        DataCell(Text(champion.banRate,
                                            style: textStyle)),
                                        DataCell(Text(champion.matches,
                                            style: textStyle)),
                                        DataCell(
                                          SvgPicture.asset(
                                            'assets/icons/${getIconName(champion.role)}.svg',
                                            width: iconSize,
                                            height: iconSize,
                                          ),
                                        ),
                                      ],
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class AppColors {
  static const Color back = Color(0xFF25232A);
  static const Color front = Color(0xFFd0bcff);
}
