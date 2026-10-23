import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final IconData icon;
  final String description;
  final double startingPrice;
  final int providerCount;
  final Color themeColor;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.startingPrice,
    this.providerCount = 0,
    this.themeColor = Colors.blue,
  });

  static List<CategoryModel> get mockCategories => [
        CategoryModel(
          id: 'cat_electrician',
          name: 'Electrician',
          icon: Icons.electrical_services,
          description: 'Wiring, switches, fan installation, fuse repairs & more',
          startingPrice: 199.0,
          providerCount: 24,
          themeColor: Colors.amber.shade700,
        ),
        CategoryModel(
          id: 'cat_plumber',
          name: 'Plumbing',
          icon: Icons.plumbing,
          description: 'Taps, leakage, bathroom fittings & pipe installations',
          startingPrice: 249.0,
          providerCount: 18,
          themeColor: Colors.blue.shade600,
        ),
        CategoryModel(
          id: 'cat_cleaning',
          name: 'Home Cleaning',
          icon: Icons.cleaning_services,
          description: 'Deep home cleaning, kitchen & bathroom sanitization',
          startingPrice: 499.0,
          providerCount: 30,
          themeColor: Colors.teal.shade600,
        ),
        CategoryModel(
          id: 'cat_ac',
          name: 'AC Repair',
          icon: Icons.ac_unit,
          description: 'AC servicing, gas charging, filter cleaning & installation',
          startingPrice: 399.0,
          providerCount: 15,
          themeColor: Colors.cyan.shade700,
        ),
        CategoryModel(
          id: 'cat_carpentry',
          name: 'Carpentry',
          icon: Icons.carpenter,
          description: 'Furniture repairs, lock changes, modular wardrobe fitting',
          startingPrice: 299.0,
          providerCount: 12,
          themeColor: Colors.brown.shade600,
        ),
        CategoryModel(
          id: 'cat_painting',
          name: 'Painting',
          icon: Icons.format_paint,
          description: 'Interior & exterior wall painting, waterproof coating',
          startingPrice: 799.0,
          providerCount: 9,
          themeColor: Colors.deepPurple.shade600,
        ),
        CategoryModel(
          id: 'cat_appliance',
          name: 'Appliance Repair',
          icon: Icons.kitchen,
          description: 'Refrigerator, washing machine, microwave & TV repair',
          startingPrice: 349.0,
          providerCount: 20,
          themeColor: Colors.orange.shade700,
        ),
        CategoryModel(
          id: 'cat_pest',
          name: 'Pest Control',
          icon: Icons.pest_control,
          description: 'Cockroach, termite, bed bug & rodent treatment',
          startingPrice: 599.0,
          providerCount: 11,
          themeColor: Colors.green.shade700,
        ),
      ];
}
