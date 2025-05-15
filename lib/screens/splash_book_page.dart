import 'package:flutter/material.dart';
import 'dart:async';
import '/screens/home_page.dart';

class SplashBookPage extends StatefulWidget {
  const SplashBookPage({super.key});

  @override
  _SplashBookPageState createState() => _SplashBookPageState();
}

class _SplashBookPageState extends State<SplashBookPage> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height:150,
              width: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(child: Icon(Icons.menu_book,size: 70,color: Colors.blue)),),
            const SizedBox(height: 40),
            Text('My Book App',style: TextStyle(fontSize: 28,fontWeight: FontWeight.bold,color: Colors.blue.shade900,),),
            const SizedBox(height: 16),
            Text('Découvrez des milliers de livres',style: TextStyle(fontSize: 16,color: Colors.blue.shade800)),
            const SizedBox(height: 50),
            const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)),
          ],
        ),
      ),
    );
  }
}
