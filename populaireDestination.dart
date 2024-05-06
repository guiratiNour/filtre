import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:recommendation/hebergement.dart';
import 'package:recommendation/hebergementService.dart';

class PopularDestinationPage extends StatelessWidget {
  final List<Hebergement> selectedHebergements;

  PopularDestinationPage({required this.selectedHebergements});

  Future<String> fetchCountryImage(String countryName) async {
    final response = await http.get(Uri.parse(
        'https://api.unsplash.com/search/photos?query=$countryName landscape&client_id=KDANlN3q7dLNzIHvd8gP_2QeEemyeAs2J6L0xZzyHC8'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'][0]['urls']['small'];
    } else {
      throw Exception('Failed to load image');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Destinations populaires'),
      ),
      body: FutureBuilder<List<String>>(
        future: HebergementService()
            .getMostReservedCountriesSimple(selectedHebergements),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else {
            List<String> popularCountries = snapshot.data ?? [];
            return ListView.builder(
              itemCount: popularCountries.length,
              itemBuilder: (context, index) {
                String country = popularCountries[index];
                return FutureBuilder<String>(
                  future: fetchCountryImage(country),
                  builder: (context, imageSnapshot) {
                    if (imageSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return ListTile(
                        title: Text(country),
                        leading: CircularProgressIndicator(),
                      );
                    } else if (imageSnapshot.hasError) {
                      return ListTile(
                        title: Text(country),
                        leading: Icon(Icons.error),
                      );
                    } else {
                      return ListTile(
                        title: Text(country),
                        leading: Image.network(imageSnapshot.data ?? ''),
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
