import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyectocatalogo/models/product_model.dart';
import 'package:proyectocatalogo/providers/product_providers.dart';

/*
 * Esta pantalla permite a los usuarios crear nuevos productos.
 * Formulario Validado: Utiliza Form y GlobalKey<FormState> para la validación de campos.
 * Controladores de Texto: Usa TextEditingController para cada campo del formulario.
 * Campos del Formulario:
 *  - Título del producto (obligatorio)
 *  - Descripción detallada (obligatorio)
 *  - Precio (obligatorio, validación numérica)
 *  - Categoría (obligatorio)
 *  - URL de imagen (obligatorio, validación básica de URL)
 * Selector de Calificación: Interfaz interactiva para seleccionar la calificación (1-5 estrellas).
 * Manejo de Estado: Muestra un indicador de progreso durante el proceso de guardado.
 * Validación: Verifica que todos los campos tengan datos válidos antes de enviar.
 * Gestión de Errores: Muestra mensajes de error si algo falla durante el proceso.
 * Retroalimentación: Proporciona notificaciones de éxito o fracaso al usuario.
* Navegación: Regresa a la pantalla anterior automáticamente tras guardar con éxito
*/
class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores para los campos del formulario
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  
  int _rating = 3; // Default rating
  bool _isLoading = false; // Estado de carga para mostrar el indicador de progreso

  @override
  void dispose() {
    // * Liberar los controladores al salir de la pantalla
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  // * Método para enviar el formulario
  void _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final productProvider = Provider.of<ProductProviders>(
        context, 
        listen: false
      );

      try {
        // * Crear un nuevo producto con los datos del formulario
        final newProduct = ProductModel(
          id: DateTime.now().millisecondsSinceEpoch, // Generate unique ID
          title: _titleController.text,
          description: _descriptionController.text,
          price: double.parse(_priceController.text),
          category: _categoryController.text,
          image: _imageUrlController.text,
          rating: _rating,
        );

        // Guardar el nuevo producto
        final success = await productProvider.saveProduct(newProduct);

        if (!mounted) return;

        if (success) {
          // * Mostrar un mensaje de éxito
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Producto añadido exitosamente!'),
              backgroundColor: Colors.green,
            ),
          );
          // * Regresar a la pantalla anterior
          Navigator.pop(context);
        } else {
          // * Mostrar un mensaje de error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Falló al añadir el producto'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        // * Manejo de errores
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.primary,
        title: Text(
          'Add New Product',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          // * Indicador de carga mientras se guarda el producto
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // * Título del formulario
                    Text(
                      'Información del Producto',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                    SizedBox(height: 20),
                    
                    // *Campo: Titulo de Producto 
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Titulo del Producto',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese un título';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),
                    
                    // *Campo: Descripcion del Producto
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Descripcion',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese una descripción';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),
                    
                    // *Campo: Precio y Categoria
                    Row(
                      children: [
                        // *Campo: Precio
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            decoration: InputDecoration(
                              labelText: 'Precio',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.attach_money),
                            ),
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ingresar precio';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Ingresar un precio válido';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 15),
                        
                        // *Campo: Categoria
                        Expanded(
                          child: TextFormField(
                            controller: _categoryController,
                            decoration: InputDecoration(
                              labelText: 'Categoria',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.category),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ingresar categoria';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    
                    // *Campo: URL de Imagen
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: InputDecoration(
                        labelText: 'Image URL',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.image),
                        helperText: 'Ingrese una URL de imagen válida',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese una URL de imagen';
                        }
                        // Basic URL validation
                        if (!Uri.tryParse(value)!.isAbsolute) {
                          return 'Por favor ingrese una URL válida';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),
                    
                    // *Campo: Calificación
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rating: $_rating',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: List.generate(
                            5,
                            (index) => IconButton(
                              icon: Icon(
                                index < _rating ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                              ),
                              onPressed: () {
                                setState(() {
                                  _rating = index + 1;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    
                    // * Botón para añadir el producto
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => _submitForm(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Add Product',
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