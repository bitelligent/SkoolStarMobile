import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skoolstar_teacher_module/core/network/api_exception.dart';
import 'package:skoolstar_teacher_module/core/utils/attachment_picker.dart';
import 'package:skoolstar_teacher_module/data/models/parent/assignment_submission.dart';
import 'package:skoolstar_teacher_module/features/parent/assignments/hand_in/hand_in_cubit.dart';

import 'hand_in_fakes.dart';

void main() {
  late FakeSubmissionRepo repo;
  late FakePicker picker;
  late HandInCubit cubit;

  setUp(() {
    repo = FakeSubmissionRepo();
    picker = FakePicker();
    cubit = HandInCubit(
      repository: repo,
      picker: picker,
      childId: '42',
      taskId: '90',
    );
  });

  tearDown(() => cubit.close());

  group('choosing files', () {
    test('adds valid files and ignores a repeat of the same file', () async {
      picker.files = [file('a.pdf'), file('b.jpg')];
      await cubit.pickFiles();
      expect(cubit.state.files.map((f) => f.source.name), ['a.pdf', 'b.jpg']);
      expect(cubit.state.error, isNull);

      picker.files = [file('a.pdf'), file('c.png')]; // a.pdf again
      await cubit.pickFiles();
      expect(cubit.state.files.map((f) => f.source.name), [
        'a.pdf',
        'b.jpg',
        'c.png',
      ]);
    });

    test('same name but different size is a different file', () async {
      picker.files = [file('scan.jpg', size: 10), file('scan.jpg', size: 20)];
      await cubit.pickFiles();
      expect(cubit.state.files, hasLength(2));
    });

    test(
      'unsupported, empty and oversized files are refused with a reason',
      () async {
        picker.files = [
          file('ok.pdf'),
          file('movie.mp4'),
          file('empty.pdf', size: 0),
          file('huge.pdf', size: SubmissionRules.maxFileBytes + 1),
        ];
        await cubit.pickFiles();
        expect(cubit.state.files.map((f) => f.source.name), ['ok.pdf']);
        expect(cubit.state.error, contains('movie.mp4 is not a supported'));
        expect(cubit.state.error, contains('empty.pdf is empty'));
        expect(cubit.state.error, contains('huge.pdf is larger than 15 MB'));
      },
    );

    test(
      'never more than five files; the rest are refused with a message',
      () async {
        picker.files = [for (var i = 0; i < 8; i++) file('f$i.pdf')];
        await cubit.pickFiles();
        expect(cubit.state.files, hasLength(5));
        expect(cubit.state.error, 'Only 5 files can be attached.');
        expect(cubit.state.canAddFile, isFalse);
      },
    );

    test(
      'with five files, choosing again does not even open the picker',
      () async {
        picker.files = [for (var i = 0; i < 5; i++) file('f$i.pdf')];
        await cubit.pickFiles();
        picker.photos = [file('late.jpg')];
        await cubit.pickPhotos();
        expect(picker.lastPhotoMax, isNull);
        expect(cubit.state.files, hasLength(5));
        expect(cubit.state.error, 'You can attach up to 5 files.');
      },
    );

    test('photos are limited to the room that is left', () async {
      picker.files = [file('a.pdf'), file('b.pdf')];
      await cubit.pickFiles();
      picker.photos = [file('p1.jpg')];
      await cubit.pickPhotos();
      expect(picker.lastPhotoMax, 3);
      expect(cubit.state.files, hasLength(3));
    });

    test(
      'camera photo is added; cancelling the camera changes nothing',
      () async {
        picker.camera = file('photo-1.jpg');
        await cubit.takePhoto();
        expect(cubit.state.files.single.source.name, 'photo-1.jpg');

        picker.camera = null;
        await cubit.takePhoto();
        expect(cubit.state.files, hasLength(1));
        expect(cubit.state.error, isNull);
      },
    );

    test('cancelling the file browser changes nothing', () async {
      picker.files = [];
      await cubit.pickFiles();
      expect(cubit.state.files, isEmpty);
      expect(cubit.state.error, isNull);
    });

    test('camera or permission problems are explained', () async {
      picker.error = const AttachmentPickException(
        'Allow camera access in Settings to take a photo.',
      );
      await cubit.takePhoto();
      expect(
        cubit.state.error,
        'Allow camera access in Settings to take a photo.',
      );
    });

    test('an unexpected picker failure never crashes', () async {
      picker.error = PlatformException(code: 'boom');
      await cubit.pickFiles();
      expect(cubit.state.error, 'Something went wrong. Please try again.');
    });

    test('a file can be removed and the error goes away', () async {
      picker.files = [file('a.pdf'), file('movie.mp4')];
      await cubit.pickFiles();
      expect(cubit.state.error, isNotNull);
      cubit.removeFile(cubit.state.files.single.id);
      expect(cubit.state.files, isEmpty);
      expect(cubit.state.error, isNull);
    });
  });

  group('links', () {
    test('are cleaned up, de-duplicated and limited', () {
      expect(cubit.addLink('example.com/a'), isNull);
      expect(cubit.state.links, ['https://example.com/a']);

      expect(
        cubit.addLink('HTTPS://EXAMPLE.COM/A'),
        'That link is already added.',
      );
      expect(cubit.addLink('not a link'), 'Enter a valid web address.');
      expect(cubit.addLink(''), 'Enter a valid web address.');

      for (var i = 1; i < SubmissionRules.maxLinks; i++) {
        expect(cubit.addLink('site$i.com'), isNull);
      }
      expect(cubit.addLink('one-more.com'), 'You can add up to 5 links.');
      expect(cubit.state.links, hasLength(5));

      cubit.removeLink('https://example.com/a');
      expect(cubit.state.links, hasLength(4));
      expect(cubit.addLink('one-more.com'), isNull);
    });
  });

  group('handing in', () {
    test(
      'uploads every file in order, then submits once with their urls',
      () async {
        picker.files = [file('a.pdf'), file('b.jpg')];
        await cubit.pickFiles();
        cubit.setNote('  Finished all five  ');
        cubit.addLink('example.com/x');

        await cubit.submit();

        expect(repo.uploads, ['a.pdf', 'b.jpg']);
        expect(repo.submits, hasLength(1));
        final s = repo.submits.single;
        expect(s.childId, '42');
        expect(s.taskId, '90');
        expect(s.note, '  Finished all five  '); // trimmed by the repository
        expect(s.links, ['https://example.com/x']);
        expect(s.fileUrls, ['/uploads/a.pdf', '/uploads/b.jpg']);
        expect(cubit.state.done, isTrue);
        expect(cubit.state.completedAt, repo.completedAt);
        expect(cubit.state.busy, isFalse);
        expect(cubit.state.error, isNull);
      },
    );

    test('a bare hand-in (nothing added) is allowed', () async {
      expect(cubit.state.isBlank, isTrue);
      await cubit.submit();
      expect(repo.uploads, isEmpty);
      expect(repo.submits.single.fileUrls, isEmpty);
      expect(cubit.state.done, isTrue);
    });

    test('while sending, state says busy and nothing can be edited', () async {
      picker.files = [file('a.pdf')];
      await cubit.pickFiles();
      repo.gate = Completer<void>();
      final sending = cubit.submit();
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.busy, isTrue);
      expect(cubit.state.progressLabel, 'Uploading 1 of 1…');

      cubit
        ..setNote('changed')
        ..removeFile(cubit.state.files.single.id)
        ..removeLink('x');
      expect(cubit.addLink('late.com'), isNull);
      await cubit.pickFiles();
      expect(cubit.state.files, hasLength(1));
      expect(cubit.state.note, '');
      expect(cubit.state.links, isEmpty);

      repo.gate!.complete();
      await sending;
      expect(cubit.state.done, isTrue);
    });

    test('a double tap sends once', () async {
      picker.files = [file('a.pdf')];
      await cubit.pickFiles();
      repo.gate = Completer<void>();
      final first = cubit.submit();
      final second = cubit.submit();
      repo.gate!.complete();
      await Future.wait([first, second]);
      expect(repo.uploads, ['a.pdf']);
      expect(repo.submits, hasLength(1));
    });

    test('submitting again after it went in does nothing', () async {
      await cubit.submit();
      await cubit.submit();
      expect(repo.submits, hasLength(1));
    });

    test(
      'if a file fails, nothing is submitted and the file is marked',
      () async {
        picker.files = [file('a.pdf'), file('b.pdf'), file('c.pdf')];
        await cubit.pickFiles();
        repo.uploadErrors['b.pdf'] = const NetworkException();

        await cubit.submit();

        expect(repo.uploads, ['a.pdf', 'b.pdf']); // c.pdf never attempted
        expect(repo.submits, isEmpty);
        expect(cubit.state.done, isFalse);
        expect(cubit.state.busy, isFalse);
        expect(cubit.state.error, contains("Couldn't upload b.pdf"));
        expect(cubit.state.error, contains('Nothing was handed in.'));
        final byName = {for (final f in cubit.state.files) f.source.name: f};
        expect(byName['a.pdf']!.status, UploadStatus.uploaded);
        expect(byName['b.pdf']!.status, UploadStatus.failed);
        expect(byName['b.pdf']!.error, const NetworkException().message);
        expect(byName['c.pdf']!.status, UploadStatus.waiting);
      },
    );

    test('retrying uploads only what is still missing', () async {
      picker.files = [file('a.pdf'), file('b.pdf')];
      await cubit.pickFiles();
      repo.uploadErrors['b.pdf'] = const NetworkException();
      await cubit.submit();
      expect(repo.uploads, ['a.pdf', 'b.pdf']);

      repo.uploadErrors.clear();
      await cubit.submit();
      expect(repo.uploads, ['a.pdf', 'b.pdf', 'b.pdf']); // a.pdf not again
      expect(repo.submits.single.fileUrls, [
        '/uploads/a.pdf',
        '/uploads/b.pdf',
      ]);
      expect(cubit.state.done, isTrue);
    });

    test('a failed file can be removed, then the rest goes in', () async {
      picker.files = [file('a.pdf'), file('bad.pdf')];
      await cubit.pickFiles();
      repo.uploadErrors['bad.pdf'] = const ValidationException(
        'Unsupported file type (.pdf).',
      );
      await cubit.submit();
      cubit.removeFile(cubit.state.files.last.id);
      await cubit.submit();
      expect(repo.submits.single.fileUrls, ['/uploads/a.pdf']);
    });

    test('a file that cannot be read is reported, not thrown', () async {
      picker.files = [file('a.pdf', readFails: true)];
      await cubit.pickFiles();
      await cubit.submit();
      expect(cubit.state.error, contains("couldn't be read"));
      expect(repo.uploads, isEmpty);
      expect(repo.submits, isEmpty);
    });

    test(
      'the server refusing the submit shows its message and keeps the work',
      () async {
        picker.files = [file('a.pdf')];
        await cubit.pickFiles();
        cubit.setNote('hello');
        repo.submitError = const ValidationException(
          'This assignment is not assigned to you.',
          statusCode: 400,
        );
        await cubit.submit();
        expect(cubit.state.error, 'This assignment is not assigned to you.');
        expect(cubit.state.done, isFalse);
        expect(cubit.state.busy, isFalse);
        expect(cubit.state.note, 'hello');

        // Retry: the file is already stored, so it is not uploaded again.
        repo.submitError = null;
        await cubit.submit();
        expect(repo.uploads, ['a.pdf']);
        expect(cubit.state.done, isTrue);
      },
    );

    test(
      'an unexpected exception ends in a message, never a stuck spinner',
      () async {
        repo.submitError = StateError('boom');
        await cubit.submit();
        expect(cubit.state.busy, isFalse);
        expect(cubit.state.error, 'Something went wrong. Please try again.');
      },
    );

    test('expired session / no permission have readable messages', () async {
      repo.submitError = const ForbiddenException();
      await cubit.submit();
      expect(cubit.state.error, const ForbiddenException().message);
    });

    test('closing the screen mid-upload does not throw', () async {
      picker.files = [file('a.pdf')];
      await cubit.pickFiles();
      repo.gate = Completer<void>();
      final sending = cubit.submit();
      await cubit.close();
      repo.gate!.complete();
      await sending; // late result is dropped
    });
  });
}
