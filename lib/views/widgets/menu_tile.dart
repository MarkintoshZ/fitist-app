import 'package:flutter/material.dart';

class MenuTile extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final Function onTap;

  const MenuTile({Key key, this.leading, this.title, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: title,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
