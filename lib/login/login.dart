import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:toggle_switch/toggle_switch.dart';

import 'dart:io' show Platform;

import '../utils/dimensions.dart';
import '../utils/images.dart';
import '../utils/route_helper.dart';
import '../utils/styles.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_indicator.dart';
import 'auth_controller.dart';


class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  String selectedOperation = "Shipa Mall";

  final List<String> operations = ["Shipa Mall", "Shipa"];
  @override
  void initState() {
    super.initState();
    Get.find<AuthController>().saveSelectedOperation(selectedOperation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        isBackButtonExist: false,
        bgColor: Theme.of(context).cardColor,
        titleColor: Theme.of(context).textTheme.bodyLarge!.color,
      ),
      body: GetBuilder<AuthController>(
        builder: (controller) {
          return Container(
            color: Theme.of(context).cardColor,
            child: Stack(
              children: [
                mainUI(context, controller),
                controller.isLoading
                    ? const LoadingIndicator()
                    : const SizedBox(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget mainUI(BuildContext context, AuthController controller) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              height: 100,
              child: Image.asset(
                Images.logo,
                // scale: 3,
                // color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            /*ToggleSwitch(
              minWidth: 90.0,
              minHeight: 40.0,
              fontSize: 14.0,
              initialLabelIndex: 1,
              activeBgColor: [Colors.green],
              activeFgColor: Colors.white,
              inactiveBgColor: Colors.grey[200],
              inactiveFgColor: Colors.grey[700],
              totalSwitches: 2,
              labels: ['Amazon', 'Shipa Mall'],
              onToggle: (index) {
                print('switched to: $index');
              },
            ),*/
            Row(
              children: [
                Text(
                  '',
                  style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeExtraLarge,
                      color: Theme.of(context).textTheme.bodyLarge!.color!),
                ),
              ],
            ),
            const SizedBox(height: 10),
            emailField(context, controller),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            passwordField(context, controller),
            const SizedBox(height: Dimensions.paddingSizeExtraLarge),
          /*  Text(
              'Operation:',
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),*/
            // Dropdown for Operation
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.all(
                    Radius.circular(Dimensions.paddingSizeExtraSmall)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedOperation,
                  isExpanded: true,
                  style: const TextStyle(
                    fontSize: 15.0, // Set the desired font size here
                    color: Colors.black, // Optional: customize color
                    //fontWeight: FontWeight.bold, // Optional: customize font weight
                  ),
                  icon: const Icon(Icons.arrow_drop_down),
                  onChanged: (value) {
                    setState(() {
                      selectedOperation = value!;
                      controller.saveSelectedOperation(selectedOperation);
                    });
                  },
                  items: operations.map((op) {
                    return DropdownMenuItem<String>(
                      value: op,
                      child: Text(op),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            CustomButton(
                onPressed: () {

                  if (!controller.isLoading) {
                    controller.login(context);
                  }
                },
                buttonText: 'Login'),
            const SizedBox(
              height: 160,
            ),

            // Footer
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                "© 2025 Shipa Ecommerce. All rights reserved. Version 1.0.0",
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget emailField(BuildContext context, AuthController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          height: 45,
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .color!
                  .withOpacity(0.06),
            ),
            borderRadius: const BorderRadius.all(
                Radius.circular(Dimensions.paddingSizeExtraSmall)),
          ),
          child: CustomTextField(
            hintText: 'Username',
            controller: controller.signInEmailController,
            inputType: TextInputType.emailAddress,
          ),

        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
      ],
    );
  }

  Column passwordField(BuildContext context, AuthController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          height: 45,
          decoration: BoxDecoration(
            border: Border.all(
                color: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .color!
                    .withOpacity(0.06)),
            borderRadius: const BorderRadius.all(
                Radius.circular(Dimensions.paddingSizeExtraSmall)),
          ),
          child: CustomTextField(
            hintText: 'Password',
            controller: controller.signInPasswordController,
            inputType: TextInputType.visiblePassword,
            isPassword: true,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
      ],
    );
  }
}
