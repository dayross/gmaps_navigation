
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  String hintText;
  TextEditingController? controller;
  void Function()? onPressed;

  
  CustomTextField({
    this.hintText = '',
    this.controller,
    this.onPressed,
    super.key});

  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    final border = OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // hintText widget and decoration
        Text(hintText, style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.green[800]
        ),),
        const SizedBox(height: 3,),
        //hintText input and decoration
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            enabledBorder: border,
            focusedBorder: border,
            isDense: true,
            focusColor: colors.primary,
            suffixIcon: IconButton(
              onPressed: onPressed, 
              icon: const Icon(Icons.location_on_sharp))
          ),
        )
      ],
    );
  }
}