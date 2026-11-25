import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/models/project.dart';

void main() {
  test('serializes the DRF field names without the server-assigned id', () {
    const project = Project(
      'Portfolio',
      'A personal portfolio.',
      category: 'Website',
      technologies: ['Flutter', 'Dart'],
      link: 'https://example.com',
      id: '42',
    );

    expect(project.toJson(), {
      'title': 'Portfolio',
      'description': 'A personal portfolio.',
      'category': 'Website',
      'tech_stack': 'Flutter, Dart',
      'project_url': 'https://example.com',
    });
  });

  test('deserializes DRF values and defaults omitted optional fields', () {
    final project = Project.fromJson({
      'id': 42,
      'title': 'Portfolio',
      'description': 'A personal portfolio.',
      'tech_stack': ' Flutter, Dart ',
    });

    expect(project.id, '42');
    expect(project.category, 'Lainnya');
    expect(project.technologies, ['Flutter', 'Dart']);
    expect(project.link, '');
    expect(project.iconName, 'lightbulb_outline');
  });
}
