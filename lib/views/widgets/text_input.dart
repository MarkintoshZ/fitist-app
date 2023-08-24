import 'package:flutter/material.dart';

class TextInputWidget extends StatelessWidget {
  final TextEditingController textEditingController;
  final Function validator;
  final Function onSaved;
  final String text;
  final bool obscureText;

  const TextInputWidget({
    Key key,
    @required this.textEditingController,
    @required this.validator,
    @required this.onSaved,
    @required this.text,
    this.obscureText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: textEditingController,
      maxLines: 1,
      autofocus: false,
      autocorrect: false,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: text,
        labelStyle: Theme.of(context).textTheme.headline4,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 33, vertical: 20),
        suffixIcon: ValueListenableBuilder(
          valueListenable: textEditingController,
          builder: (context, TextEditingValue value, _) {
            return AnimatedOpacity(
              opacity: (value.text.isEmpty) ? 0 : 1,
              duration: Duration(milliseconds: 300),
              curve: Curves.elasticInOut,
              child: IconButton(
                onPressed: textEditingController.clear,
                icon: Icon(Icons.clear),
              ),
            );
            // if (value.text.isEmpty) return Container(width: 0);
            // return IconButton(
            //   onPressed: textEditingController.clear,
            //   icon: Icon(Icons.clear),
            // );
          },
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xff707070),
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(20.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2.5,
          ),
          borderRadius: BorderRadius.circular(20.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).errorColor,
            width: 2.5,
          ),
          borderRadius: BorderRadius.circular(20.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).errorColor,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
      validator: validator,
      onSaved: onSaved,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}
