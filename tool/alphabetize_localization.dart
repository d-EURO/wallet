import 'localization/arb_file_utils.dart';

Future<void> main(List<String> args) async {
  for (var lang in ['de', 'en']) {
    final fileName = getArbFileName(lang);
    alphabetizeArbFile(fileName);
  }
}
