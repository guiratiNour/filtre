import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:recommendation/hebergement.dart';

class RecommendationPage extends StatefulWidget {
  final List<Hebergement> selectedHebergements;

  const RecommendationPage({Key? key, required this.selectedHebergements})
      : super(key: key);

  @override
  _RecommendationPageState createState() => _RecommendationPageState();
}

class _RecommendationPageState extends State<RecommendationPage> {
  Set<String> selectedHebergementIds = {};

  @override
  void initState() {
    super.initState();
    _loadSelectedHebergements();
  }

  @override
  void dispose() {
    _saveSelectedHebergements();
    super.dispose();
  }

  Future<void> _saveSelectedHebergements() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'selectedHebergementIds', selectedHebergementIds.toList());
  }

  Future<void> _loadSelectedHebergements() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedIds = prefs.getStringList('selectedHebergementIds');
    if (savedIds != null) {
      setState(() {
        selectedHebergementIds = Set.from(savedIds);
      });
    }
  }

  void toggleSelection(String hebergementId) {
    setState(() {
      if (selectedHebergementIds.contains(hebergementId)) {
        selectedHebergementIds.remove(hebergementId);
      } else {
        selectedHebergementIds.add(hebergementId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Utilisation d'un Set pour éliminer les doublons basés sur l'ID de chaque hébergement
    Set<String> uniqueIds = Set();
    List<Hebergement> uniqueHebergements =
        widget.selectedHebergements.where((hebergement) {
      return uniqueIds.add(hebergement.hebergement_id.toString());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Page de Recommandation'),
      ),
      body: ListView.builder(
        itemCount: uniqueHebergements.length,
        itemBuilder: (context, index) {
          Hebergement hebergement = uniqueHebergements[index];
          String hebergementId = hebergement.hebergement_id.toString();
          bool isSelected = selectedHebergementIds.contains(hebergementId);
          return ListTile(
            title: Text(hebergement.nom),
            subtitle: Text('Description: ${hebergement.description}'),
            trailing: Icon(
              isSelected ? Icons.check_box : Icons.check_box_outline_blank,
              color: isSelected ? Colors.green : null,
            ),
            onTap: () => toggleSelection(hebergementId),
          );
        },
      ),
    );
  }
}
