import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyectocatalogo/models/product_model.dart';
import 'package:proyectocatalogo/providers/product_providers.dart';

//Esta pantalla muestra información detallada sobre un producto específico.
/*
 * Recibe un objeto ProductModel como parámetro.
 * Muestra la imagen del producto, título, precio, calificación, categoría y descripción.
 * Incluye un botón para añadir/quitar el producto del carrito.
 * Actualiza la interfaz cuando el estado del producto en el carrito cambia.
 * Utiliza un diseño limpio con separaciones lógicas entre los elementos.
 */
class ProductDetails extends StatefulWidget {
  final ProductModel product;

  const ProductDetails({super.key, required this.product});

  @override
  ProductDetailsState createState() => ProductDetailsState();
}

class ProductDetailsState extends State<ProductDetails> {
  bool isInCart = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isInCart = Provider.of<ProductProviders>(
      context,
      listen: false,
    ).isProductInCart(widget.product.id);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.primary,
        title: Text(
          widget.product.title,
          style: TextStyle(color: Colors.white),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        leading: IconButton(
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //* Imagen del producto centrada
              Center(
                child: Container(
                  height: 200,
                  padding: EdgeInsets.all(16),
                  child: Image.network(
                    widget.product.image,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: 20),

              //* Título del producto
              Text(
                widget.product.title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
              SizedBox(height: 8),

              // *Precio y calificación
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "\$${widget.product.price.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  Row(
                    children: [
                      Text("Rating: ", style: TextStyle(fontSize: 16)),

                      //* Estrellas llenas según la calificación
                      ...List.generate(
                        widget.product.rating,
                        (index) =>
                            Icon(Icons.star, color: Colors.amber, size: 18),
                      ),

                      //* Estrellas vacías para completar 5
                      ...List.generate(
                        5 - widget.product.rating,
                        (index) => Icon(
                          Icons.star_border,
                          color: Colors.amber,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8),

              // *Categoría del producto
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.product.category,
                  style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 16),

              //* Separador visual
              Container(
                width: double.infinity,
                height: 1,
                color: Colors.grey[300],
              ),
              SizedBox(height: 16),

              // *Descripción del producto
              Text(
                "Descripción:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                widget.product.description,
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              SizedBox(height: 30),

              // *Botón para añadir/quitar del carrito
              // *Cambia de color según el estado del producto en el carrito
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    // *Cambia el estado del producto en el carrito

                    await Provider.of<ProductProviders>(
                      context,
                      listen: false,
                    ).toggleCartStatus(widget.product);
                    setState(() {
                      isInCart = !isInCart;
                    });

                    // *Muestra un mensaje de confirmación
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isInCart ? 'Añadido al carrito' : 'Eliminado del carrito',
                        ),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  
                  // *Cambia el color del botón según el estado
                  // *del producto en el carrito
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isInCart ? Colors.grey : colors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  // *Texto del botón
                  child: Text(
                    isInCart ? "Eliminar del carrito" : "Añadir al carrito",
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
        ),
      ),
    );
  }
}
