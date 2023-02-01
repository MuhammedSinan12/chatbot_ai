import 'dart:async';

import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

import 'chatmessage.dart';
import 'threedots.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  ChatGPT? chatGPT;

  StreamSubscription? _subscription;

  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    chatGPT = ChatGPT.instance;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _sendmessage() {
    ChatMessage message = ChatMessage(text: _controller.text, sender: "User");
    setState(() {
      _messages.insert(0, message);
      _isTyping = true;
    });
    _controller.clear();

    final request = CompleteReq(
        prompt: message.text, model: kTranslateModelV3, max_tokens: 200);
    _subscription = chatGPT!
        .builder("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",
            orgId: "")
        .onCompleteStream(request: request)
        .listen((response) {
      Vx.log(response!.choices[0].text);
      ChatMessage botMessage =
          ChatMessage(text: response!.choices[0].text, sender: "bot");

      setState(() {
        _isTyping = false;
        _messages.insert(0, botMessage);
      });
    });
  }

  Widget _buildTextComposer() {
    return Row(
      children: [
        Expanded(
            child: TextField(
          controller: _controller,
          onSubmitted: (value) => _sendmessage(),
          decoration:
              const InputDecoration.collapsed(hintText: "Send a message"),
        )),
        IconButton(
            onPressed: () => _sendmessage(), icon: const Icon(Icons.send))
      ],
    ).px16();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Chat GPT"),
      ),
      body: SafeArea(
        child: Column(children: [
          Flexible(
              child: ListView.builder(
            reverse: true,
            padding: Vx.m8,
            itemCount: _messages.length,
            itemBuilder: ((context, index) {
              return _messages[index];
            }),
          )),
          if (_isTyping) const ThreeDots(),
          const Divider(
            height: 1.00,
          ),
          Container(
            decoration: BoxDecoration(color: context.cardColor),
            child: _buildTextComposer(),
          )
        ]),
      ),
    );
  }
}
