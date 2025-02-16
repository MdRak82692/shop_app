import 'package:flutter/material.dart';
import '../fetch_information/fetch_information.dart';
import '../../../utils/text.dart';

class ProductAutocomplete extends StatefulWidget {
  final FetchInformation fetchInformation;
  final Function(String) onSelected;
  final TextEditingController textEditingController;
  final FocusNode focusNode;
  final VoidCallback onFieldSubmitted;
  final Key? autocompleteKey;

  const ProductAutocomplete({
    super.key,
    required this.fetchInformation,
    required this.onSelected,
    required this.textEditingController,
    required this.focusNode,
    required this.onFieldSubmitted,
    this.autocompleteKey,
  });

  @override
  ProductAutocompleteState createState() => ProductAutocompleteState();
}

class ProductAutocompleteState extends State<ProductAutocomplete> {
  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      key: widget.autocompleteKey,
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return widget.fetchInformation.productName.where((String option) {
          return option.toLowerCase().contains(
                textEditingValue.text.toLowerCase(),
              );
        });
      },
      onSelected: (String selection) {
        widget.onSelected(selection);
        widget.textEditingController.text = selection;
      },
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController fieldController,
        FocusNode focusNode,
        VoidCallback onFieldSubmitted,
      ) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: TextField(
            controller: fieldController,
            focusNode: focusNode,
            onChanged: (value) {
              if (widget.fetchInformation.selectedProductName != value) {
                widget.fetchInformation.selectedProductName = '';
              }
            },
            decoration: InputDecoration(
              labelText: 'Product Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              labelStyle: style(16, color: Colors.black),
              prefixIcon: const Icon(Icons.label, color: Colors.blue),
            ),
            style: style(16, color: Colors.black),
          ),
        );
      },
      optionsViewBuilder: (
        BuildContext context,
        AutocompleteOnSelected<String> onSelected,
        Iterable<String> options,
      ) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 6.0,
            child: SizedBox(
              height: 200.0,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final String option = options.elementAt(index);
                  final String inputText = widget.textEditingController.text;
                  final int matchStart =
                      option.toLowerCase().indexOf(inputText.toLowerCase());
                  final int matchEnd = matchStart + inputText.length;

                  return ListTile(
                    title: RichText(
                      text: TextSpan(
                        style: style(16, color: Colors.black),
                        children: [
                          TextSpan(
                            text: option.substring(0, matchStart),
                          ),
                          TextSpan(
                            text: option.substring(matchStart, matchEnd),
                            style: style(14, color: Colors.blue),
                          ),
                          TextSpan(
                            text: option.substring(matchEnd),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      onSelected(option);
                      widget.textEditingController.text = option;
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
