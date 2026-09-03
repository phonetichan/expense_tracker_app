import 'package:flutter/material.dart';

IconData getCategoryIcon(String icon) {
  switch (icon) {
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

    case 'category':
      return Icons.category;

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

    default:
      return Icons.category;
  }
}