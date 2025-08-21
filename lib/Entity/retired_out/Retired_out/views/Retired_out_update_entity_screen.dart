// ignore_for_file: use_build_context_synchronously
import 'package:cricyard/Entity/retired_out/Retired_out/model/Retired_out_model.dart';
import 'package:cricyard/Entity/retired_out/Retired_out/viewmodel/Retired_out_viewmodel.dart';
import 'package:provider/provider.dart';

import '../../../../Utils/image_constant.dart';
import '../../../../Utils/size_utils.dart';
import '../../../../theme/app_style.dart';
import '../../../../views/widgets/app_bar/appbar_image.dart';
import '../../../../views/widgets/app_bar/appbar_title.dart';
import '../../../../views/widgets/app_bar/custom_app_bar.dart';
import '../../../../views/widgets/custom_button.dart';
import '../../../../views/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import '../repository/Retired_out_api_service.dart';
import '/providers/token_manager.dart';

class retired_outUpdateEntityScreen extends StatefulWidget {
  final RetiredOutEntity entity;

  retired_outUpdateEntityScreen({required this.entity});

  @override
  _retired_outUpdateEntityScreenState createState() =>
      _retired_outUpdateEntityScreenState();
}

class _retired_outUpdateEntityScreenState
    extends State<retired_outUpdateEntityScreen> {
  final _formKey = GlobalKey<FormState>();

  bool isactive = false;

  var selectedplayer_name; // Initialize with the default value \n);
  List<String> player_nameList = [
    'bar_code',
    'qr_code',
  ];

  @override
  void initState() {
    super.initState();

    isactive = widget.entity.active ?? false; // Set initial value

    selectedplayer_name =
        widget.entity.playerName; // Initialize with the default value
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RetiredOutProvider>(context, listen: false);
    return Scaffold(
      appBar: CustomAppBar(
          height: getVerticalSize(49),
          leadingWidth: 40,
          leading: AppbarImage(
              height: getSize(24),
              width: getSize(24),
              svgPath: ImageConstant.imgArrowleftBlueGray900,
              margin: getMargin(left: 16, top: 12, bottom: 13),
              onTap: () {
                Navigator.pop(context);
              }),
          centerTitle: true,
          title: AppbarTitle(text: "Update Retired_out")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Padding(
                    padding: getPadding(top: 19),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Description",
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.left,
                              style: AppStyle.txtGilroyMedium16Bluegray900),
                          CustomTextFormField(
                              focusNode: FocusNode(),
                              hintText: "Enter Description",
                              initialValue: widget.entity.description,
                              maxLines: 4,

                              // ValidationProperties

                              onsaved: (value) {
                                widget.entity.description = value ?? "";
                              },
                              margin: getMargin(top: 6))
                        ])),
                SizedBox(height: 16),
                Row(
                  children: [
                    Switch(
                      value: isactive,
                      onChanged: (newValue) {
                        widget.entity.active = newValue;
                      },
                    ),
                    const SizedBox(width: 8),
                    const Text('Active'),
                  ],
                ),
                DropdownButtonFormField<String>(
                  decoration:
                      const InputDecoration(labelText: 'Selectplayer_name'),
                  value: widget.entity.playerName,
                  items: player_nameList
                      .map((name) => DropdownMenuItem<String>(
                            value: name,
                            child: Text(name),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedplayer_name = value!;
                      widget.entity.playerName = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                CustomButton(
                  height: getVerticalSize(50),
                  text: "Update",
                  margin: getMargin(top: 24, bottom: 5),
                  onTap: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      widget.entity.active = isactive;

                      try {
                        await provider.updateEntity(
                            widget.entity
                                .id, // Assuming 'id' is the key in your entity map
                            widget.entity);

                        Navigator.pop(context);
                      } catch (e) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Error'),
                              content: Text('Failed to update Retired_out: $e'),
                              actions: [
                                TextButton(
                                  child: const Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
