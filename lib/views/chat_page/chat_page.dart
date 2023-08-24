import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitist/model/user_profile.dart';
import 'package:fitist/providers/chat.dart';
import 'package:fitist/services/user_profile_service.dart';
import 'package:fitist/views/chat_page/announcement_widget.dart';
import 'package:fitist/views/chat_page/chat_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  final String uid;

  ChatPage({Key key, @required this.uid}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _loadingThreshold = 100; // px

  final _focusNode = FocusNode();
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  ChatNotifier _chatNotifier;
  StreamSubscription _streamSubscription;
  Map<int, Message> _messages = {};
  int _timestamp;
  Map<String, UserProfileModel> _profiles = {};
  bool _loading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _timestamp = DateTime.now().millisecondsSinceEpoch;

    _setNewMsgListener();

    // setup scroll callback to retrieve old chats
    _scrollController.addListener(() {
      var threshold =
          _scrollController.position.maxScrollExtent - _loadingThreshold;

      if (_scrollController.position.pixels > threshold) {
        if (_loading || !_hasMore) return;
        _retrieveData();
      }
    });

    _loadUserProfiles();
  }

  void _setNewMsgListener() {
    _chatNotifier = Provider.of<ChatNotifier>(context, listen: false);
    _streamSubscription =
        _chatNotifier.getChatStream(widget.uid).listen((chat) {
      setState(() {
        _messages[chat.id] = chat;
      });
      _animateToBottom();
    });
    _retrieveData();
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  Future<void> _loadUserProfiles() async {
    // load user profiles for avatars
    final selfUid = FirebaseAuth.instance.currentUser.uid;
    _profiles[selfUid] = await UserProfileService.get(selfUid);
    _profiles[widget.uid] = await UserProfileService.get(widget.uid);
    setState(() {});
  }

  /// retrieve previous chats in batch of 20 from sqlite
  Future<void> _retrieveData() async {
    setState(() {
      _loading = true;
    });
    final chats = await _chatNotifier.retrieveChats(widget.uid, _timestamp, 20);
    setState(() {
      // update chat map
      chats.forEach((chat) {
        _messages[chat.id] = chat;
      });
      // update timestamp for next retrieval
      _timestamp =
          chats.fold(_timestamp, (prev, chat) => min(prev, chat.timestamp));

      if (chats.length < 20) {
        _hasMore = false;
      }

      _loading = false;
    });
  }

  void _animateToBottom() => _scrollController.animateTo(0,
      duration: Duration(milliseconds: 500), curve: Curves.ease);

  void _sendChat() {
    _focusNode.requestFocus();
    if (_textController.text.isEmpty) return;
    _chatNotifier.sendChat(widget.uid, _textController.text);
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _profiles[widget.uid]?.displayName ?? '',
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            buildChatHistory(),
            buildChatControl(),
          ],
        ),
      ),
    );
  }

  Widget buildChatHistory() {
    final messages = _messages.values.toList();
    messages.sort((a, b) => b.timestamp - a.timestamp);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ListView.builder(
          itemBuilder: (context, index) {
            // extra padding on the top and bottom of all messages
            if (index == 0 || index == messages.length + 1)
              return Container(height: 10);

            final msg =
                messages[index - 1]; // index-1 adjusts for padding index
            switch (msg.messageType) {
              case MessageType.Announcement:
                return AnnouncementWidget(
                  key: Key(msg.id.toString()),
                  message: msg,
                );
              case MessageType.Text:
                return ChatWidget(
                  key: Key(msg.id.toString()),
                  message: msg,
                );
              default:
                return Container();
            }
          },
          itemCount: messages.length + 2, // +2 for padding container
          reverse: true,
          controller: _scrollController,
        ),
      ),
    );
  }

  Widget buildChatControl() {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height / 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Color.fromARGB(30, 100, 100, 100),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, -2))
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      child: TextField(
        focusNode: _focusNode,
        controller: _textController,
        onTap: _animateToBottom,
        onSubmitted: (value) => _sendChat(),
        maxLines: null,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          suffixIcon: IconButton(
            padding: EdgeInsets.only(right: 10),
            icon: Icon(Icons.send),
            color: Theme.of(context).primaryColor,
            onPressed: () => _sendChat(),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
