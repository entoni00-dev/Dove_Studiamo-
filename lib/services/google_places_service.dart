import 'dart:convert';
import 'package:http/http.dart' as http;

class GooglePlacesService {
  static const String _apiKey = 'AIzaSyC9E6527is_I_-o2CqdmhP03E7pVLIkpNo';

  Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json'
      '?place_id=$placeId'
      '&fields=rating,user_ratings_total'
      '&key=$_apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      return null;
    }

    final data = jsonDecode(response.body);

    if (data['status'] != 'OK') {
      return null;
    }

    return data['result'];
  }
}
