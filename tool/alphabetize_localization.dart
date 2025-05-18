import 'localization/arb_file_utils.dart';

void main(List<String> args) => alphabetizeLocalization();

void alphabetizeLocalization() {
  for (var lang in ['de', 'en']) {
    final fileName = getArbFileName(lang);
    alphabetizeArbFile(fileName);
  }
}
