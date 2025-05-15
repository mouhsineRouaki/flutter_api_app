import 'package:flutter/material.dart';
import '../models/book.dart';
import '/DataBases/Database.dart';


class DetailBookPage extends StatefulWidget {
  final Book book;

  const DetailBookPage({
    super.key, 
    required this.book,
  });

  @override
  _DetailBookPageState createState() => _DetailBookPageState();
}

class _DetailBookPageState extends State<DetailBookPage> {

  DatabaseFavorite db = DatabaseFavorite();
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }
  
  Future<void> _checkIfFavorite() async {
    final result = await db.isFavorite(widget.book.title);
    setState(() {
      isFavorite = result;
    });
  }
  
  Future<void> _toggleFavorite() async {
    if (isFavorite) {
      await db.deleteFavoriteByBookId(widget.book.title);
    } else {
      final bookData = {
        'title': widget.book.title,
        'author': widget.book.authors.join(', '),
        'coverId': widget.book.coverUrl,
        'year': widget.book.firstPublishYear.toString(),
        'key': widget.book.keyAuthor.first.toString(),
      };
      await db.insertBook(bookData);
    }
    
    setState(() {
      isFavorite = !isFavorite;
    });
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite 
            ? 'Ajouté aux favoris' 
            : 'Retiré des favoris'
        ),
        duration: const Duration(seconds: 1),
      )
    );
  }
  
  Widget _buildBookCover() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;
    final isTablet = screenWidth > 600 && screenWidth <= 1024;
    
    final coverHeight = isDesktop ? 400.0 : (isTablet ? 300.0 : 200.0);
    final coverWidth = isDesktop ? 280.0 : (isTablet ? 210.0 : 140.0);
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      height: coverHeight,
      width: coverWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: widget.book.coverUrl.isNotEmpty
            ? Image.network(
                widget.book.coverUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildCoverPlaceholder(coverHeight, coverWidth);
                },
              )
            : _buildCoverPlaceholder(coverHeight, coverWidth),
      ),
    );
  }
  
  Widget _buildCoverPlaceholder(double height, double width) {
    return Container(
      height: height,
      width: width,
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book,
            size: width * 0.4,
            color: Colors.grey[500],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              widget.book.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookDetails() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.book.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          Text(
            'Par: ${widget.book.authors.join(", ")}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          
          Text(
            'Première publication: ${widget.book.firstPublishYear}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 24),
          
          Divider(color: Colors.grey[300], thickness: 1),
          const SizedBox(height: 24),
          
          const Text(
            'À propos du livre',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Ce livre fait partie de la collection OpenLibrary. Publié pour la première fois en ${widget.book.firstPublishYear}, '
            'il a été écrit par ${widget.book.authors.join(" et ")}. '
            'Pour plus d\'informations sur ce livre, vous pouvez consulter le site OpenLibrary.',
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: _toggleFavorite,
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
            label: Text(isFavorite ? 'Favori' : 'Ajouter aux favoris'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
            ),
          ),
        
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du livre'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body:SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(child: _buildBookCover()),
                  _buildBookDetails(),
                  _buildActionButtons(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Lire ce livre'),
              content: Text('Voulez-vous commencer à lire "${widget.book.title}" ?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Lecture commencée'),
                        duration: Duration(seconds: 2),
                      )
                    );
                  },
                  child: const Text('Lire'),
                ),
              ],
            ),
          );
        },
        label: const Text('Lire'),
        icon: const Icon(Icons.book_online),
      ),
    );
  }
}