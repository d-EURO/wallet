import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class LanguagesIcon extends StatelessWidget {
  final double? size;

  const LanguagesIcon({super.key, this.size});

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
        'assets/images/icons/setting_languages.svg',
        width: size,
        height: size,
      );
}

class NodesIcon extends StatelessWidget {
  final double? size;

  const NodesIcon({super.key, this.size});

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
        'assets/images/icons/setting_nodes.svg',
        width: size,
        height: size,
      );
}
