import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:proyectocatalogo/models/product_model.dart';

//Este es el proveedor de estado que gestiona toda la lógica de negocio relacionada con los productos.
// Se encarga de obtener los productos de la API, gestionar el carrito de compras y las cantidades de los productos.
// También se encarga de guardar los productos en la lista de productos y de gestionar el estado de carga.
// Este proveedor se utiliza en toda la aplicación para acceder a los productos y al carrito de compras.
class ProductProviders extends ChangeNotifier {
  bool isLoading = false;

  List<ProductModel> products = [];
  List<ProductModel> cartProducts = [];
  Map<int, int> productQuantities = {}; // productId -> quantity

  String getBaseUrl() {
    return 'https://fakestoreapi.com';
  }

// Este método se encarga de obtener los productos de la API y almacenarlos en la lista de productos.
  Future<void> fetchProducts() async {
    isLoading = true;
    notifyListeners();

    final url = Uri.parse('${getBaseUrl()}/products');

    print("Fetch Products");
    try {
      print("Trying");

      final response = await http.get(url);

      print("response status ${response.statusCode}");
      print("respuesta ${response.body}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        products = List<ProductModel>.from(
          data.map((product) => ProductModel.fromJSON(product)),
        );
      } else {
        products = [];
      }
    } catch (e) {
      print("Error in request $e");
      products = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

// Maneja el estado del carrito para añadir/quitar productos.
  Future<void> toggleCartStatus(ProductModel product) async {
    final isInCart = cartProducts.any((item) => item.id == product.id);

    try {
      if (isInCart) {
        cartProducts.removeWhere((item) => item.id == product.id);
        productQuantities.remove(product.id);
      } else {
        cartProducts.add(product);
        productQuantities[product.id] = 1; // Default quantity is 1
      }
      
      print("Estatus del Carrito cambiado");
      print(cartProducts.length);

      notifyListeners();
    } catch (e) {
      print("Error al actualizar carrito $e");
      notifyListeners();
    }
  }

// Proporciona updateQuantity() para cambiar la cantidad de un producto en el carrito.
  void updateQuantity(int productId, int quantity) {
    if (quantity < 1) quantity = 1;
    productQuantities[productId] = quantity;
    notifyListeners();
  }

// Proporciona getCartTotal() para calcular el total del carrito.
  double getCartTotal() {
    double total = 0;
    for (var product in cartProducts) {
      total += product.price * (productQuantities[product.id] ?? 1);
    }
    return total;
  }

  void clearCart() {
    cartProducts.clear();
    productQuantities.clear();
    notifyListeners();
  }

  bool isProductInCart(int productId) {
    return cartProducts.any((product) => product.id == productId);
  }

  int getQuantity(int productId) {
    return productQuantities[productId] ?? 1;
  }

  // Este método se encarga de guardar un nuevo producto en la lista de productos.
  Future<bool> saveProduct(ProductModel product) async {
    try {
      print('Guardar: longitud de productos : ${products.length}');
      products.add(product);
      print('products length: ${products.length}');

      notifyListeners();
      return true;
    } catch (e) {
      print('Error guardando producto: $e');
      return false;
    }
  }
}