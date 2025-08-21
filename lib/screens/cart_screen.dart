import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyectocatalogo/models/product_model.dart';
import 'package:proyectocatalogo/providers/product_providers.dart';

//Esta pantalla controla el carrito de compras y el proceso de pago.
/*
 * Muestra un mensaje cuando el carrito está vacío.
 * Utiliza ListView.builder para mostrar los productos en el carrito.
 * Cada producto en el carrito se muestra con una tarjeta que incluye:
 *  - Imagen, título y precio
 *  - Controles para ajustar la cantidad
 *  - Botón para eliminar del carrito
 * Incluye un resumen del carrito en la parte inferior que muestra:
 * - Total de la compra
 * - Botón de pago (checkout)
 * Implementa un diálogo de confirmación para finalizar la compra.
 */
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<ProductProviders>(
        builder: (context, productProviders, child) {
          final cartProducts = productProviders.cartProducts;

          // *Si el carrito está vacío, muestra un mensaje
          // *y un icono de carrito vacío
          if (cartProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 100,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Tu carrito está vacío",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Encuentra productos para añadir a tu carrito",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          // *Si hay productos, muestra la lista de productos
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartProducts.length,
                  itemBuilder: (context, index) {
                    final product = cartProducts[index];
                    return CartProductCard(product: product);
                  },
                ),
              ),
              CartSummary(),
            ],
          );
        },
      ),
    );
  }
}

// *Tarjeta de producto dentro del carrito
// *Incluye controles para ajustar la cantidad y eliminar el producto del carrito
// *Muestra la imagen, título, precio, controles de cantidad y botón para eliminar el producto del carrito.
class CartProductCard extends StatelessWidget {
  final ProductModel product;
  const CartProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final productProviders = Provider.of<ProductProviders>(context);
    int quantity = productProviders.getQuantity(product.id);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // *Imagen del producto
              Container(
                width: 80,
                height: 80,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(product.image, fit: BoxFit.contain),
                ),
              ),
              SizedBox(width: 16),
              // *Detalles del producto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // *Título del producto
                    Text(
                      product.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    // *Precio del producto
                    Text(
                      "\$${product.price.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 16,
                        color: colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // *Controles de cantidad y botón de eliminar
              Column(
                children: [
                  Row(
                    children: [                      
                      // *Botón para disminuir la cantidad
                      IconButton(
                        icon: Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          productProviders.updateQuantity(
                            product.id,
                            quantity - 1,
                          );
                        },
                      ),
                      // *Cantidad del producto
                      Text(
                        quantity.toString(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // *Botón para aumentar la cantidad
                      IconButton(
                        icon: Icon(Icons.add_circle_outline),
                        onPressed: () {
                          productProviders.updateQuantity(
                            product.id,
                            quantity + 1,
                          );
                        },
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      productProviders.toggleCartStatus(product);
                    },
                    child: Text("Quitar", style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// *Resumen del carrito 
// *Muestra el total de la compra y un botón para proceder al pago
class CartSummary extends StatelessWidget {
  const CartSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final productProviders = Provider.of<ProductProviders>(context);

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          // *Total de la compra
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "\$${productProviders.getCartTotal().toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          // *Botón de pago
          // *Muestra un diálogo de confirmación al hacer clic
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                _showCheckoutDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Checkout",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // *Diálogo de confirmación para proceder al pago
  void _showCheckoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Confirmar pago"),
            content: Text("Estas seguro de querer completar el pago?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel"),
              ),

              // *Botón para confirmar el pago
              ElevatedButton(
                onPressed: () {
                  final productProviders = Provider.of<ProductProviders>(
                    context,
                    listen: false,
                  );
                  productProviders.clearCart();
                  Navigator.pop(context);

                  // *Muestra un mensaje de éxito
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Compra completada exitosamente!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: Text("Confirmar", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }
}
