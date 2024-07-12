import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vazifa22/model/restaran.dart';
import 'package:vazifa22/provider/restaran_provider.dart';
import 'package:vazifa22/services/yandex_map_services.dart';
import 'package:vazifa22/view/screen/restaran_screen.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class MapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  const MapScreen({super.key, required this.latitude, required this.longitude});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late YandexMapController mapController;
  final searchController = TextEditingController();
  List<SuggestItem> suggestions = [];

  void onMapCreated(YandexMapController controller) {
    mapController = controller;
    setState(() {
      if (widget.latitude != 0 && widget.longitude != 0) {
        goToLocation(
            Point(latitude: widget.latitude, longitude: widget.longitude));
      }
    });
  }

  void getSearchSuggestions(String address) async {
    suggestions = await YandexMapService.getSearchSuggestions(address);
    setState(() {});
  }

  void goToLocation(Point? location) {
    if (location != null) {
      mapController.moveCamera(
        animation: const MapAnimation(
          type: MapAnimationType.smooth,
        ),
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: location,
            zoom: 15,
          ),
        ),
      );
    }
  }

  void _addMarker(Point location) {
    mapController;
    _showAddRestaurantDialog(location);
  }

  void _showAddRestaurantDialog(Point location) {
    final nameController = TextEditingController();
    final imageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Restaurant'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Restaurant Name'),
            ),
            TextField(
              controller: imageController,
              decoration: const InputDecoration(labelText: 'Image Path'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final name = nameController.text;
              final imagePath = imageController.text;
              if (name.isNotEmpty && imagePath.isNotEmpty) {
                final restaurant = Restaurant(
                  name: name,
                  imagePath: imagePath,
                  location: location,
                );
                Provider.of<RestaurantProvider>(context, listen: false)
                    .addRestaurant(restaurant);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text('Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const RestaurantScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          YandexMap(
            onMapCreated: onMapCreated,
            onMapTap: (Point point) {
              _addMarker(point);
            },
          ),
          Align(
            alignment: const Alignment(0, -0.8),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: getSearchSuggestions,
                  ),
                  Container(
                    constraints: BoxConstraints(
                      maxHeight:
                          (70 * suggestions.length).clamp(0, 250).toDouble(),
                    ),
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      color: Colors.white,
                    ),
                    child: ListView.builder(
                      itemCount: suggestions.length,
                      itemBuilder: (ctx, index) {
                        final suggestion = suggestions[index];
                        return ListTile(
                          onTap: () {
                            goToLocation(suggestion.center);
                            suggestions = [];
                            searchController.text = "";
                            setState(() {});
                          },
                          title: Text(suggestion.displayText),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
