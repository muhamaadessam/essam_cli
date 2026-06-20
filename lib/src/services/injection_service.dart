class InjectionService {
  static String injectBeforeLastBrace(
    String source,
    String injection,
  ) {
    final lastBrace = source.lastIndexOf('}');

    if (lastBrace == -1) {
      throw Exception('No closing brace found');
    }

    return '${source.substring(0, lastBrace)}$injection${source.substring(lastBrace)}';
  }
}
