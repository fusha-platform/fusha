import 'package:material_ui/material_ui.dart';

class AppCardFooter extends StatelessWidget {
  final Widget child;
  final MainAxisAlignment alignment;
  final EdgeInsetsGeometry padding;

  const AppCardFooter({
    super.key,
    required this.child,
    this.alignment = MainAxisAlignment.end,
    this.padding = const EdgeInsets.only(top: 16),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: alignment,
        children: [child],
      ),
    );
  }
}