import 'package:flutter/material.dart';
import 'package:recommendation/hebergement.dart';

class Top10Page extends StatelessWidget {
  final List<Hebergement> hebergements;

  Top10Page({required this.hebergements});

  List<Hebergement> calculateTopHebergements() {
    // Attribution des poids égaux aux notes et aux réservations
    double weightNote = 0.5;
    double weightReservations = 0.5;

    // Calcul du score composite pour chaque hébergement
    hebergements.forEach((hebergement) {
      hebergement.score = (hebergement.note * weightNote) +
          (hebergement.nombreDeReservations * weightReservations);
    });

    // Tri des hébergements par score en ordre décroissant
    List<Hebergement> sortedHebergements = List.from(
        hebergements) // la liste est copiée dans sortedHebergements en utilisant List.from(hebergements)
      ..sort((a, b) => b.score.compareTo(a.score));

    // Sélection des 10 premiers
    return sortedHebergements
        .take(10)
        .toList(); //Enfin, la méthode utilise take(10) pour sélectionner les 10 premiers éléments de la liste triée, lesquels sont retournés sous forme de liste après avoir été convertis en liste grâce à toList()
  }

  @override
  Widget build(BuildContext context) {
    List<Hebergement> topHebergements = calculateTopHebergements();

    return Scaffold(
      appBar: AppBar(
        title: Text('Top 10 Hébergements'),
      ),
      body: ListView.builder(
        itemCount: topHebergements.length,
        itemBuilder: (context, index) {
          Hebergement hebergement = topHebergements[index];
          return ListTile(
            title: Text(hebergement.nom),
            subtitle: Text('Score: ${hebergement.score.toStringAsFixed(2)}'),
          );
        },
      ),
    );
  }
}
