import 'package:flutter/material.dart';
import '/models/book.dart';
import '/services/book_api_service.dart';
import '/screens/detailsBookPage.dart';

class BookSearchPage extends StatefulWidget {
  final BookApiService bookService = BookApiService();

  BookSearchPage({super.key});

  @override
  _BookSearchPageState createState() => _BookSearchPageState();
}

class _BookSearchPageState extends State<BookSearchPage> {
  final _controller = TextEditingController();
  Future<List<Book>>? _searchResults;

  void _startSearch() {
    final query = _controller.text.trim();
    if (query.isEmpty) return;
    setState(() {
      _searchResults = widget.bookService.searchBooks(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Recherche de livres"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _controller,
              onSubmitted: (_) => _startSearch(),
              decoration: InputDecoration(
                labelText: "Rechercher...",
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _startSearch,
                ),
              ),
            ),
          ),
          Expanded(
            child: _searchResults == null
                ? Center(child: Text("Entrez un terme de recherche"))
                : FutureBuilder<List<Book>>(
                    future: _searchResults,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text("Erreur: ${snapshot.error}"));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text("Aucun résultat."));
                      }

                      final books = snapshot.data!;
                      return GridView.builder(
                            padding: EdgeInsets.all(8),
                            itemCount: books.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, 
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.7,
                            ),
                            itemBuilder: (context, index) {
                              final book = books[index];
                              return GestureDetector(
                                onTap: () => Navigator.push(context,MaterialPageRoute(builder: (_) => DetailBookPage(book: book)),
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
                                            )
                                          : Container(
                                              height: 150,
                                              color: Colors.grey[300],
                                              child: Icon(Icons.book, size: 50),
                                            ),
                                      Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              book.title,
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              book.authors.join(', '),
                                              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              "Année: ${book.firstPublishYear}",
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }
          }
