import 'package:flutter/material.dart';

IconData getCategoryIcon(String icon) {
  switch (icon) {
    // --- Expenses ---
    case 'restaurant':
      return Icons.restaurant;
    case 'directions_car':
      return Icons.directions_car;
    case 'shopping_bag':
      return Icons.shopping_bag;
    case 'home':
      return Icons.home;
    case 'receipt':
      return Icons.receipt;
    case 'movie':
      return Icons.movie;
    case 'health_and_safety':
      return Icons.health_and_safety;
    case 'school':
      return Icons.school;
    case 'flight':
      return Icons.flight;
    case 'person':
      return Icons.person;
    case 'pets':
      return Icons.pets;
    case 'work':
      return Icons.work;
    case 'fitness_center':
      return Icons.fitness_center;
    case 'local_cafe':
      return Icons.local_cafe;
    case 'build':
      return Icons.build;
    case 'checkroom':
      return Icons.checkroom;
    case 'sports_esports':
      return Icons.sports_esports;
    case 'inventory_2':
      return Icons.inventory_2;

    // --- Income ---
    case 'payments':
      return Icons.payments;
    case 'computer':
      return Icons.computer;
    case 'business':
      return Icons.business;
    case 'trending_up':
      return Icons.trending_up;
    case 'card_giftcard':
      return Icons.card_giftcard;
    case 'savings':
      return Icons.savings;

    // --- Default ---
    case 'category':
      return Icons.category;
    default:
      return Icons.category;
  }
}