import 'package:flutter/material.dart';
import '../models/book.dart';
import '/dataBases/DataBase.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final DatabaseFavorite _databaseFavorite = DatabaseFavorite();
  List<Map<String, dynamic>> _favoriteBooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final favorites = await _databaseFavorite.getfavorite();
      setState(() {
        _favoriteBooks = favorites;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement des favoris: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFromFavorites(String title) async {
    await _databaseFavorite.deleteFavorite(title);
    _loadFavorites();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Livre retiré des favoris'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildBookItem(Map<String, dynamic> book) {
    final String title = book['title'];
    final String author = book['author'];
    final String coverUrl = book['coverUrl'] ?? '';
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: coverUrl.isNotEmpty
            ? Container(
                width: 50,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(coverUrl),
                    onError: (exception, stackTrace) => const AssetImage('assets/images/no_cover.png'),
                  ),
                ),
              )
            : Container(
                width: 50,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.grey[300],
                ),
                child: Icon(Icons.book, color: Colors.grey[700]),
              ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(author),
        trailing: IconButton(
          icon: const Icon(Icons.favorite, color: Colors.red),
          onPressed: () => _removeFromFavorites(title),
        ),
        onTap: () {
          final Book bookObj = Book(
            title: book['title'],
            authors: [book['author']],
            coverId: book['coverUrl'] ?? '',
            firstPublishYear: book['year'],
            keyAuthor: book['key']
            
          );
          
          Navigator.pushNamed(
            context, 
            '/book_details',
            arguments: bookObj,
          ).then((_) => _loadFavorites());
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes livres favoris'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteBooks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun livre favori',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Explorer des livres'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadFavorites,
                  child: ListView.builder(
                    itemCount: _favoriteBooks.length,
                    itemBuilder: (context, index) {
                      return _buildBookItem(_favoriteBooks[index]);
                    },
                  ),
                ),
    );
  }
}