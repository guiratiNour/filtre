import 'dart:math'; // Ajout pour l'utilisation de Random
import 'package:recommendation/equipment.dart';

class Hebergement {
  late int hebergement_id;
  late String nom;
  late String description;
  late String ville;
  late String pays;
  late double prix;
  late double distance;
  late String contact;
  late String adresse;
  late String politiqueAnnulation;
  late String nbEtoile;
  late double superficie;
  late int nb_Salles_De_Bains;
  late int nb_Chambres;
  late bool dispo;
  late int nombreDeReservations;
  late List<Equipement> equipements;
  late double note; // Nouvelle propriété pour stocker une note aléatoire sur 10
  late double score;

  Hebergement({
    required this.hebergement_id,
    required this.nom,
    required this.description,
    required this.ville,
    required this.pays,
    required this.prix,
    required this.distance,
    required this.contact,
    required this.adresse,
    required this.politiqueAnnulation,
    required this.nbEtoile,
    required this.superficie,
    required this.nb_Salles_De_Bains,
    required this.nb_Chambres,
    required this.dispo,
    required this.nombreDeReservations,
    required this.equipements,
  }) {
    // Génère une note aléatoire entre 0 et 10 lors de l'initialisation de chaque objet Hebergement
    Random rng = Random();
    note = rng.nextDouble() * 10;
  }

  factory Hebergement.fromJson(Map<String, dynamic> json) {
    var equipementsList = json['equipements'] as List;
    List<Equipement> equipements = equipementsList
        .map((equipementJson) => Equipement.fromJson(equipementJson))
        .toList();

    return Hebergement(
      hebergement_id: json['hebergement_id'] as int? ?? 0,
      nom: json['nom'] as String? ?? '',
      description: json['description'] as String? ?? '',
      ville: json['ville'] as String? ?? '',
      pays: json['pays'] as String? ?? '',
      prix: json['prix'] as double? ?? 0.0,
      distance: json['distance'] as double? ?? 0.0,
      contact: json['contact'] as String? ?? '',
      adresse: json['adresse'] as String? ?? '',
      politiqueAnnulation: json['politiqueAnnulation'] as String? ?? '',
      nbEtoile: json['nbEtoile'] as String? ?? '',
      superficie: json['superficie'] as double? ?? 0.0,
      nb_Salles_De_Bains: json['nb_Salles_De_Bains'] as int? ?? 0,
      nb_Chambres: json['nb_Chambres'] as int? ?? 0,
      dispo: json['dispo'] as bool? ?? false,
      nombreDeReservations: json['nombreDeReservations'] as int? ?? 0,
      equipements: equipements,
    )..note = Random().nextDouble() *
        10; // Assigne une note aléatoire lors de la création à partir de JSON
  }

  Map<String, dynamic> toJson() {
    return {
      'hebergement_id': hebergement_id,
      'nom': nom,
      'description': description,
      'ville': ville,
      'pays': pays,
      'prix': prix,
      'distance': distance,
      'contact': contact,
      'adresse': adresse,
      'politiqueAnnulation': politiqueAnnulation,
      'nbEtoile': nbEtoile,
      'superficie': superficie,
      'nb_Salles_De_Bains': nb_Salles_De_Bains,
      'nb_Chambres': nb_Chambres,
      'dispo': dispo,
      'nombreDeReservations': nombreDeReservations,
      'equipements':
          equipements.map((equipement) => equipement.toJson()).toList(),
      'note': note, // Inclure la note dans le JSON
    };
  }
}
