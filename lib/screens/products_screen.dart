import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyectocatalogo/models/product_model.dart';
import 'package:proyectocatalogo/providers/product_providers.dart';
import 'package:proyectocatalogo/screens/add_products_screen.dart';
import 'package:proyectocatalogo/screens/product_details.dart';

/*
 * Esta es la pantalla principal que muestra todos los productos disponibles.
 * Inicialización: Verifica si la lista de productos está vacía y, de ser así, realiza la carga desde la API.
 * Diseño de Grid: Utiliza GridView.builder para crear una cuadrícula de productos con 2 columnas.
 * Tarjeta de Producto: Cada producto se muestra en una tarjeta que incluye:
 *  - Imagen del producto en la parte superior
 *  - Título del producto (limitado a 2 líneas)
 *  - Precio con formato "$XX.XX"
 *  - Calificación visual con estrellas
 *  - Botón de añadir al carrito (que cambia de apariencia si el producto ya está en el carrito)
 * Navegación: Al tocar una tarjeta, navega a la pantalla de detalles del producto.
 * Añadir Producto: Incluye un botón flotante para crear nuevos productos.
 * Estado de Carga: Muestra un indicador de progreso mientras se cargan los productos.
 * Manejo de Errores: Proporciona retroalimentación visual si la imagen no se puede cargar.
*/

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productProviders = Provider.of<ProductProviders>(
      context,
      listen: false,
    );

    // *Si la lista de productos está vacía, se llama a la función para obtener los productos.
    if (productProviders.products.isEmpty) {
      productProviders.fetchProducts();
    }

    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Consumer<ProductProviders>(
        builder: (context, provider, child) {
          // *Si la lista de productos está vacía, se muestra un indicador de carga.
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (provider.products.isEmpty) {
            // *Si la lista de productos sigue vacía después de la carga, se muestra un mensaje.
            return Center(child: Text('Producto no disponible'));
          }

          // *Muestra las cards de productos
          return GridView.builder(
            padding: EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: provider.products.length,
            itemBuilder: (context, index) {
              return _productCard(context, provider.products[index]);
            },
          );
        },
      ),
      // *Botón flotante para añadir un nuevo producto
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProductScreen()),
          );
        },
        backgroundColor: colors.primary,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // *Tarjeta de producto
  Widget _productCard(BuildContext context, ProductModel product) {
    final colors = Theme.of(context).colorScheme;
    final productProvider = Provider.of<ProductProviders>(
      context,
      listen: false,
    );
    bool isInCart = productProvider.isProductInCart(product.id);

    return GestureDetector(
      onTap: () {
        // *Navega a la pantalla de detalles del producto
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetails(product: product),
          ),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // * Imagen del producto
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                  child: Image.network(
                    product.image,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(child: CircularProgressIndicator());
                    },
                    errorBuilder:
                        (context, error, stackTrace) => Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: Colors.grey,
                        ),
                  ),
                ),
              ),
            ),

            // *Info  del Producto 
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // *Título del producto
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  // *Precio del producto
                  Text(
                    "\$${product.price.toStringAsFixed(2)}",
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 6),
                  // *Calificación del producto
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < product.rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          ),
                        ),
                      ),
                      // *Botón de añadir al carrito
                      InkWell(
                        onTap: () {
                          productProvider.toggleCartStatus(product);
                        },
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color:
                                isInCart
                                    ? Colors.grey.shade300
                                    : colors.primaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            isInCart
                                ? Icons.shopping_cart
                                : Icons.add_shopping_cart,
                            size: 20,
                            color: isInCart ? Colors.black54 : colors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
