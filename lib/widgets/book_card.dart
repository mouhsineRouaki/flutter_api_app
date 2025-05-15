import 'package:flutter/material.dart';
import '/models/book.dart';
import '/screens/detailsBookPage.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;

  const BookCard({
    super.key, 
    required this.book,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DetailBookPage(book: book)),
              );
            },
      child: Container(
        width: 140,
        margin:EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: book.coverUrl.isNotEmpty
                  ? Image.network(
                      book.coverUrl,
                      height: 160,
                      width: 140,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildCoverPlaceholder();
                      },
                    )
                  : _buildCoverPlaceholder(),
            ),
            const SizedBox(height: 8),
            Text(
              book.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              book.mainAuthor,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            Text(
              'Published: ${book.firstPublishYear}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCoverPlaceholder() {
    return Container(
      height: 160,
      width: 140,
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.book, size: 50, color: Colors.grey),
      ),
    );
  }
}