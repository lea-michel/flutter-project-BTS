const mysql = require('mysql')
const express = require('express')
const app = express()
const port = 3000;
const bodyParser = require('body-parser')

//connexion à la base de données
const db = mysql.createConnection({
    'user': '',
    'password':'',
     'server': '',
     'database': '',
     'port' : ,
});
app.use(bodyParser.json())
app.use(express.json())
app.use(bodyParser.urlencoded({extended:true}))

app.listen(port,(err)=>{
    console.log('Server On')
});
db.connect(err => {
    if (err) throw err;
    console.log("Connecté à la base de données MySQL!");
     });

//test affichage des données dans le navigateur
app.get('/users', (req, res) => {
        db.query('SELECT * FROM users', (err,results)=>{
            if(err){
                throw err;
            }
            res.json(results);
        });
});

//login
app.post('/login', (req,res)=>{
    const { email, password} =req.body;
    const query = 'SELECT * FROM users WHERE email= ? AND password= ? AND isAdmin=1';
    db.query(query,[email,password],(err,results, fields)=>{
        if(err){
            console.error("Erreur lors de la requete SQL", err)
            return res.status(500).json({ message: 'Erreur interne du serveur' });
        }
        if(results.length>0){
           res.status(200).json({message: 'Admin connecté avec succès'});
        }else{
            return res.status(401).json({ message: 'Adresse e-mail, mot de passe ou statut d\'administrateur incorrect' });
        }

        });
});

//affichage des produits
app.get('/products', (req, res) => {
        db.query('SELECT * FROM products', (err,results)=>{
            if(err){
                throw err;
            }
            res.json(results);
        });
});

//affichage d'un produit
app.get('/products/:id', (req, res) => {
        const productId = req.params.id;
        const query = 'SELECT * FROM products WHERE id=?';
        db.query(query,[productId], (err,results)=>{
            if(err){
                throw err;
            }
            res.json(results);
        });
});


//update d'un produit
 app.put('/products/:id', (req,res)=>{
     const productId = req.params.id;
     const { name, description, image, price, categoryId} =req.body;
     const query = 'UPDATE products SET name=?, description=?, image=?, price=?, category_id=? WHERE id=?';
     db.query(query,[name,description, image, price, categoryId, productId],(err,results, fields)=>{
         if(err){
             console.error("Erreur lors de la requete SQL", err);
             return res.status(500).json({ message: 'Erreur interne du serveur' });
         }

         res.status(200).json({message: `Produit modifié avec l id : ${productId}` });

         });
 });

//insert d'un produit
app.post('/products', (req,res)=>{
     const { name, description, image, price,quantity, categoryId} =req.body;
     const query = 'INSERT INTO products (name, description, image, price, quantity, category_id) VALUES (?,?,?,?,?,?)';
     db.query(query,[name,description, image, price, quantity, categoryId],(err,results)=>{
         if(err){
             console.error("Erreur lors de la requete SQL", err)
             return res.status(500).json({ message: 'Erreur interne du serveur' });
         }

         res.status(201).json({message: 'Produit ajouté avec l\'id : ${results.rows[0]}'});


         });
 });

// delete un produit
app.delete('/products/:id', (req,res)=>{
     const productId = req.params.id;
     const query = 'DELETE FROM products WHERE id=?';
     db.query(query,[productId],(err,results)=>{
         if(err){
             console.error("Erreur lors de la requete SQL", err)
             return res.status(500).json({ message: 'Erreur interne du serveur' });
         }
         res.status(200).json({message: 'Produit supprimé avec l\'id : ${productId}'});


         });
 });

// affichage des produits avec quantité inférieure à 5
app.get('/stock', (req, res) => {
        db.query('SELECT * FROM products WHERE quantity<5', (err,results)=>{
            if(err){
                throw err;
            }
            res.json(results);
        });
});

//update quantité des produits
 app.put('/stock/update/:id', (req,res)=>{
     const productId = req.params.id;
     const quantity =req.body;
     const query = 'UPDATE products SET quantity=? WHERE id=?';
     db.query(query,[quantity, productId],(err,results, fields)=>{
         if(err){
             console.error("Erreur lors de la requete SQL", err);
             return res.status(500).json({ message: 'Erreur interne du serveur' });
         }

         res.status(200).json({message: ` Quantité du produit modifié avec l\'id : ${productId}` });

         });
 });
