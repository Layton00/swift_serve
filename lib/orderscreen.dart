import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'main.dart';
import 'thankyouscreen.dart';
import 'package:intl/intl.dart';
class OrderScreen extends StatefulWidget {
  final List<Map<String, dynamic>> order;

  const OrderScreen({Key? key, required this.order}) : super(key: key);

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> with TickerProviderStateMixin {
  int ordernumber = Random().nextInt(9000000) + 1000000;
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;
  late Animation<double> _animation1;
  late Animation<double> _animation2;
  late Animation<double> _animation3;
  late Timer _timer1;
  late Timer _timer2;
  late Timer _timer3;
  bool _showButton = false;

  @override
  void initState() {
    super.initState();

    // Initialize the AnimationControllers
    _controller1 = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    _controller2 = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    _controller3 = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    // Define the Tweens
    _animation1 = Tween<double>(begin: 0.0, end: 1.0).animate(_controller1);
    _animation2 = Tween<double>(begin: 0.0, end: 1.0).animate(_controller2);
    _animation3 = Tween<double>(begin: 0.0, end: 1.0).animate(_controller3);

    // Start the timers
    _timer1 = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_controller1.isCompleted) {
        _timer1.cancel();
        _controller2.forward();
      } else {
        _controller1.forward();
      }
    });

    _timer2 = Timer(const Duration(seconds: 5), () {
      _timer2 = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_controller2.isCompleted) {
          _timer2.cancel();
          _controller3.forward();
        } else {
          _controller2.forward();
        }
      });
    });

    _timer3 = Timer(const Duration(seconds: 10), () {
      _timer3 = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_controller3.isCompleted) {
          _timer3.cancel();
          setState(() {
            _showButton = true;
          });
        } else {
          _controller3.forward();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    _timer1.cancel();
    _timer2.cancel();
    _timer3.cancel();
    super.dispose();
  }

  void _resetOrder(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const ThankYouScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    double subtotal = widget.order.fold(0.0, (sum, item) => sum + double.parse(item['price']));
    double tax = subtotal * 0.10;
    double total = subtotal + tax;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove the back arrow button
        title: const Text('Thank you for placing your order!'),
        backgroundColor: Colors.lightGreen,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Order',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Column(
                      children: [
                        const Text('Prepping'),
                        Container(
                          width: 250, // Fixed width of 250 pixels
                          height: 24.0 * 2, // 200% taller
                          child: AnimatedBuilder(
                            animation: _animation1,
                            builder: (context, child) {
                              return LinearProgressIndicator(
                                value: _animation1.value,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.lightGreen),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10), // Separation between progress bars
                    Column(
                      children: [
                        const Text('Cooking'),
                        Container(
                          width: 250, // Fixed width of 250 pixels
                          height: 24.0 * 2, // 200% taller
                          child: AnimatedBuilder(
                            animation: _animation2,
                            builder: (context, child) {
                              return LinearProgressIndicator(
                                value: _animation2.value,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.lightGreen),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10), // Separation between progress bars
                    Column(
                      children: [
                        const Text('Finishing Touches'),
                        Container(
                          width: 250, // Fixed width of 250 pixels
                          height: 24.0 * 2, // 200% taller
                          child: AnimatedBuilder(
                            animation: _animation3,
                            builder: (context, child) {
                              return LinearProgressIndicator(
                                value: _animation3.value,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.lightGreen),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text('Order Number: ' + ordernumber.toString()),
            Text('Time: ${DateFormat('HH:mm').format(DateTime.now())}'),
            Text('Estimated Finish Time: ${DateFormat('HH:mm').format(DateTime.now().add(const Duration(minutes: 25)))}'),
            const Divider(thickness: 1, color: Colors.black),
            const SizedBox(height: 10),
            ...widget.order.map((item) => Text('${item['name']} (\$${item['price']})')).toList(),
            const Spacer(),
            Container(
              color: Colors.amber[100],
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Subtotal: \$${subtotal.toStringAsFixed(2)}'),
                  Text('Tax: \$${tax.toStringAsFixed(2)}'),
                  Text('Total: \$${total.toStringAsFixed(2)}'),
                ],
              ),
            ),
            if (_showButton)
              Center(
                child: ElevatedButton(
                  onPressed: () => _resetOrder(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen,
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  ),
                  child: const Text(
                    'I got my order',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}