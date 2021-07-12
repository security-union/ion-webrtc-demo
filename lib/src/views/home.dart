// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_ion/flutter_ion.dart' as ion;
import 'package:ion_webrtc_demo/src/styles/colors.dart';
import 'package:ion_webrtc_demo/src/styles/text.dart';
import 'package:ion_webrtc_demo/src/views/role_view.dart';
import 'package:ion_webrtc_demo/src/widgets/rounded_button.dart';
import 'package:uuid/uuid.dart';

class Home extends StatefulWidget {
  const Home({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Our device Unique identifier
  final String _uuid = const Uuid().v4();
  final _formKey = GlobalKey<FormState>();
  String _addr = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(50.0),
          child: _sfuAddrForm(
            _formKey,
            onUpdateAddr: (String addr) => setState(() => _addr = addr),
            onValidSubmit: () {
              _navigateToRoleView(_uuid, _addr);
            },
          ),
        ),
      ),
    );
  }

  Widget _sfuAddrForm(
    GlobalKey<FormState> formKey, {
    required Function(String) onUpdateAddr,
    required Function() onValidSubmit,
  }) =>
      Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 30.0),
            _urlField(
              'SFU Address',
              onChanged: onUpdateAddr,
            ),
            const SizedBox(height: 30.0),
            _submitButton('Enter', formKey, onValidSubmit: onValidSubmit),
          ],
        ),
      );

  Widget _urlField(
    String label, {
    required Function(String) onChanged,
  }) =>
      TextFormField(
        keyboardType: TextInputType.url,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: subtitle,
        ),
        validator: _validateURL,
        onChanged: onChanged,
      );

  Widget _submitButton(
    String text,
    GlobalKey<FormState> formKey, {
    required Function() onValidSubmit,
  }) =>
      roundedButton(
        text: 'Enter',
        color: AppColors.primaryBlue,
        onPressed: () {
          if (formKey.currentState!.validate()) {
            formKey.currentState!.save();
            onValidSubmit();
          }
        },
      );

  void _navigateToRoleView(String uuid, String addr) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return RoleView(uuid: uuid, addr: addr);
        },
      ),
    );
  }

  String? _validateURL(String? value) {
    return (value != null && value.length > 1) ? null : 'Empty url';
  }
}
