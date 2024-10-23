import 'package:flutter/material.dart';

class ScoreCard extends StatelessWidget {
  ScoreCard(
      {super.key, required this.total, required this.text});

  final String text;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 18),
      child: Text(
        'WINNINGS: \$$total'.toUpperCase(),
        style: Theme.of(context)
            .textTheme
            .titleLarge!
            .copyWith(color: Colors.white),
      ),
    );
  }
}
