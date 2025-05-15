import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class _CustomIcon extends StatelessWidget {
  final double? size;
  final String iconPath;

  const _CustomIcon({required this.iconPath, this.size});

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
        iconPath,
        width: size,
        height: size,
      );
}

class LanguagesIcon extends _CustomIcon {
  const LanguagesIcon({super.size})
      : super(iconPath: 'assets/images/icons/setting_languages.svg');
}

class NodesIcon extends _CustomIcon {
  const NodesIcon({super.size})
      : super(iconPath: 'assets/images/icons/setting_nodes.svg');
}

class RecoveryKeyIcon extends _CustomIcon {
  const RecoveryKeyIcon({super.size})
      : super(iconPath: 'assets/images/icons/recovery_key.svg');
}

