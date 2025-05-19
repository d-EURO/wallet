import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class _CustomIcon extends StatelessWidget {
  final String iconPath;
  final double? size;
  final Color? color;

  const _CustomIcon({required this.iconPath, this.size, this.color});

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
        iconPath,
        width: size,
        height: size,
        colorFilter:
            color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
      );
}

class LanguagesIcon extends _CustomIcon {
  const LanguagesIcon({super.size, super.color})
      : super(iconPath: 'assets/images/icons/setting_languages.svg');
}

class NodesIcon extends _CustomIcon {
  const NodesIcon({super.size, super.color})
      : super(iconPath: 'assets/images/icons/setting_nodes.svg');
}

class RecoveryKeyIcon extends _CustomIcon {
  const RecoveryKeyIcon({super.size, super.color})
      : super(iconPath: 'assets/images/icons/recovery_key.svg');
}

class CollectInterestIcon extends _CustomIcon {
  const CollectInterestIcon({super.size, super.color})
      : super(iconPath: 'assets/images/icons/collect_interest.svg');
}
