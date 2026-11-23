import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'project.g.dart';

@JsonSerializable()
class Project {
  @JsonKey(defaultValue: 'Untitled Project')
  final String title;
  @JsonKey(defaultValue: 'No description')
  final String description;
  @JsonKey(defaultValue: 'Lainnya')
  final String category;
  @JsonKey(defaultValue: <String>[])
  final List<String> technologies;
  @JsonKey(defaultValue: '')
  final String link;
  @JsonKey(name: 'icon', defaultValue: 'lightbulb_outline')
  final String iconName;
  @JsonKey(includeIfNull: false)
  final String? id;

  const Project(
    this.title,
    this.description, {
    this.category = 'Lainnya',
    this.technologies = const [],
    this.link = '',
    this.iconName = 'lightbulb_outline',
    this.id,
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

  Map<String, dynamic> toJson() => _$ProjectToJson(this);

  /// Payload accepted by the Django PortfolioItem API (Tutorial 07 schema).
  Map<String, dynamic> toApiJson() => {
    'title': title,
    'description': description,
    'category': category,
    'tech_stack': technologies.join(', '),
    'project_url': link,
  };

  factory Project.fromJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    if (normalized['technologies'] == null &&
        normalized['tech_stack'] is String) {
      normalized['technologies'] = (normalized['tech_stack'] as String)
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    if (normalized['link'] == null)
      normalized['link'] = normalized['project_url'];
    normalized['id'] = normalized['id']?.toString();
    return _$ProjectFromJson(normalized);
  }
}
