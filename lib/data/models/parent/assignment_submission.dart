import 'package:equatable/equatable.dart';

/// A file already stored by the server, ready to be referenced by a submit.
class SubmissionFile extends Equatable {
  const SubmissionFile({required this.url, required this.name});

  /// Server path returned by the upload; what the submit body carries.
  final String url;

  /// Original file name, for display only.
  final String name;

  @override
  List<Object?> get props => [url, name];
}

/// What a guardian may hand in, as enforced by the backend. Checking here
/// first means a wrong file is refused on the spot instead of after a failed
/// upload.
class SubmissionRules {
  const SubmissionRules._();

  static const int maxFiles = 5;
  static const int maxLinks = 5;
  static const int maxFileBytes = 15 * 1024 * 1024;
  static const int maxLinkLength = 2000;

  static const List<String> allowedExtensions = [
    'pdf',
    'doc',
    'docx',
    'xls',
    'xlsx',
    'ppt',
    'pptx',
    'txt',
    'jpg',
    'jpeg',
    'png',
    'zip',
  ];

  static const Set<String> imageExtensions = {'jpg', 'jpeg', 'png'};

  /// Lower-case extension without the dot; empty when there is none.
  static String extensionOf(String fileName) {
    final dot = fileName.lastIndexOf('.');
    return dot < 0 ? '' : fileName.substring(dot + 1).toLowerCase();
  }

  static bool isImage(String fileName) =>
      imageExtensions.contains(extensionOf(fileName));

  /// Why [fileName] of [bytes] cannot be handed in, or `null` when it can.
  static String? fileError(String fileName, int bytes) {
    if (bytes <= 0) return '$fileName is empty.';
    if (!allowedExtensions.contains(extensionOf(fileName))) {
      return '$fileName is not a supported file type.';
    }
    if (bytes > maxFileBytes) return '$fileName is larger than 15 MB.';
    return null;
  }

  /// Cleans up what a guardian typed as a link: trims it, adds `https://`
  /// when no scheme was typed and rejects anything that is not a web
  /// address. Returns `null` for a value that cannot be used.
  static String? normalizeLink(String raw) {
    final text = raw.trim();
    if (text.isEmpty || text.length > maxLinkLength) return null;
    if (RegExp(r'\s').hasMatch(text)) return null;
    final withScheme = RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*://').hasMatch(text)
        ? text
        : 'https://$text';
    final uri = Uri.tryParse(withScheme);
    if (uri == null || !(uri.scheme == 'http' || uri.scheme == 'https')) {
      return null;
    }
    final host = uri.host;
    if (host.isEmpty || !(host.contains('.') || host == 'localhost')) {
      return null;
    }
    return withScheme;
  }
}
