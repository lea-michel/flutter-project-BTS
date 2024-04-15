import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../main.dart';
import '../models/product.dart';
import 'dart:async';


//fonctions pour vérifier input
extension ExtString on String {
  bool get isValidImage{
    final imageRegExp = RegExp(r"^[a-zA-Z0-9]+\.[a-zA-Z]+");
    return imageRegExp.hasMatch(this);
  }

  // bool get isValidPhone{
  //   final phoneRegExp = RegExp(r"^\+?0[0-9]{10}$");
  //   return phoneRegExp.hasMatch(this);
  // }

  bool get isValidQuantity{
    final quantityRegExp = RegExp(r"^[0-9]");
    return quantityRegExp.hasMatch(this);
  }


}


class ProductsPage extends StatefulWidget {
  const ProductsPage ({super.key});


  @override
  State<ProductsPage> createState() => _ProductsPageState();

}

class _ProductsPageState extends State<ProductsPage>{
  late Future<List<Product>> products;
  final productListKey = GlobalKey<_ProductsPageState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final imageController = TextEditingController();
  final priceController = TextEditingController();
  final categoryController = TextEditingController();


  // function to fetch all products from database
  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/products'));
    if (response.statusCode==200){
      final items = json.decode(response.body).cast<Map<String,dynamic>>();
      List<Product> products = items.map<Product>((json){return Product.fromJson(json);}).toList();
      return products;
    }else{
      throw Exception('Failed to load products');
    }
  }

//function to edit a product
  Future<void> updateProduct(Product product) async{
    final newName = nameController.text;
    final newDescription = descriptionController.text;
    final newImage = imageController.text;
    final newPrice = priceController.text;
    final newCategory = categoryController.text;



    final response = await http.put(
      Uri.parse("http://10.0.2.2:3000/products/${product.productId}"),
      headers:<String,String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body:jsonEncode(<String,dynamic>{
        'name' : newName,
        'description' : newDescription,
        'image' : newImage,
        'price' : newPrice.toString(),
        'categoryId': newCategory.toString(),

      }),
    );
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      //return Product.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      throw Exception('Successful update');

    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to update product.');
    }

  }
  //function to create a new product
  void createProduct({
    required String name,
    required String description,
    required String image,
    required double price,
    required int category,
    required int quantity}) async{


      final response = await http.post(
        Uri.parse("http://10.0.2.2:3000/products"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'name': name,
          'description': description,
          'image': image,
          'price': price.toString(),
          'quantity': quantity.toString(),
          'categoryId': category.toString(),

        }),
      );

      if (response.statusCode == 201) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        fetchProducts();
        throw Exception('Successful creation');


      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        throw Exception('Failed to create product.');
      }


  }
  //end function create product


  //function to delete a product
  Future<Product> deleteProduct(Product product) async {
    final http.Response response = await http.delete(
      Uri.parse("http://10.0.2.2:3000/products/${product.productId}"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON
      return Product.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      // If the server did not return a "200 OK response",
      // then throw an exception.
      throw Exception('Failed to delete product.');
    }


  }
  //function fetch individual product API
  Future<Product> fetchProduct(Product product) async {
    //const $_baseUrl= 'http://10.0.2.2:3000';
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/products/${product.productId}'));

    if (response.statusCode == 200) {
      // Decode the JSON response body
      dynamic responseBody = jsonDecode(response.body);

      // If the response is a list, extract the first item and convert it to a map
      // This assumes that the API returns a single product for the given product ID
      if (responseBody is List) {
        responseBody = responseBody.first;
      }

      // Check if the response body is now a map
      if (responseBody is Map<String, dynamic>) {
        // If it's a map, convert it to a Product object
        return Product.fromJson(responseBody);
      } else {
        // If it's neither a list nor a map, throw an error
        throw Exception('Unexpected response format');
      }
    }

    else{
      throw Exception('Failed to load product');
    }
  }


  //function edit modal
  _updateModal(Product product) async{
    nameController.text = product.name.toString();
    descriptionController.text =  product.description.toString();
    priceController.text = product.price.toString();
    imageController.text = product.image.toString();
    categoryController.text = product.categoryId.toString();

    await showDialog(
      context:context,
      builder: (BuildContext context){
        return AlertDialog(
          title: const Text('Modifier le produit'),
          content:  Form(
          //key: _formKey,
           child: SingleChildScrollView(
            child:Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding : const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child : TextFormField(
                    decoration: const InputDecoration(
                      labelText:'Nom',
                    ),
                    controller: nameController,

                  ),
                ),
                Padding(
                  padding : const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child:TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: "Description",
                    ),
                    keyboardType: TextInputType.text,


                  ),
                ),
                Padding(
                  padding : const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child:TextFormField(
                    controller: imageController,
                    decoration: const InputDecoration(
                      labelText: "Image",
                    ),
                    keyboardType: TextInputType.text,


                  ),
                ),
                Padding(
                  padding : const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child:TextFormField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: "Prix",
                    ),
                    keyboardType: TextInputType.number,


                  ),
                ),
                Padding(
                  padding : const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child:TextFormField(
                    controller: categoryController,
                    decoration: const InputDecoration(
                      labelText: "Catégorie",
                    ),
                    keyboardType: TextInputType.text,


                  ),
                ),
          ],
        ),),),
          actions: [
            ElevatedButton(
              onPressed: (){
                Navigator.of(context).pop();
              },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.redAccent, // text color

                ),
              child: const Text('Annuler')
            ),
            ElevatedButton(
                onPressed: ()  {
                  updateProduct(product);
                  setState(() {
                    // Marquer l'état comme modifié pour déclencher un réexamen du widget
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Produit mis à jour avec succès'),
                    ));
                    products = fetchProducts();
                  });
                  Navigator.of(context).pop();
                },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.lightGreen, // text color

              ),

                child: const Text('Valider'),

            ),
          ],
        );
      },
    );
}


//function delete modal
  _deleteModal(Product product) async{

    await showDialog(
      context:context,
      builder: (BuildContext context){
        return AlertDialog(
          title: const Text('Supprimer le produit'),
          content: const Text ('Etes-vous sûr(e) de vouloir supprimer définitivement ce produit ?'),
          actions: [
            ElevatedButton(
                onPressed: (){
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white, // text color

                ),
                child: Text('Annuler')
            ),
            ElevatedButton(
              onPressed: ()  {
                deleteProduct(product);
                setState(() {
                  // Marquer l'état comme modifié pour déclencher un réexamen du widget
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Produit supprimé avec succès'),
                  ));
                  products = fetchProducts();
                });
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.redAccent, // text color

              ),

              child: Text('Supprimer'),

            ),
          ],
        );
      },
    );
  }

  //function show individual product
  _showModal(Product product) async{

    late Future<Product> futureProduct = fetchProduct(product) ;


    await showDialog(
      context:context,
      builder: (BuildContext context){
        return AlertDialog(
          //title: const Text('Produit'),
          content: FutureBuilder<Product>(
              future: futureProduct,
              builder: (BuildContext context,AsyncSnapshot snapshot){
                if (snapshot.hasData){
                  var data = snapshot.data;
                  return  SingleChildScrollView(
                      child : Column(
                          mainAxisSize: MainAxisSize.min,
                          children:<Widget>[
                            Image.asset(
                              'assets/images/${data.image}',
                              width: 150,
                            ),
                            Text(data.name.toUpperCase()),
                            Text(data.description),
                            Text("${data.price.toStringAsFixed(2)} €"),
                            Text("Catégorie : ${data.categoryId.toString()}"),
                            Text("Quantité : ${data.quantity.toString()}"),
                          ],

                    ),);
                  }
                else if (snapshot.hasError){
                  return Text('${snapshot.error}');
              }

              // By default, show a loading spinner.
                return const CircularProgressIndicator();
            },),

          actions: [
            ElevatedButton(
                onPressed: (){
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white, // text color

                ),
                child: Text('Fermer')
            ),

          ],
        );
      },
    );
  }



  @override
  void initState() {
    super.initState();
    products = fetchProducts();

  }

//visual part - list of all products
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: productListKey,
        appBar: AppBar(
          title: const Text('Produits'),
        ),
        drawer: const NavDrawer(),
        body: Container(
          margin: const EdgeInsets.only(bottom:36),
          child : Center(
          child:FutureBuilder<List<Product>>(
            future: products,
            builder: (BuildContext context,AsyncSnapshot snapshot){
              if (snapshot.hasData){
                return ListView.builder (
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index){
                    var data = snapshot.data[index];

                    return Card (
                      child: ListTile(
                        leading: Image.asset('assets/images/${data.image}',height:90,width:90),
                        trailing: Wrap(
                          spacing :-12,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_red_eye),
                              color: Colors.lightGreen,
                              onPressed: (){
                                _showModal(data);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              color: Colors.black,
                              onPressed: (){
                                _updateModal(data);

                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              color: Colors.redAccent,
                              onPressed: (){
                                _deleteModal(data);

                              },
                            ),

                          ],
                        ),

                        title:Text(data.name.toUpperCase(),
                            style: const TextStyle(fontSize: 18),
                          ),
                      subtitle: Text(
                        "${data.price.toStringAsFixed(2)} €",
                        style:const TextStyle(fontSize: 15),
                      ),

                      /*onTap: (){
                          Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context)=>Details(product:data)),
                          ); //push
                    },//onTap*/

                      ),
                    );

                  },

                );

              }else if (snapshot.hasError){
                return Text('${snapshot.error}');
              }
              return const CircularProgressIndicator();
            },
          )

          ),
    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const CreateProductPage();
          }));
        },

        child: const Icon(Icons.add),
      ),

    );

  }
}

//page de création d'un produit
class CreateProductPage extends StatefulWidget {
  const CreateProductPage({super.key});





  @override
  State<CreateProductPage> createState() => _CreateProductPageState();
  }

  class _CreateProductPageState extends State<CreateProductPage>{

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final _formKey = GlobalKey<FormState>();





  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Création d\'un nouveau produit'),
    ),
    body: SafeArea(
      top : false,
      bottom:false,
      child: Form(
  //mainAxisAlignment : MainAxisAlignment.center,
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child:Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                  padding : const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child : TextFormField(
                  decoration: const InputDecoration(
                  labelText:'Nom du produit',
                  ),
                  controller: nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom de produit';
                    }
                    return null;
                  },
                  ),
                  ),
                  Padding(
                  padding : const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child:TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                  labelText: "Description",
                  ),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description';
                    }
                    return null;
                  },

                  ),
                  ),
                  Padding(
                  padding : const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child:TextFormField(
                  controller: imageController,
                  decoration: const InputDecoration(
                  labelText: "Image",
                  ),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty || !value.isValidImage) {
                    return 'Veuillez entrer le chemin d\'une image valide';
                    }
                    return null;
                  },

                  ),
                  ),
                  Padding(
                  padding : const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child:TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(
                  labelText: "Prix",
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un prix';
                    }
                    return null;
                  },

                  ),
                  ),
                  Padding(
                    padding : const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child:TextFormField(
                      controller: quantityController,
                      decoration: const InputDecoration(
                        labelText: "Quantité",
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty || !value.isValidQuantity) {
                          return 'Veuillez entrer une quantité valide';
                        }
                        return null;
                      },

                    ),
                  ),

                  Padding(
                  padding : const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child:TextFormField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                  labelText: "Catégorie",
                  ),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une catégorie';
                    }
                    return null;
                  },

                  ),
                  ),

                  Padding(
                  padding : const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {

                      // Récupérer les valeurs des contrôleurs
                      String name = nameController.text;
                      String description = descriptionController.text;
                      String image = imageController.text;
                      double price = double.parse(priceController.text);
                      int category = int.parse(categoryController.text);
                      int quantity = int.parse(quantityController.text);
                      //appel de la fonction createProduct
                      _ProductsPageState().createProduct(
                        name: name,
                        description: description,
                        image: image,
                        price: price,
                        category: category,
                        quantity: quantity,
                      );

                      setState(()  {
                        // Marquer l'état comme modifié pour déclencher un réexamen du widget
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Nouveau produit ajouté avec succès'),
                            ));


                      });

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProductsPage()),
                      );

                    }},
                  child: const Text("Valider"),
                  ),

                  )

                ],
          ),
          ],
          ),

          ),


          ),
          ),

    );
  }
  }





