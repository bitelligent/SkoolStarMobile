import 'package:flutter_test/flutter_test.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child.dart';

void main() {
  String short(String className) =>
      Child(id: '1', name: 'A', className: className).classShort;

  test('drops a leading "Class"', () {
    expect(short('Class 2'), '2');
    expect(short('class 10'), '10');
    expect(short('CLASS 7'), '7');
    expect(short('  Class 3  '), '3');
    expect(short('Class 4B'), '4B');
  });

  test('keeps names that do not start with "Class"', () {
    expect(short('Nursery'), 'Nursery');
    expect(short('Grade 5'), 'Grade 5');
    expect(short('Classroom 1'), 'Classroom 1'); // not the word "Class"
    expect(short('Prep'), 'Prep');
  });

  test('never produces an empty label from a non-empty class', () {
    expect(short('Class'), 'Class');
    expect(short('Class '), 'Class');
    expect(short(''), '');
  });
}
