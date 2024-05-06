import 'dart:math';
import 'hebergement.dart';

class DBSCANClustering {
  late List<Hebergement> _data;
  late double _epsilon;
  late int _minPts;

  DBSCANClustering({
    required List<Hebergement> data,
    required double epsilon,
    required int minPts,
  }) {
    _data = data;
    _epsilon = epsilon;
    _minPts = minPts;
  }

  List<int> run() {
    List<int> clusterAssignments = List.filled(_data.length, -1);
    int clusterId = 0;

    for (int i = 0; i < _data.length; i++) {
      if (clusterAssignments[i] != -1) continue; // Already visited

      List<int> neighbors = _findNeighbors(i);
      if (neighbors.length < _minPts) {
        // Noise point
        clusterAssignments[i] = 0;
        continue;
      }

      clusterId++;
      _expandCluster(i, neighbors, clusterId, clusterAssignments);
    }

    return clusterAssignments;
  }

  List<int> _findNeighbors(int pointIndex) {
    List<int> neighbors = [];
    for (int i = 0; i < _data.length; i++) {
      if (_calculateDistance(_data[pointIndex], _data[i]) <= _epsilon) {
        neighbors.add(i);
      }
    }
    return neighbors;
  }

  void _expandCluster(int pointIndex, List<int> neighbors, int clusterId,
      List<int> assignments) {
    assignments[pointIndex] = clusterId;

    for (int neighborIndex in neighbors) {
      if (assignments[neighborIndex] == -1) {
        List<int> neighborNeighbors = _findNeighbors(neighborIndex);
        if (neighborNeighbors.length >= _minPts) {
          neighbors.addAll(neighborNeighbors);
        }
      }
      if (assignments[neighborIndex] == 0) {
        assignments[neighborIndex] = clusterId;
      }
    }
  }

  double _calculateDistance(Hebergement point1, Hebergement point2) {
    // Utilisation de la distance euclidienne sur plusieurs attributs des hébergements
    return sqrt(pow(point1.prix - point2.prix, 2) +
        pow(point1.distance - point2.distance, 2) +
        pow(point1.superficie - point2.superficie, 2));
    // Ajoutez d'autres attributs ici pour affiner la similarité
  }
}
