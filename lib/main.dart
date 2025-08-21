import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyectocatalogo/providers/product_providers.dart';
import 'package:proyectocatalogo/providers/recipe_providers.dart';
import 'package:proyectocatalogo/screens/cart_screen.dart';
import 'package:proyectocatalogo/screens/favorites_screen.dart';
import 'package:proyectocatalogo/screens/home_screen.dart';
import 'package:proyectocatalogo/screens/products_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ProductProviders())],
      child: MaterialApp(
        title: 'Catalogo de productos',
        home: EcommerceCatalog(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

// *Pantalla principal con pestañas (catálogo y carrito)

// *Utiliza [DefaultTabController] para manejar dos pestañas:
// * - Productos: muestra la lista de productos disponibles.
// * - Carrito: muestra los productos agregados al carrito.
// * El AppBar incluye un contador de productos en el carrito y permite navegar entre pestañas.
class EcommerceCatalog extends StatelessWidget {
  const EcommerceCatalog({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DefaultTabController(
      length: 2, // *Número de pestañas
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: colors.primary,
          title: Text("E-Shop Catalogo", style: TextStyle(color: Colors.white)),
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: <Widget>[
              Tab(icon: Icon(Icons.shopping_bag), text: 'Productos'),
              Tab(icon: Icon(Icons.shopping_cart), text: 'Carrito'),
            ],
          ),
          actions: [
            // *Icono de carrito con contador de productos
            Consumer<ProductProviders>(
              builder: (context, provider, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.shopping_cart, color: Colors.white),
                      onPressed: () {
                        // *Cambia a la pestaña de carrito al presionar el icono
                        DefaultTabController.of(context).animateTo(1);
                      },
                    ),
                    // *Muestra el contador solo si hay productos en el carrito
                    if (provider.cartProducts.isNotEmpty)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${provider.cartProducts.length}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
        // *Contenido de las pestañas
        body: TabBarView(children: [ProductsScreen(), CartScreen()]),
      ),
    );
  }
}
