
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CustomTextField extends StatelessWidget {
  String hintText;
  String text;
  void Function()? locationOnPressed;
  void Function()? deleteOnPressed;

  
  CustomTextField({
    this.hintText = '',
    this.text = '',
    this.locationOnPressed,
    this.deleteOnPressed,
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
          controller: TextEditingController(text: text),
          readOnly: true,          
          maxLines: 1,
          decoration: InputDecoration(
            hintText: hintText,
            enabledBorder: border,
            focusedBorder: border,
            suffixIconConstraints: BoxConstraints( minWidth: size.width*0.25),
            isDense: true,
            focusColor: colors.primary,
            suffixIcon: Container(
              width: 30,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: deleteOnPressed, 
                    icon: const Icon(Icons.cancel)),
                  IconButton(
                    onPressed: locationOnPressed, 
                    icon: const Icon(Icons.location_on_sharp)),
                ],
              ),
            )
          ),
        )
      ],
    );
  }
}