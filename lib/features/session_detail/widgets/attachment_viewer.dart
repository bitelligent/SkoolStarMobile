import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:skoolstar_teacher_module/data/models/homework_model.dart';
import 'package:skoolstar_teacher_module/data/repositories/homework_repository.dart';

/// Opens a homework attachment: images in an in-app zoomable viewer, PDFs and
/// every other type in the device's own viewer/browser.
Future<void> openHomeworkAttachment(
  BuildContext context,
  HomeworkAttachment attachment,
) async {
  final repo = context.read<HomeworkRepository>();
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);

  void fail(String message) => messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

  final url = attachment.hasLocation ? repo.attachmentUrl(attachment) : null;
  if (url == null) {
    fail(
      "${attachment.fileName} can't be opened: it was saved without a file "
      'location. Re-attach the file to this homework.',
    );
    return;
  }

  if (attachment.isImage) {
    final headers = await repo.attachmentHeaders();
    await navigator.push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => _ImageViewer(
          url: url,
          headers: headers,
          title: attachment.fileName,
        ),
      ),
    );
    return;
  }

  try {
    final opened = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!opened) fail("Couldn't open ${attachment.fileName}.");
  } on Object {
    fail("Couldn't open ${attachment.fileName}.");
  }
}

class _ImageViewer extends StatelessWidget {
  const _ImageViewer({
    required this.url,
    required this.headers,
    required this.title,
  });

  final Uri url;
  final Map<String, String> headers;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        title: Text(title, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: 'Open in browser',
            icon: const Icon(Icons.open_in_new_rounded),
            onPressed: () =>
                launchUrl(url, mode: LaunchMode.externalApplication),
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          maxScale: 5,
          child: Image.network(
            url.toString(),
            headers: headers,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, progress) => progress == null
                ? child
                : const CircularProgressIndicator(color: Colors.white),
            errorBuilder: (context, error, stack) => Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                _loadErrorMessage(error),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Distinguishes "the server has no such file" from a connectivity problem.
String _loadErrorMessage(Object error) {
  if (error is NetworkImageLoadException) {
    if (error.statusCode == 404) {
      return 'This file is no longer available on the server.';
    }
    if (error.statusCode == 401 || error.statusCode == 403) {
      return "You don't have permission to view this file.";
    }
  }
  return "Couldn't load this image.\nCheck your connection and try again.";
}
