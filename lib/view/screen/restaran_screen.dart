import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:vazifa22/provider/restaran_provider.dart';
import 'package:vazifa22/services/yandex_map_services.dart';
import 'package:vazifa22/view/screen/map_screen.dart';

class RestaurantScreen extends StatelessWidget {
  const RestaurantScreen({Key? key}) : super(key: key);

  Future<void> _pickImage(BuildContext context, int index) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imagePath = pickedFile.path;

      // Update the restaurant image path using Provider
      Provider.of<RestaurantProvider>(context, listen: false)
          .updateRestaurantImage(index, imagePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final restaurants = Provider.of<RestaurantProvider>(context).restaurants;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text('Restaurants'),
      ),
      body: ListView.builder(
        itemCount: restaurants.length,
        itemBuilder: (context, index) {
          final restaurant = restaurants[index];

          return Dismissible(
            key: Key(restaurant.name),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              Provider.of<RestaurantProvider>(context, listen: false)
                  .removeRestaurant(index);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${restaurant.name} dismissed')),
              );
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: ListTile(
              leading: GestureDetector(
                onTap: () => _pickImage(context, index),
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: restaurant.imagePath.isNotEmpty
                          ? FileImage(File(restaurant.imagePath))
                          : const AssetImage('assets/markaz_oshxona.jpg')
                              as ImageProvider,
                    ),
                  ),
                ),
              ),
              title: Text(restaurant.name),
              subtitle: FutureBuilder<String>(
                future: YandexMapService.getAddressByPoint(
                  restaurant.location,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text('Loading...');
                  } else if (snapshot.hasError) {
                    return const Text('Error loading address');
                  } else {
                    return Text(snapshot.data ?? 'Address not found');
                  }
                },
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
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MapScreen(latitude: 0, longitude: 0),
            ),
          );
        },
        child: const Icon(Icons.map),
      ),
    );
  }
}
