import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skoolstar_teacher_module/data/repositories/chat_repository.dart';
import 'package:skoolstar_teacher_module/features/chat/cubit/direct_chat_state.dart';

/// Cubit for a single 1-to-1 parent chat. Owns the message list + the
/// `isSending` flag so the composer can disable itself while a message
/// is in flight.
class DirectChatCubit extends Cubit<DirectChatState> {
  DirectChatCubit({
    required this.threadId,
    required ChatRepository repository,
  })  : _repo = repository,
        super(const DirectChatState.initial());

  final String threadId;
  final ChatRepository _repo;

  Future<void> load() async {
    emit(const DirectChatState.loading());
    try {
      final thread = await _repo.getThreadById(threadId);
      if (thread == null) {
        emit(const DirectChatState.error('Chat not found'));
        return;
      }
      final messages = await _repo.getDirectMessagesFor(threadId);
      emit(DirectChatState.loaded(thread: thread, messages: messages));
      // Mark unread parent messages as read now that we've opened the thread.
      await _repo.markDirectThreadRead(threadId);
    } on Exception catch (e) {
      emit(DirectChatState.error(e.toString()));
    }
  }

  Future<bool> send(String content) async {
    final s = state;
    if (s is! DirectChatLoaded) return false;
    if (content.trim().isEmpty) return false;
    if (s.isSending) return false;

    emit(s.copyWith(isSending: true));
    try {
      final msg = await _repo.sendDirectMessage(
        threadId: threadId,
        content: content,
        fromTeacher: true,
      );
      emit(s.copyWith(messages: [...s.messages, msg], isSending: false));
      return true;
    } on Exception {
      emit(s.copyWith(isSending: false));
      return false;
    }
  }
}
