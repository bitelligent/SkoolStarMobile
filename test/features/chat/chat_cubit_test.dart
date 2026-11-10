import 'package:flutter_test/flutter_test.dart';
import 'package:skoolstar_teacher_module/data/models/chat_thread.dart';
import 'package:skoolstar_teacher_module/data/repositories/chat_repository.dart';
import 'package:skoolstar_teacher_module/features/chat/cubit/chat_cubit.dart';
import 'package:skoolstar_teacher_module/features/chat/cubit/chat_state.dart';

import 'chat_fakes.dart';

void main() {
  late _ListRepo repo;
  late ChatCubit cubit;

  ChatLoaded loaded() => cubit.state as ChatLoaded;

  Future<void> boot({Duration poll = const Duration(hours: 1)}) async {
    repo = _ListRepo();
    cubit = ChatCubit(
      repo,
      pollInterval: poll,
      debounce: const Duration(milliseconds: 10),
    );
    await cubit.load();
  }

  tearDown(() async {
    await cubit.close();
    await repo.dispose();
  });

  test('loads threads and counts unread per tab', () async {
    await boot();
    expect(loaded().threads.length, 2);
    expect(cubit.unreadCountFor(ChatCategory.oneToOne), 3);
    expect(cubit.unreadCountFor(ChatCategory.feedback), 0);
  });

  test('realtime events refresh quietly, bursts are coalesced', () async {
    await boot();
    final base = repo.fetches;
    repo.threads = [
      repo.threads.first.copyWith(unreadCount: 9),
      repo.threads.last,
    ];
    for (var i = 0; i < 5; i++) {
      repo.controller.add(DirectThreadChanged('dm_1'));
    }
    await pump(80);
    expect(repo.fetches, base + 1);
    expect(loaded().threads.first.unreadCount, 9);
  });

  test('a failing refresh never replaces the list with an error', () async {
    await boot();
    repo.fail = true;
    repo.controller.add(const ChatResync());
    await pump(80);
    expect(cubit.state, isA<ChatLoaded>());
    expect(loaded().threads.length, 2);
  });

  test('timer refresh surfaces new feedback threads', () async {
    await boot(poll: const Duration(milliseconds: 30));
    repo.threads = [
      ...repo.threads,
      ChatThread(
        id: 'fb_7',
        name: 'New parent',
        category: ChatCategory.feedback,
        lastMessageAt: DateTime(2026, 10, 3),
      ),
    ];
    await pump(120);
    expect(loaded().threads.length, 3);
  });

  test('presence updates the matching thread only', () async {
    await boot();
    repo.controller.add(const PeerPresenceChanged('peer', online: true));
    await pump();
    expect(loaded().threads.first.isOnline, isTrue);
    expect(loaded().threads.last.isOnline, isFalse);
  });

  test('search filters by name and message within the tab', () async {
    await boot();
    cubit.setActiveTab(ChatCategory.oneToOne);
    cubit.setQuery('amir');
    expect(cubit.visibleThreads().length, 1);
    cubit.setQuery('zzz');
    expect(cubit.visibleThreads(), isEmpty);
  });

  test('initial load failure shows an error', () async {
    repo = _ListRepo()..fail = true;
    cubit = ChatCubit(repo);
    await cubit.load();
    expect(cubit.state, isA<ChatError>());
  });
}

class _ListRepo extends FakeChatRepository {
  _ListRepo() {
    threads = [
      ChatThread(
        id: 'dm_1',
        name: 'Muhammad Amir',
        category: ChatCategory.oneToOne,
        lastMessageAt: DateTime(2026, 10, 2),
        unreadCount: 3,
        peerUserId: 'peer',
      ),
      ChatThread(
        id: 'fb_2',
        name: 'Other Parent',
        category: ChatCategory.feedback,
        lastMessageAt: DateTime(2026, 10, 1),
      ),
    ];
  }

  late List<ChatThread> threads;
  int fetches = 0;
  bool fail = false;

  @override
  Future<List<ChatThread>> getThreads() async {
    fetches++;
    if (fail) throw networkError;
    return List.of(threads);
  }
}
