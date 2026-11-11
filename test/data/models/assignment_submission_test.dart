import 'package:flutter_test/flutter_test.dart';
import 'package:skoolstar_teacher_module/data/models/parent/assignment_submission.dart';

void main() {
  group('SubmissionRules.fileError', () {
    test('accepts every allowed type, any case', () {
      for (final ext in SubmissionRules.allowedExtensions) {
        expect(SubmissionRules.fileError('work.$ext', 10), isNull, reason: ext);
      }
      expect(SubmissionRules.fileError('SCAN.JPG', 10), isNull);
    });

    test('refuses other types, no extension and dot-only names', () {
      expect(
        SubmissionRules.fileError('movie.mp4', 10),
        'movie.mp4 is not a supported file type.',
      );
      expect(SubmissionRules.fileError('README', 10), isNotNull);
      expect(SubmissionRules.fileError('archive.', 10), isNotNull);
      expect(SubmissionRules.fileError('virus.exe.txt.exe', 10), isNotNull);
    });

    test('size: empty and over 15 MB are refused, exactly 15 MB passes', () {
      expect(SubmissionRules.fileError('a.pdf', 0), 'a.pdf is empty.');
      expect(
        SubmissionRules.fileError('a.pdf', SubmissionRules.maxFileBytes),
        isNull,
      );
      expect(
        SubmissionRules.fileError('a.pdf', SubmissionRules.maxFileBytes + 1),
        'a.pdf is larger than 15 MB.',
      );
    });

    test('knows images', () {
      expect(SubmissionRules.isImage('p.PNG'), isTrue);
      expect(SubmissionRules.isImage('p.pdf'), isFalse);
    });
  });

  group('SubmissionRules.normalizeLink', () {
    test('keeps http(s) links and adds https to bare addresses', () {
      expect(
        SubmissionRules.normalizeLink(' https://example.com/a?b=1 '),
        'https://example.com/a?b=1',
      );
      expect(
        SubmissionRules.normalizeLink('http://example.com'),
        'http://example.com',
      );
      expect(
        SubmissionRules.normalizeLink('docs.google.com/doc/1'),
        'https://docs.google.com/doc/1',
      );
    });

    test('rejects anything that is not a web address', () {
      for (final bad in [
        '',
        '   ',
        'hello',
        'two words.com',
        'ftp://example.com',
        'javascript:alert(1)',
        'https://',
        'https://nodot',
        '://example.com',
      ]) {
        expect(SubmissionRules.normalizeLink(bad), isNull, reason: bad);
      }
    });

    test('rejects absurdly long text', () {
      expect(
        SubmissionRules.normalizeLink(
          'https://a.com/${'x' * SubmissionRules.maxLinkLength}',
        ),
        isNull,
      );
    });

    test('localhost is allowed for development', () {
      expect(
        SubmissionRules.normalizeLink('http://localhost:3000/x'),
        'http://localhost:3000/x',
      );
    });
  });
}
