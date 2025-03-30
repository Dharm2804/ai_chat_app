import 'package:flutter/material.dart';
import 'pdf_viewer_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'login_signup_screen.dart';

class Book {
  final String name;
  final String author;
  final String publishDate;
  final String pdfPath;
  final String imagePath;

  Book(this.name, this.author, this.publishDate, this.pdfPath, this.imagePath);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Book> _books = [
    Book("Flutter for Beginners", "John Doe", "2022", "assets/books/book1.pdf", "assets/images/book1.jpg"),
    Book("Mastering Dart", "Jane Smith", "2021", "assets/books/book2.pdf", "assets/images/book2.jpg"),
    Book("Advanced Flutter", "Mike Johnson", "2023", "assets/books/book3.pdf", "assets/images/book3.jpg"),
    Book("Flutter Cookbook", "Alice Brown", "2020", "assets/books/book4.pdf", "assets/images/book4.jpg"),
    Book("Dart in Depth", "Charlie White", "2019", "assets/books/book5.pdf", "assets/images/book5.jpg"),
    Book("Flutter UI Design", "David Black", "2024", "assets/books/book6.pdf", "assets/images/book6.jpg"),
  ];

  bool _isGridView = false;

  void _logout() async {
  await FirebaseAuth.instance.signOut();
  await GoogleSignIn().signOut(); // Sign out from Google if used

  // Navigate to the login/signup screen and remove all previous screens from the stack
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const LoginSignupScreen()),
    (route) => false, // This removes all previous routes from the stack
  );
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: const Text(
          'E-Book Store',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view, color: Colors.white),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          IconButton(
  icon: const Icon(Icons.logout, color: Colors.white),
  onPressed: () => _logout(), // Explicitly passing context
),

        ],
      ),
      body: _isGridView ? _buildGridView() : _buildListView(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.shade900,
        onPressed: () {
          setState(() {
            _isGridView = !_isGridView;
          });
        },
        child: Icon(_isGridView ? Icons.list : Icons.grid_view, color: Colors.white),
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      itemCount: _books.length,
      itemBuilder: (context, index) {
        final book = _books[index];
        return Card(
          color: Colors.blue.shade100,
          margin: const EdgeInsets.all(8.0),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.asset(
                book.imagePath,
                width: 60,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 60),
              ),
            ),
            title: Text(
              book.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            subtitle: Text("Author: ${book.author}\nPublished: ${book.publishDate}", style: TextStyle(color: Colors.blue.shade700)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blue),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PdfViewerScreen(pdfAssetPath: book.pdfPath),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _books.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 0.7,
      ),
      itemBuilder: (context, index) {
        final book = _books[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PdfViewerScreen(pdfAssetPath: book.pdfPath),
              ),
            );
          },
          child: Card(
            color: Colors.blue.shade100,
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15.0)),
                    child: Image.asset(
                      book.imagePath,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 60),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    book.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
