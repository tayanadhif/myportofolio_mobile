import 'package:material_ui/material_ui.dart';
import 'package:json_annotation/json_annotation.dart';

part 'project.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Project {
  @JsonKey(defaultValue: 'Untitled Project')
  final String title;
  @JsonKey(defaultValue: 'No description')
  final String description;
  @JsonKey(defaultValue: 'Lainnya')
  final String category;
  @JsonKey(
    name: 'tech_stack',
    fromJson: _technologiesFromJson,
    toJson: _technologiesToJson,
  )
  final List<String> technologies;
  @JsonKey(name: 'project_url', defaultValue: '')
  final String link;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String iconName;
  @JsonKey(includeToJson: false)
  final String? id;

  const Project(
    this.title,
    this.description, {
    this.category = 'Lainnya',
    this.technologies = const <String>[],
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

  Map<String, dynamic> toApiJson() => toJson();

  factory Project.fromJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    if (!normalized.containsKey('tech_stack') &&
        normalized['technologies'] != null) {
      final technologies = normalized['technologies'];
      normalized['tech_stack'] = technologies is List
          ? technologies.join(', ')
          : technologies;
    }
    if (!normalized.containsKey('project_url') &&
        normalized.containsKey('link')) {
      normalized['project_url'] = normalized['link'];
    }
    normalized['id'] = normalized['id']?.toString();
    return _$ProjectFromJson(normalized);
  }
}

List<String> _technologiesFromJson(Object? value) {
  final technologies = value is String
      ? value.split(',')
      : value is List
      ? value.whereType<String>()
      : const <String>[];
  return technologies
      .map((technology) => technology.trim())
      .where((technology) => technology.isNotEmpty)
      .toList();
}

String _technologiesToJson(List<String> technologies) =>
    technologies.join(', ');
