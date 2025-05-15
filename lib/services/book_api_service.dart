import 'dart:convert';
import 'package:app_books/models/author.dart';

import '/models/book.dart';
import 'package:http/http.dart' as http;
import 'dart:async';


class BookApiService {

  static const String _baseUrl = 'https://openlibrary.org';
  
  Future<List<Book>> fetchTopRatedBooks() async {
    return _fetchBooks('$_baseUrl/search.json?q=book&sort=rating');
  }


  Future<List<Book>> searchBooks(String query) async {
    final url = '$_baseUrl/search.json?q=$query';
    return _fetchBooks(url);
  } 


  Future<List<Book>> fetchBooksByAuthor(Author author) async {
    return _fetchBooks('https://openlibrary.org/search.json?author=${author.name}');
  }

  Future<List<Book>> fetchRecommendedBooks() async {
    return _fetchBooks('$_baseUrl/search.json?q=popular&sort=editions');
  }


  Future<List<Book>> fetchLatestBooks() async {
    return _fetchBooks('$_baseUrl/search.json?q=book&sort=new');
  }

  
  Future<List<Book>> _fetchBooks(String url) async {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _addToList(data);
      } else {
        throw Exception('Failed to load books: ${response.statusCode}');
      }
  
  }
  
  List<Book> _addToList(Map<String, dynamic> data) {
    List<Book> books = [];
    List<dynamic> docs = data['docs'] ?? [];
    
    for (var doc in docs) {
      String title = doc['title'] ?? 'Unknown Title';
      List<String> authors = List<String>.from((doc['author_name'] ?? ['Unknown Author']));
      String coverId = doc['cover_i']?.toString() ?? '';
      String firstPublishYear = doc['first_publish_year']?.toString() ?? 'Unknown';
      List<String> authorKey = List<String>.from((doc['author_key'] ?? ['Unknown key']));
      
      books.add(Book(
        title: title,
        authors: authors,
        coverId: coverId,
        firstPublishYear: firstPublishYear,
        keyAuthor: authorKey
      ));
    }
    
    return books;
  }

}