import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:yene_farm/models/user_model.dart';
import 'package:yene_farm/models/product_model.dart';
import 'package:yene_farm/models/order_model.dart';
import 'package:yene_farm/utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String _baseUrl = AppConstants.baseUrl;
  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // Authentication APIs
  Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/login'),
        headers: _headers,
        body: jsonEncode({
          'phone': phone,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> register(UserModel user, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/register'),
        headers: _headers,
        body: jsonEncode({
          ...user.toJson(),
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Registration failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Product APIs
  Future<List<ProductModel>> getProducts({String? category, String? search}) async {
    try {
      String url = '$_baseUrl/api/products';
      if (category != null && category != 'All') {
        url += '?category=$category';
      }
      if (search != null && search.isNotEmpty) {
        url += '${url.contains('?') ? '&' : '?'}search=$search';
      }

      final response = await http.get(Uri.parse(url), headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => ProductModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<ProductModel> addProduct(ProductModel product) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/products'),
        headers: _headers,
        body: jsonEncode(product.toJson()),
      );

      if (response.statusCode == 201) {
        return ProductModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to add product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Order APIs
  Future<List<OrderModel>> getOrders() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/orders'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => OrderModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<OrderModel> createOrder(OrderModel order) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/orders'),
        headers: _headers,
        body: jsonEncode(order.toJson()),
      );

      if (response.statusCode == 201) {
        return OrderModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create order: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Payment APIs
  Future<Map<String, dynamic>> initiatePayment(double amount, String phone, String method) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/payments/initiate'),
        headers: _headers,
        body: jsonEncode({
          'amount': amount,
          'phone': phone,
          'method': method,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Payment initiation failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Chat APIs
  Future<List<dynamic>> getChatHistory(String receiverId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/chat/$receiverId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load chat history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> sendMessage(String receiverId, String message) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/chat/send'),
        headers: _headers,
        body: jsonEncode({
          'receiverId': receiverId,
          'message': message,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Utility method for handling errors
  String getErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return 'An unexpected error occurred';
  }
}