import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vazifa22/provider/restaran_provider.dart';
import 'package:vazifa22/view/screen/map_screen.dart';

class RestaurantScreen extends StatelessWidget {
  const RestaurantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final restaurants = Provider.of<RestaurantProvider>(context).restaurants;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurants'),
      ),
      body: ListView.builder(
        itemCount: restaurants.length,
        itemBuilder: (context, index) {
          final restaurant = restaurants[index];
          return ListTile(
            leading: Container(
              height: 100,
              width: 100,
              child: Image.asset(restaurant.imagePath),
            ),
            title: Text(restaurant.name),
            subtitle: Text(
              'Lat: ${restaurant.location.latitude}, Lon: ${restaurant.location.longitude}',
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MapScreen(
                    latitude: restaurant.location.latitude,
                    longitude: restaurant.location.longitude,
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    const MapScreen(latitude: 0, longitude: 0)),
          );
        },
        child: const Icon(Icons.map),
      ),
    );
  }
}
