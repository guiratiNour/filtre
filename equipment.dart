class Equipement {
  final int id;
  final String nom;

  Equipement({required this.id, required this.nom});

  factory Equipement.fromJson(Map<String, dynamic> json) {
    return Equipement(
      id: json['id'] as int? ?? 0,
      nom: json['nom'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
    };
  }
}
