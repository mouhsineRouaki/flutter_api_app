import 'package:flutter/material.dart';
import '/services/book_api_service.dart';
import '/models/book.dart';
import '/models/author.dart';
import '/screens/detailsBookPage.dart';

class AuthorBooksPage extends StatelessWidget {
  final Author author;
  final BookApiService bookService;

  const AuthorBooksPage({
    super.key,
    required this.author,
    required this.bookService,
  });

  Future<List<Book>> fetchBooksByAuthor() async {
    return await bookService.fetchBooksByAuthor(author);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Livres de ${author.name}'),
      ),
      body: FutureBuilder<List<Book>>(
        future: fetchBooksByAuthor(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Erreur de chargement'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun livre trouvé pour cet auteur.'));
          }

          final books = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              itemCount: books.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.7,
              ),
              itemBuilder: (context, index) {
                final book = books[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DetailBookPage(book: book)),
                  ),
                  child: Card(
                    elevation: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        book.coverId.isNotEmpty
                            ? Image.network(
                                "https://covers.openlibrary.org/b/id/${book.coverId}-M.jpg",
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50),
                              )
                            : Container(
                                height: 150,
                                color: Colors.grey[300],
                                child: const Icon(Icons.book, size: 50),
                              ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                book.title,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                book.authors.join(', '),
                                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                "Année: ${book.firstPublishYear}",
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
