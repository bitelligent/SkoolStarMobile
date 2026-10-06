import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skoolstar_teacher_module/data/models/chat_thread.dart';
import 'package:skoolstar_teacher_module/data/repositories/chat_repository.dart';
import 'package:skoolstar_teacher_module/features/chat/cubit/chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit(this._repo) : super(const ChatState.initial());

  final ChatRepository _repo;

  Future<void> load() async {
    emit(const ChatState.loading());
    try {
      final threads = await _repo.getThreads();
      emit(ChatState.loaded(threads: threads));
    } on Exception catch (e) {
      emit(ChatState.error(e.toString()));
    }
  }

  void setActiveTab(ChatCategory tab) {
    final s = state;
    if (s is ChatLoaded) emit(s.copyWith(activeTab: tab));
  }

  void setQuery(String q) {
    final s = state;
    if (s is ChatLoaded) emit(s.copyWith(query: q));
  }

  /// Threads for the active tab, with the current search applied.
  List<ChatThread> visibleThreads() {
    final s = state;
    if (s is! ChatLoaded) return const [];
    final q = s.query.trim().toLowerCase();
    return s.threads.where((t) {
      if (t.category != s.activeTab) return false;
      if (q.isEmpty) return true;
      return t.name.toLowerCase().contains(q) ||
          t.lastMessage.toLowerCase().contains(q);
    }).toList();
  }

  /// Total unread count per category — used to decorate the pill tabs.
  int unreadCountFor(ChatCategory cat) {
    final s = state;
    if (s is! ChatLoaded) return 0;
    return s.threads
        .where((t) => t.category == cat)
        .fold<int>(0, (sum, t) => sum + t.unreadCount);
  }
}
