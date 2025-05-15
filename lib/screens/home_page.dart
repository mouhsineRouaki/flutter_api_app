import 'package:flutter/material.dart';
import '/models/book.dart';
import '/services/book_api_service.dart';
import '/widgets/book_card.dart';
import '/screens/SearchPage.dart';
import '/screens/favoritesPage.dart';
import '/screens/author_book.dart';
import '/models/author.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final BookApiService _bookService = BookApiService();

  List<Book> topRatedBooks = [];
  List<Book> recommendedBooks = [];
  List<Book> latestBooks = [];
  List<Author> authors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);

    try {
      final topRated = await _bookService.fetchTopRatedBooks();
      final recommended = await _bookService.fetchRecommendedBooks();
      final latest = await _bookService.fetchLatestBooks();

      final allBooks = [...topRated, ...recommended, ...latest];
      final uniqueAuthors = <String, Author>{};

      for (var book in allBooks) {
        for (int i = 0; i < book.authors.length; i++) {
          final name = book.authors[i];
          final key = (i < book.keyAuthor.length) ? book.keyAuthor[i] : null;

          if (key != null && !uniqueAuthors.containsKey(key)) {
            uniqueAuthors[key] = Author(
              name: name,
              image: "https://covers.openlibrary.org/a/olid/$key.jpg",
            );
          }
        }
      }

      setState(() {
        topRatedBooks = topRated;
        recommendedBooks = recommended;
        latestBooks = latest;
        authors = uniqueAuthors.values.toList();
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching data: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Book App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => BookSearchPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => FavoritesPage()),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection('Auteurs', _buildAuthorList(authors)),
                    _buildSection('Top Rated Books', _buildBookList(topRatedBooks)),
                    _buildSection('Recommended Books', _buildBookList(recommendedBooks)),
                    _buildSection('Latest Books', _buildBookList(latestBooks)),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        content,
      ],
    );
  }

  Widget _buildBookList(List<Book> books) {
    return SizedBox(
      height: 240,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: books.length,
        itemBuilder: (_, index) => BookCard(book: books[index]),
      ),
    );
  }

  Widget _buildAuthorList(List<Author> authors) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: authors.length,
        itemBuilder: (_, index) {
          final author = authors[index];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AuthorBooksPage(
                  author: author,
                  bookService: _bookService,
                ),
              ),
            ),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipOval(
                    child: Image.network(
                      author.image,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 50),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    author.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
