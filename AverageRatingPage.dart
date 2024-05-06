import 'package:flutter/material.dart';
import 'package:recommendation/hebergement.dart';

class AverageRatingPage extends StatelessWidget {
  final List<Hebergement> hebergements;

  // Utilisez le constructeur existant si déjà défini pour accepter une liste d'hébergements
  AverageRatingPage({required this.hebergements});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Les Moyennes'),
      ),
      body: ListView.builder(
        itemCount: hebergements.length,
        itemBuilder: (context, index) {
          Hebergement hebergement = hebergements[index];
          return ListTile(
            title: Text(hebergement.nom),
            subtitle: Text('Note: ${hebergement.note.toStringAsFixed(1)}/10'),
          );
        },
      ),
    );
  }
}
