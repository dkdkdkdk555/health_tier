import 'package:flutter/material.dart';

class FeedDetail extends StatelessWidget {
  final int feedId;
  const FeedDetail({
    super.key,
    required this.feedId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const SizedBox(
              width: 300,
              height: 300,
              child: Icon(
                Icons.arrow_back
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                '$feedId'
              ),
            ),
          )
        ],
      ),
    );
  }
}