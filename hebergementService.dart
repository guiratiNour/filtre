import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:recommendation/DBSCANClustering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:recommendation/hebergement.dart';
import 'package:recommendation/KMeansClustering.dart';

class HebergementService {
  // Liste pour stocker les hébergements filtrés
  List<Hebergement> filteredHebergements = [];

  Future<List<Hebergement>> fetchHebergements() async {
    final response =
        await http.get(Uri.parse('http://localhost:62623/hebergement/all'));

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      return responseData.map((data) => Hebergement.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load hebergements');
    }
  }

  // Méthode pour sauvegarder les hébergements filtrés
  Future<void> saveFilteredHebergements(
      List<Hebergement> filteredHebergements) async {
    SharedPreferences prefs = await SharedPreferences
        .getInstance(); //Cet objet permet de stocker et de récupérer des données sous forme de paires clé-valeur
    List<String> hebergementIds =
        filteredHebergements //la méthode transforme la liste des objets Hebergement en une liste de chaînes de caractères représentant leurs identifiants
            .map((hebergement) => hebergement.hebergement_id.toString())
            .toList();
    await prefs.setStringList('filteredHebergementIds',
        hebergementIds); //enregistre la liste des identifiants d'hébergements dans les préférences partagées
  }

  // Méthode pour charger les hébergements filtrés
  Future<List<Hebergement>> loadFilteredHebergements() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? hebergementIds = prefs.getStringList(
        'filteredHebergementIds'); //Cette ligne tente de récupérer une liste de chaînes de caractères stockées sous la clé 'filteredHebergementIds'
    List<Hebergement> filteredHebergements = [];

    if (hebergementIds != null) {
      for (String id in hebergementIds) {
        Hebergement? hebergement = await getHebergementById(id);
        if (hebergement != null) {
          filteredHebergements.add(hebergement);
        }
      }
    }

    return filteredHebergements;
  }

//Récupère les détails d'un hébergement spécifique en utilisant son identifiant.
  Future<List<Hebergement>> getFilteredHebergements({
    required String selectedCountry,
    required double minSelectedPrice,
    required double maxSelectedPrice,
    required double minSelectedDistance,
    required double maxSelectedDistance,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? likedIds = prefs.getStringList('likedHebergementIds');
    List<Hebergement> likedHebergements = [];
    if (likedIds != null) {
      for (String id in likedIds) {
        Hebergement? hebergement = await getHebergementById(id);
        if (hebergement != null) {
          likedHebergements.add(hebergement);
        }
      }
    }

    final response = await http.post(
      Uri.parse('http://localhost:62623/api/filtered-hebergements/filter'),
      body: {
        'selectedCountry': selectedCountry,
        'minSelectedPrice': minSelectedPrice.toString(),
        'maxSelectedPrice': maxSelectedPrice.toString(),
        'minSelectedDistance': minSelectedDistance.toString(),
        'maxSelectedDistance': maxSelectedDistance.toString(),
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      List<Hebergement> filteredHebergements =
          responseData.map((data) => Hebergement.fromJson(data)).toList();

      // Ajouter les hébergements likés à la liste filtrée
      filteredHebergements.addAll(likedHebergements);

      return filteredHebergements;
    } else {
      throw Exception('Failed to filter hebergements');
    }
  }

  Future<List<Hebergement>> getRecommendedHebergements(
    List<Hebergement> selectedHebergements,
  ) async {
    final allHebergements = await fetchHebergements();
    List<Hebergement> recommendedHebergements = [];

    // Intégrer l'algorithme K-Means
    KMeansClustering kmeans = KMeansClustering(
      data: filteredHebergements.isNotEmpty
          ? filteredHebergements
          : allHebergements,
      k: 5, // Nombre de clusters, ajustez selon vos besoins
    );

    kmeans.run(); // Exécutez l'algorithme K-Means

    // Créer une liste des clusters pour les hébergements sélectionnés
    List<int> selectedClusters = [];
    for (Hebergement selectedHebergement in selectedHebergements) {
      selectedClusters.add(kmeans.predict(selectedHebergement));
    }

    // Récupérer les hébergements de chaque cluster sélectionné
    for (int clusterId in selectedClusters) {
      List<Hebergement> clusterHebergements =
          kmeans.getCluster(clusterId).toList();

      // Appliquer les critères de filtrage pour chaque hébergement sélectionné
      for (Hebergement selectedHebergement in selectedHebergements) {
        List<Hebergement> filteredHebergements = clusterHebergements
            .where((hebergement) =>
                hebergement.pays == selectedHebergement.pays &&
                hebergement.nbEtoile == selectedHebergement.nbEtoile &&
                hebergement.prix >=
                    selectedHebergement.prix -
                        300 && // Filtrer les prix dans une plage de +/- 300
                hebergement.prix <=
                    selectedHebergement.prix +
                        300 && // Filtrer les prix dans une plage de +/- 300
                hebergement.distance >=
                    selectedHebergement.distance -
                        200 && // Filtrer les distances dans une plage de +/- 200
                hebergement.distance <=
                    selectedHebergement.distance +
                        300) // Filtrer les distances dans une plage de +/- 300
            .toList();

        recommendedHebergements.addAll(filteredHebergements);
      }
    }

    // Retirer les hébergements déjà sélectionnés de la liste des recommandations
    recommendedHebergements.removeWhere(
        (hebergement) => selectedHebergements.contains(hebergement));

    return recommendedHebergements;
  }

  Future<Hebergement?> getHebergementById(String id) async {
    final response =
        await http.get(Uri.parse('http://localhost:62623/hebergement/$id'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return Hebergement.fromJson(responseData);
    } else {
      throw Exception('Failed to load hebergement');
    }
  }

  /*************************************************** */
//méthode pour les pays les plus populaires
  Future<List<String>> getMostReservedCountriesSimple(
      List<Hebergement> selectedHebergements) async {
    Map<String, int> countryReservationCount = {};
    for (Hebergement hebergement in selectedHebergements) {
      // Assurez-vous que nombreDeReservations n'est pas null avec une valeur par défaut de 0
      int reservations = hebergement.nombreDeReservations ?? 0;

      if (!countryReservationCount.containsKey(hebergement.pays)) {
        countryReservationCount[hebergement.pays] = 0;
      }
      // Assurez-vous que l'accès à la valeur du dictionnaire ne retourne jamais null en utilisant !
      countryReservationCount[hebergement.pays] =
          countryReservationCount[hebergement.pays]! + reservations;
    }

    var sortedCountries = countryReservationCount.entries.toList();
    sortedCountries.sort((a, b) => b.value.compareTo(
        a.value)); // Trier par le total des réservations décroissantes

    // Retourner les noms des pays triés par le total des réservations, limités aux 5 premiers
    return sortedCountries.map((entry) => entry.key).take(5).toList();
  }

  /***************************************************************************************** */
  /*Future<List<Hebergement>> getRecommendedHebergements(
      List<Hebergement> selectedHebergements) async {
    final allHebergements = await fetchHebergements();
    List<Hebergement> recommendedHebergements = [];

    for (Hebergement selectedHebergement in selectedHebergements) {
      // Intégrer l'algorithme de recommandation
      // Exemple avec DBSCANClustering
      DBSCANClustering dbscan = DBSCANClustering(
        data: allHebergements,
        epsilon: 0.1, // Valeur d'epsilon à ajuster selon vos besoins
        minPts: 5, // Valeur de minPts à ajuster selon vos besoins
      );

      List<int> clusterAssignments = dbscan.run();

      // Récupérer les hébergements du même cluster que l'hébergement sélectionné
      int clusterId =
          clusterAssignments[selectedHebergements.indexOf(selectedHebergement)];
      List<Hebergement> clusterHebergements = allHebergements
          .where((hebergement) =>
              clusterAssignments[allHebergements.indexOf(hebergement)] ==
              clusterId)
          .toList();

      // Appliquer les critères de filtrage spécifiques à cet hébergement sélectionné
      List<Hebergement> filteredHebergements = clusterHebergements
          .where((hebergement) =>
              hebergement.pays == selectedHebergement.pays &&
              hebergement.nbEtoile == selectedHebergement.nbEtoile &&
              hebergement.prix >= selectedHebergement.prix - 300 &&
              hebergement.prix <= selectedHebergement.prix + 300 &&
              hebergement.distance >= selectedHebergement.distance - 200 &&
              hebergement.distance <= selectedHebergement.distance + 300)
          .toList();

      // Retirer les hébergements déjà sélectionnés de la liste des recommandations
      filteredHebergements.removeWhere(
          (hebergement) => selectedHebergements.contains(hebergement));

      recommendedHebergements.addAll(filteredHebergements);
    }

    return recommendedHebergements;
  }*/
}
