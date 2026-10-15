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

// ── Parent module (recorded from UAT, parent account zealmughal) ───────────

const parentContext = {
  'contextKey': 'Parent:8',
  'role': 'Parent',
  'clientId': 2,
  'clientName': 'Muhammad Amir',
  'instituteId': 8,
  'instituteName': 'ISL AC',
  'instituteTypeId': 2,
  'instituteTypeCode': 'TUITION_CENTER',
  'instituteTypeName': 'Tuition Center',
  'staffId': null,
  'studentId': 2,
  'guardianId': 2,
  'displayName': 'Parent — ISL AC',
};

const adminContext = {
  'contextKey': 'ClientAdmin:2',
  'role': 'ClientAdmin',
  'clientId': 2,
  'clientName': 'Muhammad Amir',
  'instituteId': 2,
  'instituteName': 'test',
  'instituteTypeId': 1,
  'instituteTypeCode': 'SCHOOL',
  'instituteTypeName': 'School',
  'staffId': null,
  'studentId': null,
  'guardianId': null,
  'displayName': 'Client Admin — Muhammad Amir',
};

const multiRoleLogin = {
  'tokenType': 'Bearer',
  'accessToken': 'pre-context',
  'expiresIn': 86400,
  'refreshToken': 'rt',
  'availableContexts': [adminContext, parentContext],
  'requiresContextSelection': true,
  'activeContextKey': null,
};

const myChildren = [
  {
    'studentId': 3,
    'studentName': 'Irha Shahzadi',
    'className': 'Class 2',
    'sectionName': null,
    'isPrimaryGuardian': true,
  },
  {
    'studentId': 2,
    'studentName': 'Jannat Shahzadi',
    'className': 'Class 1',
    'sectionName': null,
    'isPrimaryGuardian': true,
  },
];

const childAttendance = [
  {
    'studentId': 2,
    'studentName': 'Jannat Shahzadi',
    'date': '2026-10-09T00:00:00',
    'statusId': 3,
    'remarks': null,
    'sessionDate': '2026-10-09',
    'subjectName': '',
    'className': 'Class 1',
    'startTime': '14:40:00',
    'endTime': '23:40:00',
    'scheduleOccurrencePublicId': '40be1b5b-ba70-40e5-b67e-02c1e0a18a52',
  },
  {
    'studentId': 2,
    'studentName': 'Jannat Shahzadi',
    'date': '2026-10-07T00:00:00',
    'statusId': 1,
    'remarks': null,
    'sessionDate': '2026-10-07',
    'subjectName': '',
    'className': 'Class 1',
    'startTime': '19:08:00',
    'endTime': '23:08:00',
    'scheduleOccurrencePublicId': 'de17fe62-4cd4-4d55-8f06-9b7b8d9b95af',
  },
  {
    'studentId': 2,
    'studentName': 'Jannat Shahzadi',
    'date': '2026-10-05T00:00:00',
    'statusId': 1,
    'remarks': 'On time',
    'sessionDate': '2026-10-05',
    'className': 'Class 1',
    'startTime': '14:53:00',
    'endTime': '23:53:00',
    'scheduleOccurrencePublicId': 'f0dc4aab-b5cc-4f5d-bd5b-210f839f920e',
  },
];

const childAssignments = [
  {
    'studentId': 2,
    'studentName': 'Jannat Shahzadi',
    'taskId': 1009,
    'title': 'Computer — Class 1',
    'description': 'test',
    'deadline': '2026-10-10T15:41:00',
    'maxMarks': 100,
    'isCompleted': false,
    'completedAt': null,
    'feedback': 'weldone',
    'marks': 89,
    'scheduleOccurrenceId': 1027,
    'scheduleOccurrencePublicId': '40be1b5b-ba70-40e5-b67e-02c1e0a18a52',
    'sessionDate': '2026-10-09',
    'subjectName': '',
    'className': 'Class 1',
  },
  {
    'studentId': 2,
    'studentName': 'Jannat Shahzadi',
    'taskId': 1006,
    'title': 'first test',
    'description': 'first',
    'deadline': '2026-10-02T15:51:00',
    'maxMarks': 100,
    'isCompleted': false,
    'completedAt': null,
    'feedback': null,
    'marks': null,
    'scheduleOccurrencePublicId': 'cc459182-a077-4a98-a55d-0b702091dfbf',
    'sessionDate': '2026-10-01',
    'className': 'Class 1',
  },
];

const studentOccurrences = [
  {
    'id': 1019,
    'publicId': 'cc459182-a077-4a98-a55d-0b702091dfbf',
    'classScheduleId': 1010,
    'sessionDate': '2026-10-01',
    'classId': 23,
    'className': 'Class 1',
    'sectionId': null,
    'subjectId': null,
    'subjectName': 'Computer, English, Math',
    'startTime': '15:48:00',
    'endTime': '16:48:00',
    'isBreak': false,
    'status': 0,
    'teacherSubjects': [
      {
        'subjectId': 18,
        'subjectName': 'Computer',
        'teacherId': 2,
        'teacherName': 'Adnan Ilyas',
      },
      {
        'subjectId': 18,
        'subjectName': 'Computer',
        'teacherId': 3,
        'teacherName': 'Tahir Mughal',
      },
      {
        'subjectId': 19,
        'subjectName': 'English',
        'teacherId': 3,
        'teacherName': 'Tahir Mughal',
      },
    ],
    'classes': [
      {'id': 23, 'name': 'Class 1'},
      {'id': 24, 'name': 'Class 2'},
    ],
  },
  {
    'id': 1027,
    'publicId': '40be1b5b-ba70-40e5-b67e-02c1e0a18a52',
    'classScheduleId': 1017,
    'sessionDate': '2026-10-09',
    'classId': 23,
    'className': 'Class 1',
    'startTime': '14:40:00',
    'endTime': '23:40:00',
    'isBreak': false,
    'status': 0,
    'teacherSubjects': [
      {
        'subjectId': 17,
        'subjectName': 'Math',
        'teacherId': 3,
        'teacherName': 'Tahir Mughal',
      },
    ],
    'classes': [
      {'id': 23, 'name': 'Class 1'},
      {'id': 24, 'name': 'Class 2'},
    ],
  },
];

const contactPersons = [
  {
    'id': 2,
    'studentId': 2,
    'fullName': 'Muhammad Amir',
    'email': 'zealmughal@gmail.com',
    'phoneNumber': '23423423',
    'relationship': 'Father',
    'isPrimaryGuardian': true,
  },
];
