import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(const CarFlashcardsApp());

class Car {
  final String name;
  final String image;
  final String fact;

  const Car(this.name, this.image, this.fact);
}

// Put the matching image files in assets/cars/.
const cars = [
  Car('Porsche 911', 'assets/cars/porsche_911.jpg', 'Made since 1964, always rear-engined.'),
  Car('Ford Mustang', 'assets/cars/ford_mustang.jpg', 'Launched in 1964 and started the "pony car" class.'),
  Car('Volkswagen Beetle', 'assets/cars/vw_beetle.jpg', 'Over 21 million of the original were built.'),
  Car('Lamborghini Countach', 'assets/cars/lamborghini_countach.jpg', 'Famous for its scissor doors.'),
  Car('Toyota Supra', 'assets/cars/toyota_supra.jpg', 'The MK4 is known for its 2JZ engine.'),
  Car('Tesla Model S', 'assets/cars/tesla_model_s.jpg', 'An all-electric sedan launched in 2012.'),
];

class CarFlashcardsApp extends StatelessWidget {
  const CarFlashcardsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guess the Car',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.red, useMaterial3: true),
      home: const FlashcardScreen(),
    );
  }
}

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  late List<Car> _deck = [...cars]..shuffle();
  int _index = 0;
  int _score = 0;
  bool _flipped = false;
  bool _answered = false;

  void _flip() => setState(() => _flipped = !_flipped);

  void _mark(bool correct) {
    if (_answered) return;
    setState(() {
      _answered = true;
      if (correct) _score++;
    });
  }

  void _next() {
    setState(() {
      _flipped = false;
      _answered = false;
      if (_index < _deck.length - 1) {
        _index++;
      } else {
        _showResult();
      }
    });
  }

  void _restart() {
    setState(() {
      _deck = [...cars]..shuffle();
      _index = 0;
      _score = 0;
      _flipped = false;
      _answered = false;
    });
  }

  void _showResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Deck finished!'),
        content: Text('You got $_score out of ${_deck.length} right.'),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _restart();
            },
            child: const Text('Play again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final car = _deck[_index];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guess the Car'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text('Score: $_score', style: const TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('Card ${_index + 1} of ${_deck.length}'),
            const SizedBox(height: 16),
            Expanded(
              child: GestureDetector(
                onTap: _flip,
                child: FlipCard(
                  flipped: _flipped,
                  front: _CardFront(car: car),
                  back: _CardBack(car: car),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (!_flipped)
              const Text('Tap the card to reveal the answer')
            else if (!_answered)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _mark(false),
                    icon: const Icon(Icons.close),
                    label: const Text('Got it wrong'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: () => _mark(true),
                    icon: const Icon(Icons.check),
                    label: const Text('Got it right'),
                  ),
                ],
              )
            else
              FilledButton(onPressed: _next, child: const Text('Next car')),
          ],
        ),
      ),
    );
  }
}

/// Flips between [front] and [back] with a 3D rotation around the Y axis.
class FlipCard extends StatelessWidget {
  final bool flipped;
  final Widget front;
  final Widget back;

  const FlipCard({super.key, required this.flipped, required this.front, required this.back});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: flipped ? pi : 0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      builder: (context, angle, _) {
        final showBack = angle > pi / 2;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // perspective
            ..rotateY(angle),
          child: showBack
              // Un-mirror the back side so its text reads correctly.
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(pi),
                  child: back,
                )
              : front,
        );
      },
    );
  }
}

class _CardShell extends StatelessWidget {
  final Widget child;
  final Color? color;

  const _CardShell({required this.child, this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      color: color,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox.expand(child: child),
    );
  }
}

class _CardFront extends StatelessWidget {
  final Car car;

  const _CardFront({required this.car});

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            car.image,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.directions_car, size: 120, color: Colors.grey),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              color: Colors.black54,
              padding: const EdgeInsets.all(12),
              child: const Text(
                'What car is this?',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  final Car car;

  const _CardBack({required this.car});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _CardShell(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              car.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(car.fact, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
