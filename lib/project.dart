import 'package:flutter/material.dart';

class Project {
  final String title;
  final String description;
  final String category;
  final List<String> technologies;
  final String link;
  final String iconName;

  const Project(
    this.title,
    this.description, {
    this.category = 'Lainnya',
    this.technologies = const [],
    this.link = '',
    this.iconName = 'lightbulb_outline',
  });

  IconData get icon {
    const map = <String, IconData>{
      'language': Icons.language,
      'phone_android': Icons.phone_android,
      'sports_esports': Icons.sports_esports,
      'smart_display': Icons.smart_display,
      'mic': Icons.mic,
      'calculate': Icons.calculate,
      'lightbulb_outline': Icons.lightbulb_outline,
      'code': Icons.code,
      'rocket_launch': Icons.rocket_launch,
      'design_services': Icons.design_services,
      'book': Icons.book,
      'terminal': Icons.terminal,
    };
    return map[iconName] ?? Icons.lightbulb_outline;
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'category': category,
    'technologies': technologies,
    'link': link,
    'icon': iconName,
  };

  factory Project.fromJson(Map<String, dynamic> json) => Project(
    json['title'] as String? ?? 'Untitled Project',
    json['description'] as String? ?? 'No description',
    category: json['category'] as String? ?? 'Lainnya',
    technologies:
        (json['technologies'] as List<dynamic>?)?.cast<String>() ?? const [],
    link: json['link'] as String? ?? '',
    iconName: json['icon'] as String? ?? 'lightbulb_outline',
  );
}
