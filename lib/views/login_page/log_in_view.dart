import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitist/model/form_models.dart';
import 'package:fitist/utils/input_validators.dart';
import 'package:fitist/views/landing.dart';
import 'package:fitist/views/widgets/text_input.dart';
import 'package:flutter/material.dart';

final auth = FirebaseAuth.instance;

class LogInView extends StatefulWidget {
  final goToHome;

  const LogInView({Key key, this.goToHome}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _LogInViewState();
  }
}

class _LogInViewState extends State<LogInView> {
  static const padding = const EdgeInsets.symmetric(vertical: 12);

  final _formKey = GlobalKey<FormState>();
  var _formData = LogInFormData();
  final _emailInputController = TextEditingController();
  final _passwordInputController = TextEditingController();

  var _errorMessage = '';
  var _isLoading = false;

  // Perform login or sign up when primary button is pressed
  void _validateAndSubmit() async {
    if (!_formKey.currentState.validate()) return;
    _formKey.currentState.save();

    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });

    try {
      await auth.signInWithEmailAndPassword(
          email: _formData.email, password: _formData.password);
      var user = auth.currentUser;
      if (!user.emailVerified) {
        Navigator.pushNamed(context, EMAIL_VERIFICATION_PAGE);
      } else {
        widget.goToHome();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
        _formKey.currentState.reset();
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
          _showCircularProgress(),
        ],
      ),
    );
  }

  Widget _showCircularProgress() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

  // TODO: Implement reset password feature

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
            'Login',
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
      style: TextStyle(
        fontSize: 13.0,
        color: Colors.red,
        height: 1.0,
        fontWeight: FontWeight.w300,
      ),
    );
  }

  Widget _showEmailInput() {
    return Padding(
      padding: padding,
      child: TextInputWidget(
        text: 'Email',
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
      child: ElevatedButton(
        child: Text('Login'),
        onPressed: _validateAndSubmit,
      ),
    );
  }
}
