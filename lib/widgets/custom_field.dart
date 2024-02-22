import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';

class CustomField extends StatelessWidget {
  final TextEditingController? controller;
  final IconData? data;
  final String? hintText;
  bool? isObsecre = true;
  bool? enabled = true;
  final String? placeholder;
  bool? changeToLowerCase;
  Function? callBack;

  CustomField({
    this.controller,
    this.data,
    this.hintText,
    this.isObsecre,
    this.enabled,
    this.placeholder,
    this.changeToLowerCase,
    this.callBack
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(20, 8, 20, 10),
          child: TextFormField(
            inputFormatters: [
              FilteringTextInputFormatter.deny(new RegExp(r"\s\b|\b\s"))
            ],
            enabled: enabled,
            controller: controller,
            obscureText: isObsecre!,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10)),
              contentPadding: EdgeInsets.symmetric(vertical: 10),
              labelText: hintText?.tr(),
              border: const OutlineInputBorder(
                  borderSide: BorderSide(
                      width: 0.1, color: Colors.black)
              ),
              prefixIcon: Icon(data),
            ),
              enableInteractiveSelection: true,
            onChanged: (v){
              callBack!();
            },

          ),
        ),
      ],
    );
  }
}













