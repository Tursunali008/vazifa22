import 'package:flutter/material.dart';
import 'package:vazifa22/model/restaran.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class RestaurantProvider with ChangeNotifier {
  final List<Restaurant> _restaurants = [];

  List<Restaurant> get restaurants => _restaurants;

  void addRestaurant(Restaurant restaurant) {
    _restaurants.add(restaurant);
    notifyListeners();
  }

  void updateRestaurantLocation(int index, Point location) {
    if (index >= 0 && index < _restaurants.length) {
      _restaurants[index] = Restaurant(
        name: _restaurants[index].name,
        imagePath: _restaurants[index].imagePath,
        location: location,
      );
      notifyListeners();
    }
  }

  void updateRestaurantImage(int index, String imagePath) {
    if (index >= 0 && index < _restaurants.length) {
      _restaurants[index] = Restaurant(
        name: _restaurants[index].name,
        imagePath: imagePath,
        location: _restaurants[index].location,
      );
      notifyListeners();
    }
  }

  void removeRestaurant(int index) {
    if (index >= 0 && index < _restaurants.length) {
      _restaurants.removeAt(index);
      notifyListeners();
    }
  }
}
