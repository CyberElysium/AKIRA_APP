import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/buttons/primary_button.dart';
import 'error_messages.dart';
import 'settings.dart';

class Alerts {
  static void showMessageForResponse(BuildContext context, response,
      {String title = "Oops!",
      String button = "OK",
      Function? onCloseCallback}) {
    String? message = ErrorMessages.getErrorMessage(response: response);
    showMessage(context, message!,
        title: title, button: button, onCloseCallback: onCloseCallback);
  }

  static void showMessage(BuildContext context, String message,
      {String title = "Oops!",
      String button = "OK",
      Function? onCloseCallback}) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                  topLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          title == "Oops!"
                              ? const Icon(
                                  Icons.warning_rounded,
                                  color: Colors.amber,
                                )
                              : const Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.green,
                                ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            title,
                            style: const TextStyle(
                                color: textFieldMain, fontSize: 20),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        message,
                        style: const TextStyle(
                          color: gray,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      const SizedBox(
                        height: 45.0,
                        // child: RaisedButton(
                        //   shape: RoundedRectangleBorder(
                        //     borderRadius: BorderRadius.circular(100),
                        //   ),
                        //   onPressed: () => onCloseCallback == null
                        //       ? Navigator.of(context).pop()
                        //       : onCloseCallback(),
                        //   padding: const EdgeInsets.all(10),
                        //   color: primaryButtonColor,
                        //   child: Text(
                        //     button,
                        //     style: const TextStyle(
                        //         color: primaryButtonTextColor),
                        //   ),
                        // ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  static void showGuestMessage(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                  topLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Icons.person_rounded,
                                color: Colors.blueAccent,
                                size: 20,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                "Guest Alert!",
                                style: TextStyle(
                                    color: gray,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 18),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: const Icon(
                              Icons.close_outlined,
                              color: gray,
                              size: 20,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        "Would you like to explore more...",
                        style: TextStyle(
                          color: gray,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      SizedBox(
                        height: 40.0,
                        child: PrimaryButton(
                            clickCallback: () async {
                              await Settings.setIsGuest(false);
                              Navigator.pushNamed(context, '/LoginScreen');
                            },
                            text: "Login"),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }
}
