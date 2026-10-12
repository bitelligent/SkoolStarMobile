import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:skoolstar_teacher_module/core/network/api_client.dart';
import 'package:skoolstar_teacher_module/core/network/api_exception.dart';
import 'package:skoolstar_teacher_module/data/models/class_group.dart';
import 'package:skoolstar_teacher_module/data/models/feedback_model.dart';
import 'package:skoolstar_teacher_module/data/models/homework_model.dart';
import 'package:skoolstar_teacher_module/data/models/session_model.dart';
import 'package:skoolstar_teacher_module/data/repositories/attendance_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/feedback_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/homework_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/session_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/teacher_catalog.dart';
import 'package:skoolstar_teacher_module/data/repositories/user_repository.dart';

import '../../fixtures/fixtures.dart' as fx;
import '../../helpers/fakes.dart';

ApiClient _api(MockClient mock) => ApiClient(
  baseUrl: 'https://api.test',
  httpClient: mock,
  timeout: const Duration(seconds: 2),
);

final _session = Session(
  id: 'pub-1',
  date: DateTime(2026, 10, 8),
  startTime: '15:24',
  endTime: '22:24',
  classIds: const ['23', '24'],
  subjectIds: const ['18'],
  teacherId: '3',
  occurrenceId: 1026,
  scheduleId: 1017,
);

const _classes = [
  ClassGroup(id: '23', name: 'Class 1'),
  ClassGroup(id: '24', name: 'Class 2'),
];

void main() {
  group('SessionRepository', () {
    late FakeAuthRepository auth;
    late List<http.Request> requests;
    late SessionRepositoryImpl repo;

    SessionRepositoryImpl build(
      FutureOr<http.Response> Function(http.Request) handler,
    ) {
      requests = [];
      return repo = SessionRepositoryImpl(
        apiClient: _api(
          MockClient((r) async {
            requests.add(r);
            return handler(r);
          }),
        ),
        authRepository: auth,
      );
    }

    setUp(() => auth = FakeAuthRepository());

    test(
      'requests the whole month for the staff and filters the range',
      () async {
        build((_) => jsonResponse(fx.occurrencesOctober));

        final out = await repo.getBetween(
          DateTime(2026, 10, 5),
          DateTime(2026, 10, 9),
        );

        expect(
          requests.single.url.path,
          '/api/Schedules/occurrences/teacher/3',
        );
        expect(requests.single.url.queryParameters, {
          'from': '2026-10-01',
          'to': '2026-10-31',
        });
        expect(out.map((s) => s.occurrenceId), [1026]); // 1019 is on Oct 1
      },
    );

    test(
      'caches months, de-duplicates concurrent calls and spans months',
      () async {
        build((_) => jsonResponse(fx.occurrencesOctober));

        await Future.wait([
          repo.getBetween(DateTime(2026, 10), DateTime(2026, 10, 31)),
          repo.getBetween(DateTime(2026, 10), DateTime(2026, 10, 31)),
        ]);
        await repo.getBetween(DateTime(2026, 10), DateTime(2026, 10, 31));
        expect(requests, hasLength(1));

        await repo.getBetween(DateTime(2026, 10), DateTime(2026, 11, 30));
        expect(requests, hasLength(2)); // only November was new
        expect(requests.last.url.queryParameters['from'], '2026-11-01');

        await repo.getBetween(
          DateTime(2026, 10),
          DateTime(2026, 10, 31),
          refresh: true,
        );
        expect(requests, hasLength(3));
      },
    );

    test('a failed month is not cached', () async {
      var fail = true;
      build((_) => fail ? http.Response('', 503) : jsonResponse([]));

      await expectLater(
        repo.getBetween(DateTime(2026, 10), DateTime(2026, 10, 31)),
        throwsA(isA<ServerException>()),
      );
      fail = false;
      expect(
        await repo.getBetween(DateTime(2026, 10), DateTime(2026, 10, 31)),
        isEmpty,
      );
    });

    test('cache is dropped on sign-out', () async {
      build((_) => jsonResponse(fx.occurrencesOctober));
      await repo.getBetween(DateTime(2026, 10), DateTime(2026, 10, 31));
      await auth.logout();
      await repo.getBetween(DateTime(2026, 10), DateTime(2026, 10, 31));
      expect(requests, hasLength(2));
    });

    test('getById uses cache, else the guid endpoint; 404 is null', () async {
      build((r) {
        if (r.url.path.endsWith('/missing')) return http.Response('', 404);
        return jsonResponse(fx.occurrencesOctober[1]);
      });

      final s = await repo.getById('473c2ebb-3344-4535-9df3-c99646450be7');
      expect(s?.occurrenceId, 1026);
      expect(
        requests.single.url.path,
        '/api/Schedules/occurrences/guid/473c2ebb-3344-4535-9df3-c99646450be7',
      );
      await repo.getById('473c2ebb-3344-4535-9df3-c99646450be7');
      expect(requests, hasLength(1));
      expect(await repo.getById('missing'), isNull);
    });
  });

  group('TeacherCatalogSource', () {
    test('loads once, shares in-flight call, retries after failure', () async {
      var calls = 0;
      var fail = true;
      final source = TeacherCatalogSource(
        apiClient: _api(
          MockClient((r) async {
            calls++;
            if (fail) return http.Response('', 500);
            if (r.url.path.contains('Schedules/teacher')) {
              return jsonResponse(fx.teacherSchedules);
            }
            if (r.url.path.endsWith('my-classes')) {
              return jsonResponse(fx.myClasses);
            }
            return jsonResponse(fx.myStudents);
          }),
        ),
        authRepository: FakeAuthRepository(),
      );

      await expectLater(source.load(), throwsA(isA<ServerException>()));
      fail = false;
      calls = 0;
      final results = await Future.wait([source.load(), source.load()]);
      expect(calls, 3); // one load = three endpoints
      expect(results.first.classes, hasLength(2));
      await source.load();
      expect(calls, 3);
    });
  });

  group('AttendanceRepository', () {
    test('merges classes, de-duplicates pupils, maps status ids', () async {
      final requests = <http.Request>[];
      final repo = AttendanceRepositoryImpl(
        _api(
          MockClient((r) async {
            requests.add(r);
            return jsonResponse(fx.attendanceForClass23);
          }),
        ),
      );

      final sheet = await repo.getSheet(_session, _classes);

      expect(requests, hasLength(2)); // one per class
      expect(
        requests.first.url.queryParameters['scheduleOccurrencePublicId'],
        'pub-1',
      );
      expect(requests.first.url.queryParameters['date'], '2026-10-08');
      expect(sheet.students, hasLength(2)); // unique pupils
      expect(sheet.statuses['2'], 'present');
      expect(sheet.statuses['3'], 'unmarked');
      // class resolved from the server's className, not the request class
      final irha = sheet.students.firstWhere((s) => s.id == '3');
      expect(irha.classGroupId, '24');
      expect(irha.firstName, 'Irha');
    });

    test(
      'submit sends only marked students; nothing marked sends nothing',
      () async {
        final requests = <http.Request>[];
        final repo = AttendanceRepositoryImpl(
          _api(
            MockClient((r) async {
              requests.add(r);
              return http.Response('', 200);
            }),
          ),
        );

        await repo.submit(_session, {'2': 'unmarked', '3': 'unmarked'});
        expect(requests, isEmpty);

        await repo.submit(_session, {
          '2': 'present',
          '3': 'unmarked',
        });
        final body = jsonDecode(requests.single.body) as Map<String, dynamic>;
        expect(requests.single.url.path, '/api/TeacherModule/attendance/mark');
        expect(body['scheduleOccurrencePublicId'], 'pub-1');
        expect(body['scheduleOccurrenceId'], 1026);
        expect(body['scheduleId'], 1017);
        expect(body['date'], '2026-10-08');
        expect(body['items'], [
          {'studentId': 2, 'statusId': 1},
        ]);
      },
    );

    test('server error is propagated', () async {
      final repo = AttendanceRepositoryImpl(
        _api(MockClient((_) async => http.Response('', 500))),
      );
      await expectLater(
        repo.submit(_session, {'2': 'present'}),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('HomeworkRepository', () {
    test('lists across classes without duplicates; empty is fine', () async {
      final repo = HomeworkRepositoryImpl(
        _api(
          MockClient(
            (r) async => r.url.path.endsWith('/23')
                ? jsonResponse([
                    {
                      'taskId': 1,
                      'title': 'A',
                      'deadline': '2026-10-09T10:00:00',
                    },
                  ])
                : jsonResponse([
                    {'taskId': 1, 'title': 'A'},
                    {
                      'taskId': 2,
                      'title': 'B',
                      'deadline': '2026-10-12T10:00:00',
                    },
                  ]),
          ),
        ),
      );
      final list = await repo.getForSession(_session);
      expect(list.map((h) => h.id), ['2', '1']); // latest deadline first

      final empty = HomeworkRepositoryImpl(
        _api(MockClient((_) async => jsonResponse([]))),
      );
      expect(await empty.getForSession(_session), isEmpty);
    });

    test(
      'create sends the documented body incl. uploaded references',
      () async {
        late http.Request req;
        final repo = HomeworkRepositoryImpl(
          _api(
            MockClient((r) async {
              req = r;
              return jsonResponse({'taskId': 55});
            }),
          ),
        );
        final created = await repo.create(
          _session.copyWith(sectionId: 7),
          Homework(
            id: '',
            sessionId: 'pub-1',
            classId: '23',
            subjectId: '18',
            title: ' Chapter 1 ',
            description: 'Read',
            deadline: DateTime(2026, 10, 20, 9),
            assignedStudentIds: const ['2', '3'],
            attachments: const [
              HomeworkAttachment(
                fileName: 'a.pdf',
                sizeKb: 1,
                type: 'pdf',
                reference: 'uploads/a.pdf',
              ),
              HomeworkAttachment(fileName: 'b.pdf', sizeKb: 1, type: 'pdf'),
            ],
          ),
        );

        final body = jsonDecode(req.body) as Map<String, dynamic>;
        expect(req.url.path, '/api/TeacherModule/homework');
        expect(body['title'], 'Chapter 1');
        expect(body['classId'], 23);
        expect(body['subjectId'], 18);
        expect(body['sectionId'], 7);
        expect(body['studentIds'], [2, 3]);
        expect(body['attachments'], ['uploads/a.pdf']); // not-uploaded skipped
        expect(body['scheduleOccurrencePublicId'], 'pub-1');
        expect(created.id, '55');
      },
    );

    test('create validation errors surface with field messages', () async {
      final repo = HomeworkRepositoryImpl(
        _api(
          MockClient(
            (_) async => jsonResponse({
              'errors': {
                'Title': ['Title is required'],
              },
            }, 400),
          ),
        ),
      );
      await expectLater(
        repo.create(
          _session,
          Homework(
            id: '',
            sessionId: 'pub-1',
            classId: '23',
            subjectId: '18',
            title: '',
            description: '',
            deadline: DateTime(2026, 10, 20),
          ),
        ),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            'Title is required',
          ),
        ),
      );
    });

    test('upload rejects oversized files before any request', () async {
      var called = false;
      final repo = HomeworkRepositoryImpl(
        _api(
          MockClient((_) async {
            called = true;
            return http.Response('', 200);
          }),
        ),
      );
      await expectLater(
        repo.uploadAttachment(
          fileName: 'big.zip',
          bytes: List.filled(maxAttachmentBytes + 1, 0),
        ),
        throwsA(isA<ValidationException>()),
      );
      expect(called, isFalse);
    });

    test(
      'upload returns the reference from string or object responses',
      () async {
        for (final body in <Object>[
          'uploads/x.pdf',
          {'url': 'uploads/x.pdf'},
          {'fileUrl': 'uploads/x.pdf', 'fileName': 'x.pdf'},
        ]) {
          late http.BaseRequest req;
          final repo = HomeworkRepositoryImpl(
            _api(
              MockClient.streaming((r, _) async {
                req = r;
                final bytes = utf8.encode(jsonEncode(body));
                return http.StreamedResponse(
                  Stream.value(bytes),
                  200,
                  headers: {'content-type': 'application/json'},
                );
              }),
            ),
          );
          final a = await repo.uploadAttachment(
            fileName: 'x.pdf',
            bytes: List.filled(2048, 1),
          );
          expect(a.reference, 'uploads/x.pdf');
          expect(a.sizeKb, 2);
          expect(a.type, 'pdf');
          expect(
            req.headers['content-type'],
            startsWith('multipart/form-data'),
          );
        }
      },
    );

    test(
      'upload uses fileUrl (the real UAT response), not the file name',
      () async {
        final repo = HomeworkRepositoryImpl(
          _api(
            MockClient(
              (_) async => jsonResponse({
                'fileUrl':
                    '/uploads/teacher-module/homework/20261009122836464-63a8-shot.png',
                'fileName': 'shot.png',
              }),
            ),
          ),
        );
        final a = await repo.uploadAttachment(
          fileName: 'shot.png',
          bytes: List.filled(10, 1),
        );
        expect(
          a.reference,
          '/uploads/teacher-module/homework/20261009122836464-63a8-shot.png',
        );
        expect(a.hasLocation, isTrue);
        expect(a.fileName, 'shot.png');
      },
    );

    test(
      'an upload response with only a file name is rejected, not saved',
      () async {
        // This is exactly what produced homework with unopenable attachments.
        final repo = HomeworkRepositoryImpl(
          _api(MockClient((_) async => jsonResponse({'fileName': 'shot.png'}))),
        );
        await expectLater(
          repo.uploadAttachment(fileName: 'shot.png', bytes: [1]),
          throwsA(isA<ParseException>()),
        );
      },
    );

    test('parseUploadResponse handles key variants and unknown path keys', () {
      expect(parseUploadResponse('/u/a.png')?.location, '/u/a.png');
      expect(
        parseUploadResponse({'url': 'http://h/a.png'})?.location,
        'http://h/a.png',
      );
      expect(
        parseUploadResponse({
          'storedAt': '/u/b.png',
          'fileName': 'b.png',
        })?.location,
        '/u/b.png',
      );
      expect(parseUploadResponse({'fileName': 'b.png', 'id': 5}), isNull);
      expect(parseUploadResponse(null), isNull);
      expect(parseUploadResponse(''), isNull);
    });

    test('upload with an unreadable response is a ParseException', () async {
      final repo = HomeworkRepositoryImpl(
        _api(MockClient((_) async => http.Response('', 200))),
      );
      await expectLater(
        repo.uploadAttachment(fileName: 'a.pdf', bytes: [1]),
        throwsA(isA<ParseException>()),
      );
    });
  });

  group('FeedbackRepository', () {
    const draft = FeedbackMessage(
      id: '',
      sessionId: 'pub-1',
      studentIds: ['2', '3', '4'],
      message: ' Well done ',
    );

    test('sends one request per student with the occurrence ids', () async {
      final bodies = <Map<String, dynamic>>[];
      final repo = FeedbackRepositoryImpl(
        _api(
          MockClient((r) async {
            bodies.add(jsonDecode(r.body) as Map<String, dynamic>);
            return jsonResponse({'id': 10 + bodies.length});
          }),
        ),
      );
      final res = await repo.sendMessage(_session, draft);

      expect(res.allSent, isTrue);
      expect(res.sent.map((m) => m.studentIds.single), ['2', '3', '4']);
      expect(bodies.map((b) => b['studentId']), [2, 3, 4]);
      expect(bodies.first['content'], 'Well done');
      expect(bodies.first['isPositive'], isTrue);
      expect(bodies.first['scheduleOccurrencePublicId'], 'pub-1');
    });

    test('partial failure reports the failed students only', () async {
      final repo = FeedbackRepositoryImpl(
        _api(
          MockClient((r) async {
            final id = (jsonDecode(r.body) as Map)['studentId'];
            return id == 3 ? http.Response('', 500) : jsonResponse({});
          }),
        ),
      );
      final res = await repo.sendMessage(_session, draft);
      expect(res.allSent, isFalse);
      expect(res.failedStudentIds, ['3']);
      expect(res.sent, hasLength(2));
    });

    test('everything failing throws the real error', () async {
      final repo = FeedbackRepositoryImpl(
        _api(MockClient((_) async => throw const SocketException('down'))),
      );
      await expectLater(
        repo.sendMessage(_session, draft),
        throwsA(isA<NetworkException>()),
      );
    });

    test('a 401 stops the loop immediately', () async {
      var calls = 0;
      final repo = FeedbackRepositoryImpl(
        _api(
          MockClient((_) async {
            calls++;
            return http.Response('', 401);
          }),
        ),
      );
      await expectLater(
        repo.sendMessage(_session, draft),
        throwsA(isA<UnauthorizedException>()),
      );
      expect(calls, 1);
    });

    test('getReviews reads graded students per homework', () async {
      final repo = FeedbackRepositoryImpl(
        _api(MockClient((_) async => jsonResponse(fx.taskStudents))),
      );
      final reviews = await repo.getReviews(
        _session,
        [
          Homework(
            id: '1008',
            sessionId: 'pub-1',
            classId: '23',
            subjectId: '18',
            title: 'T',
            description: '',
            deadline: DateTime(2026, 10, 8),
          ),
        ],
      );
      expect(reviews.single.studentId, '2');
      expect(reviews.single.marks, 80);
    });

    test('saveReview posts marks and review text', () async {
      late http.Request req;
      final repo = FeedbackRepositoryImpl(
        _api(
          MockClient((r) async {
            req = r;
            return http.Response('', 200);
          }),
        ),
      );
      final saved = await repo.saveReview(
        const AssignmentReview(
          id: '',
          sessionId: 'pub-1',
          homeworkId: '1008',
          studentId: '2',
          marks: 90,
          reviewText: ' Nice ',
        ),
      );
      expect(req.url.path, '/api/TeacherModule/homework/1008/review');
      expect(jsonDecode(req.body), {
        'studentId': 2,
        'marks': 90,
        'review': 'Nice',
      });
      expect(saved.reviewedAt, isNotNull);
    });
  });

  group('UserRepository', () {
    test('reads the staff record and caches it', () async {
      var calls = 0;
      final repo = UserRepositoryImpl(
        apiClient: _api(
          MockClient((r) async {
            calls++;
            expect(r.url.path, '/api/Staff/3');
            return jsonResponse(fx.staff3);
          }),
        ),
        authRepository: FakeAuthRepository(),
      );
      final user = await repo.getCurrentUser();
      await repo.getCurrentUser();
      expect(user.firstName, 'Tahir');
      expect(user.lastName, 'Mughal');
      expect(user.email, 'tahir@gmail.com');
      expect(calls, 1);
    });

    test(
      'updateProfile sends names, and passwords only when changing',
      () async {
        final bodies = <Map<String, dynamic>>[];
        final repo = UserRepositoryImpl(
          apiClient: _api(
            MockClient((r) async {
              if (r.method == 'PUT') {
                bodies.add(jsonDecode(r.body) as Map<String, dynamic>);
                return http.Response('', 200);
              }
              return jsonResponse(fx.staff3);
            }),
          ),
          authRepository: FakeAuthRepository(),
        );

        final u = await repo.updateProfile(firstName: 'T', lastName: 'M');
        expect(bodies.last, {'firstName': 'T', 'lastName': 'M'});
        expect(u.firstName, 'T');

        await repo.updateProfile(
          firstName: 'T',
          lastName: 'M',
          currentPassword: 'old',
          newPassword: 'New1!',
        );
        expect(bodies.last['currentPassword'], 'old');
        expect(bodies.last['newPassword'], 'New1!');
        expect(bodies.last['confirmNewPassword'], 'New1!');
      },
    );

    test('rejected password change surfaces the server message', () async {
      final repo = UserRepositoryImpl(
        apiClient: _api(
          MockClient((r) async {
            if (r.method == 'PUT') {
              return jsonResponse({
                'errors': {
                  'PasswordMismatch': ['Incorrect password.'],
                },
              }, 400);
            }
            return jsonResponse(fx.staff3);
          }),
        ),
        authRepository: FakeAuthRepository(),
      );
      await expectLater(
        repo.updateProfile(
          firstName: 'T',
          lastName: 'M',
          currentPassword: 'x',
          newPassword: 'y',
        ),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'm',
            'Incorrect password.',
          ),
        ),
      );
    });
  });
}
