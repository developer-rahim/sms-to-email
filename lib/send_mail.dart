import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:sms_forward/provider/auth_provider.dart';
import 'package:sms_forward/provider/provider.dart';
import 'google_signIn.dart';
import 'loginPage.dart';

class EmailSender extends StatefulWidget {
  const EmailSender({Key? key}) : super(key: key);

  @override
  State<EmailSender> createState() => _EmailSenderState();
}

class _EmailSenderState extends State<EmailSender> {
  SmsQuery query = SmsQuery();
  late List<SmsMessage> messages = [];
  late List<SmsMessage> newMessages = [];
  int? timeStamp;
  late List<String> toEmail = [];
  String messageBody = "";
  bool isSent = false;
  String status = "Loading......";
  Timer? timer;

  int START_SERVICE = 0;

  Future<void> startService() async {
    if (Platform.isAndroid) {
      var methodChannel = MethodChannel("com.example.messages");
      String data = await methodChannel.invokeMethod("startService");
      debugPrint(data);
    }
  }

  

  @override
  void initState() {
    AuthController authController = Provider.of(context, listen: false);
        Controller controller = Provider.of(context, listen: false);
    controller.background();
    Timer.periodic(Duration(minutes: 50), (timer) {
      authController.refreshToken();
      // setState(() {
      //   START_SERVICE++;
      //   print('aaaaa$START_SERVICE');
      // });
    });

    super.initState();

    loadData().then((value) {
      timer = Timer.periodic(const Duration(seconds: 10), (Timer t) {
        // setState(() {
        //   START_SERVICE++;
        //   print('aaaaa$START_SERVICE');
        // });
        if (toEmail.isNotEmpty) {
          loadData();
        }
      });
    });
  }

  loadData() async {

    
    print('bbbbbbbb');
    final prefs = await SharedPreferences.getInstance();
    timeStamp = prefs.getInt('time');
    toEmail = prefs.getStringList('email') ?? [];
    messages = await query.querySms(
      kinds: [SmsQueryKind.inbox],
    );
    messageBody = "";
    if (toEmail.isEmpty) {
      await addEmailDialog(context);
      return;
    }
    if (timeStamp == null) {
      /// Check all sms first time
      newMessages = [];
      for (int i = 0; i < messages.length; i++) {
        newMessages.add(messages[i]);
        messageBody = "$messageBody\n----------------------------------------"
            "\n${messages[i].sender}--\n${messages[i].body}\n${messages[i].date!.toString()}";
      }
    } else {
      /// Check new sms
      newMessages = [];
      for (int i = 0; i < messages.length; i++) {
        if (messages[i]
                .date!
                .compareTo(DateTime.fromMillisecondsSinceEpoch(timeStamp!)) ==
            1) {
          newMessages.add(messages[i]);
          messageBody = "$messageBody\n----------------------------------------"
              "\n${messages[i].sender}\n${messages[i].body}\n${messages[i].date!.toString()}";
        }
      }
    }
    setState(() {
      status = "New sms found: " + newMessages.length.toString();
      isSent = newMessages.isEmpty;
    });
    await sendNewSms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: Drawer(
          child: ListView(children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                userC.displayName,
                style: const TextStyle(color: Colors.white),
              ),
              accountEmail: ListView.builder(
                itemCount: toEmail.length,
                itemBuilder: (BuildContext context, int index) {
                  return Text(
                    toEmail.elementAt(index),
                    style: const TextStyle(color: Colors.white),
                  );
                },
              ),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(userC.photoURL),
              ),
              decoration: const BoxDecoration(color: Colors.blueGrey),
            ),
            ListTile(
              title: const Text('Edit Email'),
              leading: const Icon(Icons.email),
              onTap: () {
                addEmailDialog(context);
              },
            ),
            ListTile(
              title: const Text('About Us'),
              leading: const Icon(Icons.info_outline_rounded),
              onTap: () {
                aboutDialog(context);
              },
            ),
            ListTile(
              title: const Text('Support'),
              leading: const Icon(Icons.contact_support_outlined),
              onLongPress: () {},
            ),
            ListTile(
              title: const Text('Logout'),
              leading: const Icon(Icons.logout),
              onTap: () async {
                await GoogleAuthApi.signOut();
                SystemChannels.platform.invokeMethod('SystemNavigator.pop');
              },
            ),
            ListTile(
                title: const Text('Close'),
                leading: const Icon(Icons.close),
                onTap: () {
                  Navigator.of(context).pop();
                }),
          ]),
        ),
        appBar: AppBar(
          title: const Text('Sms to Email'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.email,
                size: 30,
              ),
              onPressed: () async {
                await addEmailDialog(context);
              },
            ),
          ],
        ),
        body: Center(
          child: Container(
              height: MediaQuery.of(context).size.height / 3,
              width: MediaQuery.of(context).size.width / 1.2,
              decoration: BoxDecoration(
                  color: Colors.lightBlueAccent,
                  borderRadius: BorderRadius.circular(20)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  isSent
                      ? const Icon(
                          Icons.done_outline,
                          size: 50,
                          color: Colors.greenAccent,
                        )
                      : const CircularProgressIndicator(),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    status,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  )
                ],
              )),
        ));
    // child: ListView.builder(
    //     shrinkWrap: true,
    //     //  physics: NeverScrollableScrollPhysics(),
    //     itemCount: newMessages.length,
    //     itemBuilder: (context, index) {
    //       return Column(
    //         mainAxisAlignment: MainAxisAlignment.start,
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [
    //           ListTile(
    //             title: Text(newMessages[index].sender.toString()),
    //             subtitle: Text(newMessages[index].body.toString()),
    //             trailing: Icon(
    //               Icons.cloud_done,
    //               color: isSent ? Colors.blue : Colors.blueGrey,
    //             ),
    //             // tileColor: Colors.greenAccent,
    //           ),
    //           Divider(
    //             thickness: 2,
    //           )
    //         ],
    //       );
    //     })));
  }

  Future<void> sendNewSms() async {
    if (messageBody.isNotEmpty) {
      /// Send sms here
      await sendEmail('SMS from App', toEmail, 'New SMS', messageBody);
    }
  }

  Future sendEmail(
    String title,
    List toEmail,
    String subject,
    String body,
  ) async {
    final smtpServer = gmailSaslXoauth2(email!, token!);
    final message = Message()
      ..from = Address(email!, title)
      ..recipients = toEmail
      ..subject = subject
      ..text = body;

    try {
      await send(message, smtpServer).then((value) async {
        final prefs = await SharedPreferences.getInstance();
        showSnackBar(context, "Email sent SuccessFully");
        timeStamp = messages[0].date!.millisecondsSinceEpoch;
        await prefs.setInt('time', timeStamp!);
        isSent = true;
        status = newMessages.length.toString() + " new sms sent successfully";
        setState(() {});
      });
    } on MailerException catch (e) {
      showSnackBar(context, "Email sent failed" + e.message);
    }
  }

  Future<void> addEmailDialog(BuildContext context) async {
    final controller1 = TextEditingController();
    final controller2 = TextEditingController();
    final controller3 = TextEditingController();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Receiver Email Address'),
          actions: [
            MaterialButton(
              elevation: 0,
              minWidth: MediaQuery.of(context).size.width / 4,
              height: 40,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              onPressed: () async {
                toEmail = [];
                controller1.text.isNotEmpty
                    ? toEmail.add(controller1.text)
                    : '';
                controller2.text.isNotEmpty
                    ? toEmail.add(controller2.text)
                    : '';
                controller3.text.isNotEmpty
                    ? toEmail.add(controller3.text)
                    : '';
                if (toEmail.isNotEmpty) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setStringList('email', toEmail);
                  setState(() {});
                  Navigator.of(context).pop();
                  showSnackBar(context, "Receiver Email added");
                  loadData();
                } else {
                  showSnackBar(context, "At least one email require");
                }
              },
              color: Colors.blue,
              child: const Text("Save"),
              textColor: Colors.white,
            ),
            MaterialButton(
              elevation: 0,
              minWidth: MediaQuery.of(context).size.width / 4,
              height: 40,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              onPressed: () {
                if (timeStamp == null) {
                  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                }
                Navigator.of(context).pop();
              },
              color: Colors.blue,
              child: const Text("Cancel"),
              textColor: Colors.white,
            ),
          ],
          content: SizedBox(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height - 550,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                      hintText: 'ex: exaple@gmail.com',
                      labelText: "Enter Email Address 1",
                      border: OutlineInputBorder()),
                  controller: controller1,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                      hintText: 'ex: exaple@gmail.com',
                      labelText: "Enter Email Address 2",
                      border: OutlineInputBorder()),
                  controller: controller2,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                      hintText: 'ex: exaple@gmail.com',
                      labelText: "Enter Email Address 3",
                      border: OutlineInputBorder()),
                  controller: controller3,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        message,
      ),
      duration: const Duration(seconds: 6),
      backgroundColor: Colors.blue,
      action: SnackBarAction(
        label: 'Ok',
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    ));
  }

  Future<void> aboutDialog(BuildContext context) async {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          titlePadding: const EdgeInsets.all(0),
          actionsPadding: const EdgeInsets.all(0),
          buttonPadding: const EdgeInsets.all(0),
          insetPadding: const EdgeInsets.all(0),
          contentPadding: const EdgeInsets.all(10),
          title: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.close,
              color: Colors.redAccent,
            ),
            alignment: Alignment.topRight,
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height - 400,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaterialButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  color: Colors.white70,
                  elevation: 0,
                  child: const Text(
                    "SMS to Email",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {},
                ),
                const SizedBox(
                  height: 20,
                ),
                MaterialButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  color: Colors.white70,
                  elevation: 0,
                  child: const Text(
                    'DevInfo',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {},
                ),
                TextField(
                    controller:
                        TextEditingController(text: "liotauhid@gmail.com")),
                TextField(
                    controller: TextEditingController(
                        text: "https://github.com/lioTauhid/")),
                TextField(
                    controller: TextEditingController(
                        text:
                            "https://www.linkedin.com/in/md-tauhid-5861b8140/")),
              ],
            ),
          ),
        );
      },
    );
  }
}
