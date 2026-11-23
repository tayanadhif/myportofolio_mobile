// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

Project _$ProjectFromJson(Map<String, dynamic> json) => Project(
  json['title'] as String? ?? 'Untitled Project',
  json['description'] as String? ?? 'No description',
  category: json['category'] as String? ?? 'Lainnya',
  technologies:
      (json['technologies'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  link: json['link'] as String? ?? '',
  iconName: json['icon'] as String? ?? 'lightbulb_outline',
  id: json['id'] as String?,
);

Map<String, dynamic> _$ProjectToJson(Project instance) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'category': instance.category,
  'technologies': instance.technologies,
  'link': instance.link,
  'icon': instance.iconName,
  if (instance.id != null) 'id': instance.id,
};
