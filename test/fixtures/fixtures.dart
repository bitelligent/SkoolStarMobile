// Payloads recorded from the UAT server (teacher account, staffId 3,
// instituteId 8) with tokens removed. Used by mapper/repository tests.

const teacherContext = {
  'contextKey': 'Teacher:3',
  'role': 'Teacher',
  'clientId': 2,
  'clientName': 'Muhammad Amir',
  'instituteId': 8,
  'instituteName': 'ISL AC',
  'instituteTypeId': 2,
  'instituteTypeCode': 'TUITION_CENTER',
  'instituteTypeName': 'Tuition Center',
  'staffId': 3,
  'studentId': null,
  'guardianId': null,
  'displayName': 'Teacher — ISL AC',
};

const loginResponse = {
  'tokenType': 'Bearer',
  'accessToken': 'at',
  'expiresIn': 86400,
  'refreshToken': 'rt',
  'availableContexts': [teacherContext],
  'requiresContextSelection': false,
  'activeContextKey': 'Teacher:3',
};

const occurrencesOctober = [
  {
    'id': 1019,
    'publicId': 'cc459182-a077-4a98-a55d-0b702091dfbf',
    'classScheduleId': 1010,
    'sessionDate': '2026-10-01',
    'classId': 23,
    'className': 'Class 1, Class 2',
    'sectionId': null,
    'subjectId': null,
    'subjectName': 'Computer, English, Math',
    'startTime': '15:48:00',
    'endTime': '16:48:00',
    'isBreak': false,
    'status': 0,
    'statusName': 'Scheduled',
    'teacherSubjects': [
      {'subjectId': 18, 'subjectName': 'Computer', 'teacherId': 3},
      {'subjectId': 19, 'subjectName': 'English', 'teacherId': 3},
      {'subjectId': 17, 'subjectName': 'Math', 'teacherId': 3},
    ],
    'classes': [
      {'id': 23, 'name': 'Class 1'},
      {'id': 24, 'name': 'Class 2'},
    ],
  },
  {
    'id': 1026,
    'publicId': '473c2ebb-3344-4535-9df3-c99646450be7',
    'classScheduleId': 1017,
    'sessionDate': '2026-10-08',
    'classId': 23,
    'className': 'Class 1',
    'sectionId': null,
    'subjectId': null,
    'subjectName': '',
    'startTime': '15:24:00',
    'endTime': '22:24:00',
    'isBreak': false,
    'status': 0,
    'statusName': 'Scheduled',
    // Another teacher shares this slot: only staff 3's subjects are ours.
    'teacherSubjects': [
      {'subjectId': 18, 'subjectName': 'Computer', 'teacherId': 2},
      {'subjectId': 18, 'subjectName': 'Computer', 'teacherId': 3},
      {'subjectId': 19, 'subjectName': 'English', 'teacherId': 2},
      {'subjectId': 19, 'subjectName': 'English', 'teacherId': 3},
    ],
    'classes': [
      {'id': 23, 'name': 'Class 1'},
      {'id': 24, 'name': 'Class 2'},
    ],
  },
  {
    // Breaks are not classes and must be skipped.
    'id': 1030,
    'publicId': 'break-1',
    'sessionDate': '2026-10-08',
    'isBreak': true,
    'status': 0,
  },
];

const teacherSchedules = [
  {
    'id': 1017,
    'classId': 23,
    'classes': [
      {'id': 23, 'name': 'Class 1'},
      {'id': 24, 'name': 'Class 2'},
    ],
    'teacherSubjects': [
      {'subjectId': 18, 'subjectName': 'Computer', 'teacherId': 3},
      {'subjectId': 19, 'subjectName': 'English', 'teacherId': 3},
      {'subjectId': 17, 'subjectName': 'Math', 'teacherId': 3},
      {'subjectId': 99, 'subjectName': 'Other teacher only', 'teacherId': 2},
    ],
  },
];

const myClasses = [
  {
    'classId': 23,
    'className': 'Class 1',
    'subjects': ['Computer', 'English', 'Math'],
    'studentCount': 2,
  },
];

const myStudents = [
  {'studentId': 3, 'studentName': 'Irha Shahzadi', 'className': 'Class 2'},
  {'studentId': 2, 'studentName': 'Jannat Shahzadi', 'className': 'Class 1'},
];

const attendanceForClass23 = {
  'classId': 23,
  'date': '2026-10-08',
  'scheduleOccurrenceId': 1026,
  'scheduleOccurrencePublicId': '473c2ebb-3344-4535-9df3-c99646450be7',
  'students': [
    {
      'studentId': 3,
      'studentName': 'Irha Shahzadi',
      'className': 'Class 2',
      'statusId': null,
    },
    {
      'studentId': 2,
      'studentName': 'Jannat Shahzadi',
      'className': 'Class 1',
      'statusId': 1,
    },
  ],
};

const staff3 = {
  'id': 3,
  'firstName': 'Tahir',
  'lastName': 'Mughal',
  'fullName': 'Tahir Mughal',
  'email': 'tahir@gmail.com',
  'photoUrl': '',
};

const taskStudents = [
  {
    'studentId': 2,
    'studentName': 'Jannat Shahzadi',
    'className': 'Class 1',
    'submitted': true,
    'completedAt': '2026-10-08T10:00:00',
    'marks': 80,
    'review': 'Good work',
  },
  {
    'studentId': 3,
    'studentName': 'Irha Shahzadi',
    'className': 'Class 2',
    'submitted': false,
    'completedAt': null,
    'marks': null,
    'review': null,
  },
];
