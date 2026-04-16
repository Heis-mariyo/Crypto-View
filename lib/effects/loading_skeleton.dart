import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget _buildLoadingSkeleton() {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade900,
    highlightColor: Colors.grey.shade800,
    child: ListView.builder(
      itemCount: 8,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const CircleAvatar(backgroundColor: Colors.white),
          title: Container(
            height: 12.0,
            width: 100.0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.0),
            ),
          ),
          subtitle: Container(
            margin: const EdgeInsets.only(top: 8.0),
            height: 10.0,
            width: 60.0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.0),
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(height: 12.0, width: 60.0, color: Colors.white),
              const SizedBox(height: 8.0),
              Container(height: 10.0, width: 40.0, color: Colors.white),
            ],
          ),
        );
      },
    ),
  );
}