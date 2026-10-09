/// The API has no colours for classes/subjects, so assign one deterministically
/// from the id: the same class/subject always gets the same colour.
const _palette = <String>[
  '#2563EB',
  '#8B5CF6',
  '#14B8A6',
  '#F97316',
  '#EC4899',
  '#06B6D4',
  '#6366F1',
  '#10B981',
];

String colorHexFor(int id) => _palette[id.abs() % _palette.length];
