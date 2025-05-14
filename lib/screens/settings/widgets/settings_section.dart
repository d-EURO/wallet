import 'package:deuro_wallet/styles/colors.dart';
import 'package:flutter/material.dart';

class SettingOption {
  final String title;
  final Widget leading;
  final Widget? trailing;
  final String? selectedOption;
  final GestureTapCallback? onTap;

  SettingOption({
    required this.title,
    required this.leading,
    this.trailing,
    this.selectedOption,
    this.onTap
  });
}

class SettingsSections extends StatelessWidget {
  final String title;
  final List<SettingOption> settings;

  const SettingsSections(
      {super.key, required this.title, required this.settings});

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Row(children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: DEuroColors.neutralGrey,
                ),
              )
            ]),
            Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  final setting = settings[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    child: InkWell(
                      enableFeedback: false,
                      onTap: setting.onTap,
                      child: Row(children: [
                        setting.leading,
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Text(
                            setting.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: DEuroColors.anthracite,
                            ),
                          ),
                        ),
                        if (setting.trailing != null) ...[
                          Spacer(),
                          if (setting.selectedOption != null) ...[
                            Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Text(
                                setting.selectedOption!,
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: DEuroColors.neutralGrey,
                                ),
                              ),
                            ),
                          ],
                          setting.trailing!
                        ],
                      ]),
                    ),
                  );
                },
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: DEuroColors.neutralGrey98,
                ),
                itemCount: settings.length,
              ),
            ),
          ],
        ),
      );
}
