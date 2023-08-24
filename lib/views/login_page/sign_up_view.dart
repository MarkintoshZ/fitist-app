import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitist/model/form_models.dart';
import 'package:fitist/services/firestore.dart';
import 'package:fitist/utils/input_validators.dart';
import 'package:fitist/views/landing.dart';
import 'package:fitist/views/widgets/text_input.dart';
import 'package:flutter/material.dart';

final auth = FirebaseAuth.instance;

class SignUpView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SignUpViewState();
  }
}

class _SignUpViewState extends State<SignUpView> {
  static const padding = const EdgeInsets.symmetric(vertical: 12);

  final _formKey = GlobalKey<FormState>();
  var _formData = SignUpFormData();
  final _usernameInputController = TextEditingController();
  final _displayNameInputController = TextEditingController();
  final _emailInputController = TextEditingController();
  final _passwordInputController = TextEditingController();

  var _errorMessage = '';
  var _isLoading = false;

  void validateAndSubmit() async {
    if (!_formKey.currentState.validate()) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    _formKey.currentState.save();

    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });

    try {
      // 1. create user auth
      print(_formData.email + '' + _formData.password);
      await auth.createUserWithEmailAndPassword(
        email: _formData.email,
        password: _formData.password,
      );
      // 2. create user profile in DB
      final user = auth.currentUser;
      createUser(user.uid, _formData.username, _formData.displayName);
      // 3. send email verification TODO: implement action code?
      await auth.currentUser.sendEmailVerification();
      // 4. Navigate to confirm email page
      Navigator.pushNamed(context, EMAIL_VERIFICATION_PAGE);
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
        // _formKey.currentState.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: <Widget>[
          _showForm(),
          if (_isLoading) Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _showForm() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _showHeader(),
                _showUsernameInput(),
                _showDisplayNameInput(),
                _showEmailInput(),
                _showPasswordInput(),
                _showSubmitButton(),
                if (_errorMessage != null && _errorMessage.length > 0)
                  _showErrorMessage(),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
            ),
          ),
        ),
      ),
    );
  }

  Widget _showHeader() {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.03,
        bottom: MediaQuery.of(context).size.height * 0.04,
      ),
      child: Column(
        children: [
          Text(
            'Sign Up',
            style: Theme.of(context).textTheme.headline1,
          ),
          SizedBox(height: 2),
          Text(
            "Let's get you started",
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
    );
  }

  Widget _showErrorMessage() {
    return Text(
      _errorMessage,
      style: Theme.of(context)
          .textTheme
          .headline3
          .copyWith(color: Theme.of(context).errorColor),
    );
  }

  Widget _showUsernameInput() {
    return Padding(
      padding: padding,
      child: TextInputWidget(
        text: "Username",
        textEditingController: _usernameInputController,
        validator: (s) {
          if (s.length == 0) return 'Cannot be empty';
          return null;
        },
        onSaved: (value) => _formData.displayName = value.trim(),
      ),
    );
  }

  Widget _showDisplayNameInput() {
    return Padding(
      padding: padding,
      child: TextInputWidget(
        text: "Display name",
        textEditingController: _displayNameInputController,
        validator: usernameValidator,
        onSaved: (value) => _formData.username = value.trim(),
      ),
    );
  }

  Widget _showEmailInput() {
    return Padding(
      padding: padding,
      child: TextInputWidget(
        text: "Email",
        textEditingController: _emailInputController,
        validator: emailValidator,
        onSaved: (value) => _formData.email = value.trim(),
      ),
    );
  }

  Widget _showPasswordInput() {
    return Padding(
      padding: padding,
      child: TextInputWidget(
        text: "Password",
        textEditingController: _passwordInputController,
        validator: passwordValidator,
        onSaved: (value) => _formData.password = value.trim(),
        obscureText: true,
      ),
    );
  }

  Widget _showSubmitButton() {
    return Padding(
      padding: padding.copyWith(bottom: 8),
      child:
          ElevatedButton(child: Text('Sign Up'), onPressed: validateAndSubmit),
    );
  }
}
