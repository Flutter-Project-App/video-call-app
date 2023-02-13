import 'package:flutter/material.dart';
import 'package:flutter_application/ui/blocs/auth/auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../generated/l10n.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            context.read<AuthBloc>().login("username", "password");
          },
          child: Text(S.of(context).sign_in),
        ),
      ),
    );
  }
}
