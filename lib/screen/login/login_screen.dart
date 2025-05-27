import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sor_inventory/provider/current_host_provider.dart';
import 'package:sor_inventory/provider/screen_provider.dart';

import '../../app/app_route.dart';
import '../../app/constants.dart';
import '../../provider/shared_preference_provider.dart';
import 'login_provider.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MediaQueryData data = MediaQuery.of(context);
    const spcTop = Constants.kPadding * 6;
    const spcLogo = Constants.kPadding * 4;
    const spcField = Constants.kPadding * 3;
    // final isRedirect = useState(false);
    ref.watch(localAuthProvider).whenData((l) {
      if (l != null) {
        ref.read(currentConfigProvider.notifier).state = CurrentConfig(
          host: "${l.host}.sor.my",
          user: l,
          clientName: l.clientName ?? "Client not Configured",
        );
        Constants.host = l.host ?? "tkdev.sor.my";
        Constants.clientName = l.clientName ?? "Client not Configured";
        Constants.baseUrl = "https://${Constants.host}/sor_inv_api/";
        Constants.reportUrl = "https://${Constants.host}/reports/";

        if (l.screen != null && l.screen!.isNotEmpty) {
          ref.read(screenProvider.notifier).state = l.screen!;
        }
        Timer(Duration(milliseconds: 50), () {
          Navigator.of(context).pushReplacementNamed(
            homeV3Route,
          );
        });
      }
    });
    // ref.listen(loginStateProvider, (prev, next) {
    //   if (next is LoginStateDone ) {
    //     Timer(Duration(milliseconds: 50), () {
    //       Navigator.of(context).pushReplacementNamed(
    //         homeRoute,
    //       );
    //     });
    //   }
    // });

    // height is 800
    double xheight = MediaQuery.of(context).size.height - 100;
    if (xheight < 800) {
      xheight = 800;
    }
    return Scaffold(
      backgroundColor: const Color(0xff008a8d),
      body: MediaQuery(
        data: data.copyWith(textScaleFactor: 1.0),
        child: Center(
          child: SingleChildScrollView(
            child: SizedBox(
              height: xheight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  const _LoginHeader(spcTop: spcTop, spcLogo: spcLogo),
                  _LoginBody(),
                  const Spacer(),
                  const _LoginFooter(spcField: spcField, spcTop: spcTop),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginBody extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrUsername = useTextEditingController(text: "");
    final ctrPassword = useTextEditingController(text: "");
    final isUserPasswordNotEmpty = useState(false);
    final isLoading = useState<bool>(false);
    final errorUser = useState<String>("");
    final errorPassword = useState<String>("");

    ref.listen(loginStateProvider, (prev, next) {
      if (next is LoginStateLoading) {
        isLoading.value = true;
      } else if (next is LoginStateError) {
        isLoading.value = false;
        if (!next.message.contains("account")) {
          errorUser.value = "";
          errorPassword.value = next.message;
        } else {
          errorUser.value = next.message;
          errorPassword.value = "";
        }
      } else if (next is LoginStateDone) {
        Constants.host = next.loginModel.host ?? "tkdev.sor.my";
        Constants.clientName = next.loginModel.clientName ?? "Unknown Client";
        Constants.baseUrl = "https://${Constants.host}/sor_inv_api/";
        Constants.reportUrl = "https://${Constants.host}/reports/";
        Navigator.of(context).pushReplacementNamed(
          homeV3Route,
        );
      }
    });
    ctrUsername.addListener(() {
      if (ctrUsername.text != "" && ctrPassword.text != "") {
        isUserPasswordNotEmpty.value = true;
      } else {
        isUserPasswordNotEmpty.value = false;
      }
    });
    ctrPassword.addListener(() {
      if (ctrUsername.text != "" && ctrPassword.text != "") {
        isUserPasswordNotEmpty.value = true;
      } else {
        isUserPasswordNotEmpty.value = false;
      }
    });

    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          children: [
            _TextField(
              hintText: "Username",
              iconString: "images/icon_login_username.png",
              obscuredText: false,
              control: ctrUsername,
            ),
            if (errorUser.value != "") _ErrorMessage(message: errorUser.value),
            const SizedBox(
              height: Constants.kPadding,
            ),
            _TextField(
              iconString: "images/icon_login_password.png",
              hintText: "Password",
              obscuredText: true,
              control: ctrPassword,
            ),
            if (errorPassword.value != "")
              _ErrorMessage(message: errorPassword.value),
            const SizedBox(
              height: Constants.kPadding,
            ),
            _LoginButton(
              press: (isUserPasswordNotEmpty.value)
                  ? () {
                      ref.read(loginStateProvider.notifier).login(
                          username: ctrUsername.text,
                          password: ctrPassword.text);
                    }
                  : null,
            ),
          ],
        ),
        if (isLoading.value)
          const SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({
    Key? key,
    required this.message,
  }) : super(key: key);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        //color: Colors.white.withOpacity(0.5),
      ),
      width: 500,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 5),
            Text(message,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xfff1b1b2),
                )),
          ],
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  final VoidCallback? press;
  const _LoginButton({
    Key? key,
    required this.press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.loose(const Size(300, 200)),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              alignment: Alignment.center,
              backgroundColor: MaterialStateColor.resolveWith(
                (states) {
                  Color resultColor = Constants.orange;
                  for (var element in states) {
                    if (element == MaterialState.disabled) {
                      resultColor = Colors.grey.shade400;
                    }
                  }
                  return resultColor;
                },
              ),
            ),
            onPressed: press,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Login",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            )),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final String hintText;
  final bool obscuredText;
  final TextEditingController control;
  final void Function(String)? onSubmitted;
  final String iconString;

  const _TextField({
    Key? key,
    required this.hintText,
    required this.obscuredText,
    required this.control,
    this.iconString = "",
    this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.loose(const Size(300, 200)),
      child: TextField(
        controller: control,
        textAlign: TextAlign.left,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
        onSubmitted: onSubmitted,
        obscureText: obscuredText,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: (iconString == "")
              ? null
              : Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Image.asset(
                    iconString,
                  ),
                ),
          hintStyle: const TextStyle(
            color: Colors.white24,
            fontSize: 20,
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(
              color: Colors.white,
              width: 2.0,
            ),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
            borderSide: BorderSide(
              color: Constants.orange,
              width: 2.0,
            ),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
            borderSide: BorderSide(
              color: Colors.white24,
              width: 2.0,
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginFooter extends StatelessWidget {
  const _LoginFooter({
    Key? key,
    required this.spcField,
    required this.spcTop,
  }) : super(key: key);

  final double spcField;
  final double spcTop;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: spcField,
        ),
        Text(
          "${Constants.appVersion} ©2024 SOR SYSTEM SDN BHD",
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        SizedBox(
          height: spcTop / 2,
        )
      ],
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader({
    Key? key,
    required this.spcTop,
    required this.spcLogo,
  }) : super(key: key);

  final double spcTop;
  final double spcLogo;

  final logoHeightPercentage = 10;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: spcTop,
        ),
        // SvgPicture.asset(
        //   "images/logo_pearl.svg",
        //   height:
        //       MediaQuery.of(context).size.height * logoHeightPercentage / 100,
        // ),
        Image.asset(
          "images/sor_pearl_logo.gif",
          height:
              MediaQuery.of(context).size.height * logoHeightPercentage / 100,
        ),
        const SizedBox(
          height: 30,
        ),
        Text(
          Constants.appTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
          ),
        ),
        Text(
          Constants.appSubTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
          ),
        ),
        SizedBox(
          height: spcLogo,
        ),
      ],
    );
  }
}
