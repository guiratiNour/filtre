import 'dart:math';
import 'hebergement.dart';

class KMeansClustering {
  late List<Hebergement> _data;
  late int _k;
  late List<Point<num>> _centroids;
  late List<int> _clusterAssignments;

  KMeansClustering({
    required List<Hebergement> data,
    required int k,
  }) {
    _data = data;
    _k = k;
    _centroids = [];
    _clusterAssignments = [];
  }

  void run() {
    // Initialisation aléatoire des centroïdes
    _initializeCentroids();

    // Itération jusqu'à la convergence
    for (int i = 0; i < 100; i++) {
      // Limite de 100 itérations pour éviter les boucles infinies
      // Attribution des clusters initiaux
      _assignClusters();

      // Mise à jour des centroïdes
      _updateCentroids();

      // Vérifier la convergence
      if (_hasConverged()) {
        break;
      }
    }
  }

  void _initializeCentroids() {
    // Choix aléatoire de k points comme centroïdes initiaux
    for (int i = 0; i < _k; i++) {
      int randomIndex = Random().nextInt(_data.length);
      _centroids.add(
          Point<num>(_data[randomIndex].prix, _data[randomIndex].distance));
    }
  }

  void _assignClusters() {
    _clusterAssignments = List.filled(_data.length, -1);

    for (int i = 0; i < _data.length; i++) {
      double minDistance = double.infinity;
      int closestCentroidIndex = -1;

      // Trouver le centroïde le plus proche pour chaque point de données
      for (int j = 0; j < _centroids.length; j++) {
        double distance = _calculateDistance(_centroids[j], _data[i]);
        if (distance < minDistance) {
          minDistance = distance;
          closestCentroidIndex = j;
        }
      }

      _clusterAssignments[i] = closestCentroidIndex;
    }
  }

  void _updateCentroids() {
    List<Point<num>> newCentroids = List.filled(_k, Point<num>(0, 0));
    List<int> clusterCounts = List.filled(_k, 0);

    for (int i = 0; i < _data.length; i++) {
      int clusterIndex = _clusterAssignments[i];
      newCentroids[clusterIndex] +=
          Point<num>(_data[i].prix, _data[i].distance);
      clusterCounts[clusterIndex]++;
    }

    for (int i = 0; i < _k; i++) {
      if (clusterCounts[i] > 0) {
        newCentroids[i] = Point<num>(newCentroids[i].x / clusterCounts[i],
            newCentroids[i].y / clusterCounts[i]);
      }
    }

    _centroids = newCentroids;
  }

  bool _hasConverged() {
    // Vérifier si les centroids ont convergé
    for (int i = 0; i < _k; i++) {
      if (_centroids[i] != _calculateCentroid(i)) {
        return false;
      }
    }
    return true;
  }

  Point<num> _calculateCentroid(int centroidIndex) {
    Point<num> centroid = Point<num>(0, 0);
    int count = 0;

    for (int i = 0; i < _data.length; i++) {
      if (_clusterAssignments[i] == centroidIndex) {
        centroid += Point<num>(_data[i].prix, _data[i].distance);
        count++;
      }
    }

    if (count > 0) {
      centroid = Point<num>(centroid.x / count, centroid.y / count);
    }

    return centroid;
  }

  double _calculateDistance(Point<num> point1, Hebergement point2) {
    return sqrt(
        pow(point1.x - point2.prix, 2) + pow(point1.y - point2.distance, 2));
  }

  int predict(Hebergement hebergement) {
    double minDistance = double.infinity;
    int closestCentroidIndex = -1;

    // Trouver le centroïde le plus proche pour le nouvel hébergement
    for (int j = 0; j < _centroids.length; j++) {
      double distance = _calculateDistance(_centroids[j], hebergement);
      if (distance < minDistance) {
        minDistance = distance;
        closestCentroidIndex = j;
      }
    }

    return closestCentroidIndex;
  }

  List<Hebergement> getCluster(int clusterIndex) {
    List<Hebergement> clusterHebergements = [];

    // Récupérer les hébergements du cluster spécifié
    for (int i = 0; i < _data.length; i++) {
      if (_clusterAssignments[i] == clusterIndex) {
        clusterHebergements.add(_data[i]);
      }
    }

    return clusterHebergements;
  }
}
