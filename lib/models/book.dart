class Book {
  final String title;
  final List<String> authors;
  final String coverId;
  final String firstPublishYear;
  final List<String> keyAuthor;

  Book({
    required this.title,
    required this.authors,
    required this.coverId,
    required this.firstPublishYear,
     required this.keyAuthor,
  });
  
  String get coverUrl {
    if(coverId.isNotEmpty){
      return 'https://covers.openlibrary.org/b/id/$coverId-M.jpg';
    }else{
      return " ";
    }
  }
  
  String get mainAuthor {
    if(authors.isNotEmpty){
      return authors.first ;
    }else{
      return 'Unknown Author';
    }
  }
  String get mainkeyAuthor {
    if(keyAuthor.isNotEmpty){
      return keyAuthor.first ;
    }else{
      return 'Unknown key';
    }
  }
}