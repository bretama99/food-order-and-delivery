// import "package:dart_amqp/dart_amqp.dart";
// import 'package:flutter/material.dart';
// class AmqpTest extends StatefulWidget {
//   const AmqpTest({Key? key}) : super(key: key);
//   @override
//   State<AmqpTest> createState() => _AmqpTestState();
// }
//
// class _AmqpTestState extends MountedState<AmqpTest> {
//   Client client = Client();
//   @override
//   Future<void> initState() async {
//     ConnectionSettings settings = ConnectionSettings(
//         host: "192.168.0.108:8092",
//         authProvider: PlainAuthenticator("user", "pass")
//     );
//     Client client = Client(settings: settings);
//     Channel channel = await client.channel();
//     Exchange exchange = await channel.exchange("logs", ExchangeType.FANOUT);
//     exchange.publish("Testing 1-2-3", null);
//     client.close();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body:
//         Padding(padding: EdgeInsets.only(top: 50),child: Text("AAAAAAAAAAAAA")));
//   }
//
//
//
// }
//
