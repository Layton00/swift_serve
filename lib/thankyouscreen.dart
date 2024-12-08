import 'package:flutter/material.dart';
import 'main.dart';

class ThankYouScreen extends StatelessWidget {
  const ThankYouScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thank You'),
        backgroundColor: Colors.lightGreen,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Thank you for ordering!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MenuScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                backgroundColor: Colors.lightGreen,
              ),
              child: const Text(
                'Order again',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButton<int>(
              hint: const Text('Rate this restaurant'),
              items: List.generate(5, (index) => index + 1)
                  .map((rating) => DropdownMenuItem<int>(
                        value: rating,
                        child: Text('$rating star${rating > 1 ? 's' : ''}'),
                      ))
                  .toList(),
              onChanged: (rating) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('You rated $rating star${rating! > 1 ? 's' : ''}'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}