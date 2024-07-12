import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:location/location.dart';

class YandexMapService {
  static final Location _location = Location();
  static LocationData? currentLocation;
  static bool _isServiceEnabled = false;
  static PermissionStatus _permissionStatus = PermissionStatus.denied;

  // Get the current location of the device
  static Future<void> getCurrentLocation() async {
    // Check if location services are enabled
    _isServiceEnabled = await _location.serviceEnabled();
    if (!_isServiceEnabled) {
      _isServiceEnabled = await _location.requestService();
      if (!_isServiceEnabled) {
        return;
      }
    }

    // Check and request location permissions
    _permissionStatus = await _location.hasPermission();
    if (_permissionStatus == PermissionStatus.denied) {
      _permissionStatus = await _location.requestPermission();
      if (_permissionStatus != PermissionStatus.granted) {
        return;
      }
    }

    // Get the current location
    currentLocation = await _location.getLocation();
  }

  // Get search suggestions for a given address
  static Future<List<SuggestItem>> getSearchSuggestions(String address) async {
    // Perform the suggestion request
    final result = await YandexSuggest.getSuggestions(
      text: address,
      boundingBox: const BoundingBox(
        northEast: Point(
          latitude: 55.751244, // Example coordinates for Moscow
          longitude: 37.618423,
        ),
        southWest: Point(
          latitude: 55.711244, // Example coordinates for Moscow
          longitude: 37.548423,
        ),
      ),
      suggestOptions: const SuggestOptions(
        suggestType: SuggestType.geo,
      ),
    );

    // Await the result of the suggestion request
    final (_, futureSuggestionResult) = result;
    final suggestionResult = await futureSuggestionResult;

    // Check for errors and return suggestions if successful
    if (suggestionResult.error != null) {
      print("Error getting suggestions: ${suggestionResult.error}");
      return [];
    }

    return suggestionResult.items ?? [];
  }

  static Future<String> getAddressByPoint(Point point) async {
    try {
      final searchSession = await YandexSearch.searchByPoint(
        point: point,
        searchOptions: SearchOptions(searchType: SearchType.geo),
      );

      final searchResult = await searchSession.$2;
      if (searchResult.error != null) {
        print('Error searching by point: ${searchResult.error}');
        return 'Address not found';
      }

      final items = searchResult.items;
      if (items != null && items.isNotEmpty) {
        final firstItem = items.first;
        final toponymMetadata = firstItem.toponymMetadata;
        if (toponymMetadata != null) {
          return toponymMetadata.address.formattedAddress;
        } else {
          return 'Address not found';
        }
      } else {
        return 'Address not found';
      }
    } catch (e) {
      print('Exception while searching by point: $e');
      return 'Address not found';
    }
  }
}
