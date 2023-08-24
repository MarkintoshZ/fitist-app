import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final store = FirebaseFirestore.instance;
final auth = FirebaseAuth.instance;

const tableChat = 'chat';
const columnId = 'id';
const columnUid = 'uid';
const columnUidFrom = 'uidFrom'; // for firestore only
const columnUidTo = 'uidTo'; // for firestore only
const columnMsgType = 'msgType';
const columnContent = 'content';
const columnTimestamp = 'timestamp';
const columnStatus = 'status';

enum ChatStatus {
  Sending,
  Sent,
  SendFailed,
  Received,
}

enum MessageType {
  Text,
  File,
  Announcement, // e.g. friend added hint text
}

class Message {
  final int id;
  final String uid;
  final MessageType messageType;
  final String content;
  final int timestamp;
  final ChatStatus status;

  Message({
    int id,
    @required this.uid,
    @required this.messageType,
    @required this.content,
    @required this.timestamp,
    @required this.status,
  }) : this.id = id ?? Random.secure().nextInt(4294967295); // 2^32 - 1

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      columnId: id,
      columnUid: uid,
      columnMsgType: messageType.index,
      columnContent: content,
      columnTimestamp: timestamp,
      columnStatus: status.index,
    };
  }

  Message.fromMap(Map<String, dynamic> map)
      : id = map[columnId],
        uid = map[columnUid],
        messageType = MessageType.values[map[columnMsgType]],
        content = map[columnContent],
        timestamp = map[columnTimestamp],
        status = ChatStatus.values[map[columnStatus]];

  /// Convert message into ready-to-send map object to other user
  Map<String, dynamic> toFirestoreMap() {
    return <String, dynamic>{
      columnId: id,
      columnUidFrom: FirebaseAuth.instance.currentUser.uid,
      columnUidTo: uid,
      columnMsgType: messageType.index,
      columnContent: content,
      columnTimestamp: FieldValue.serverTimestamp(),
    };
  }

  /// Parse message received from firestore (only used for received messages)
  Message.fromFirestoreMap(Map<String, dynamic> map)
      : id = map[columnId],
        uid = map[columnUidFrom],
        messageType = MessageType.values[map[columnMsgType]],
        content = map[columnContent],
        timestamp = map[columnTimestamp].millisecondsSinceEpoch,
        status = ChatStatus.Received;

  Message copyFrom({
    int id,
    String uid,
    MessageType messageType,
    String content,
    int timestamp,
    ChatStatus status,
  }) {
    return Message(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      messageType: messageType ?? this.messageType,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

/// Helper class for ChatNotifier
class LastUpdateTime {
  static SharedPreferences _pref;
  static int _value;

  static Future<int> getValue() async {
    if (_value == null) {
      _pref ??= await SharedPreferences.getInstance();
      _value = _pref.getInt('chatLastUpdateTime');
    }
    return _value;
  }

  static Future<void> setValue(int v) async {
    _value = v;
    _pref ??= await SharedPreferences.getInstance();
    await _pref.setInt('chatLastUpdateTime', v);
  }
}

/// Wrapper around sqlite for managing chat history
class ChatHistoryDB {
  static Database _db;

  /// Opens the database
  ///
  /// Only needs to call once but can be called multiple times
  /// Running other methods in [ChatHistoryDB] will try to run this method first
  /// if the database is not opened already
  static Future open() async {
    print('open database');
    _db = await openDatabase(
      join(await getDatabasesPath(), 'chat_history.db'),
      version: 2,
      onCreate: (Database db, int version) async {
        print('create database');
        await db.execute('''
          CREATE TABLE $tableChat (
              $columnId INTEGER UNIQUE PRIMARY KEY,
              $columnUid TEXT NOT NULL,
              $columnMsgType INTEGER NULL,
              $columnTimestamp INTEGER NOT NULL,
              $columnStatus INTEGER NOT NULL,
              $columnContent TEXT NOT NULL
          );
          CREATE INDEX idx_ts_uid
          ON $tableChat ($columnUid, $columnTimestamp);
          ''');
      },
    );
    // deleteDatabase(join(await getDatabasesPath(), 'chat_history.db'));
    print('database opened');
  }

  /// Inserts a chat into the database
  static Future<void> insert(Message chat) async {
    if (_db == null) await open();
    await _db.insert(tableChat, chat.toMap());
  }

  /// Retrieves chat by id
  static Future<Message> getChat(int id) async {
    if (_db == null) await open();
    List<Map> maps =
        await _db.query(tableChat, where: '$columnId = ?', whereArgs: [id]);
    if (maps.length > 0) {
      return Message.fromMap(maps.first);
    }
    return null;
  }

  /// Retrieves chats relating to a user
  ///
  /// - uid: user id
  /// - timestamp: query chats before this timestamp
  /// - n: how many chats to retrieve
  static Future<List<Message>> getChats(
      String uid, int timestamp, int n) async {
    if (_db == null) await open();
    List<Map> res = await _db.query(
      tableChat,
      where: '$columnUid == ? and $columnTimestamp <= ?',
      whereArgs: [uid, timestamp],
      orderBy: '$columnTimestamp DESC',
      limit: n,
    );
    if (res.length > 0) {
      return res.map((e) => Message.fromMap(e)).toList(growable: false);
    }
    return [];
  }

  /// Deletes the chat given [id]
  static Future<int> delete(int id) async {
    if (_db == null) await open();
    return await _db.delete(
      tableChat,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  /// Updates the chat
  static Future<int> update(Message chat) async {
    if (_db == null) await open();
    return await _db.update(
      tableChat,
      chat.toMap(),
      where: '$columnId = ?',
      whereArgs: [chat.id],
    );
  }

  /// Deletes the table
  static Future<int> empty() async {
    if (_db == null) await open();
    return await _db.delete(
      tableChat,
      where: '$columnMsgType != ?',
      whereArgs: [MessageType.Announcement.index],
    );
  }

  /// Retrieves last chat of all contacts sort by timestamp in descending order
  static Future<List<Message>> getRecentContacts() async {
    if (_db == null) await open();
    final res = await _db.query(
      tableChat,
      groupBy: columnUid,
      orderBy: columnTimestamp,
    );
    return res
        .reversed
        .map((e) => Message.fromMap(e))
        .toList(growable: false);
  }

  /// Close db connection
  static Future close() async {
    await _db.close();
    // TODO: check if _db is null after close, if not, manually set to null
  }
}

class ChatHistoryService {
  static final deletionThreshold = 20;
  StreamController<Message> _streamController;
  EventSink _sink;
  Stream<Message> stream;

  ChatHistoryService() {
    _streamController = StreamController();
    _sink = _streamController.sink;
    stream = _streamController.stream.asBroadcastStream();

    final uid = auth.currentUser.uid;
    store
        .doc('/Users/$uid/Chats/0')
        .snapshots()
        .asyncMap(_unpackSnapshot)
        .expand((messages) => messages)
        .listen((msg) async {
      print('message received from firestore');
      // dispatch actions
      switch (msg.messageType) {
        case MessageType.File: // TODO: save file
        case MessageType.Text:
        case MessageType.Announcement:
          _sink.add(msg);
          ChatHistoryDB.insert(msg);
          break;
      }
    });
  }

  Future<List<Message>> _unpackSnapshot(DocumentSnapshot doc) async {
    if (!doc.exists) return <Message>[];
    final map = doc.data();
    final chats = map.values.map((v) => Message.fromFirestoreMap(v)).toList();
    // 1. filter for new chats
    final lastUpdateTime = (await LastUpdateTime.getValue()) ?? 0;
    final newChats =
        chats.where((chat) => chat.timestamp > lastUpdateTime).toList();
    // 2. update lastUpdateTime
    final t = newChats.fold(Timestamp.now().millisecondsSinceEpoch,
        (int prev, chat) => max(prev, chat.timestamp));
    await LastUpdateTime.setValue(t);
    // 3. Delete old chats
    // filter out the new chats
    map.removeWhere((_, value) =>
        Message.fromFirestoreMap(value).timestamp > lastUpdateTime);
    // delete chats in firestore if it contains more than 30 messages
    if (map.length > 30) {
      _deleteChats(map.keys.toList(growable: false));
    }
    return newChats;
  }

  Future _deleteChats(List<String> ids) {
    final uid = auth.currentUser.uid;
    final update = Map<String, dynamic>.fromIterable(ids,
        value: (_) => FieldValue.delete());
    return store.doc('/Users/$uid/Chats/0').update(update);
  }

  Future<List<Message>> retrieveChats(String uid, int timestamp, int n) async {
    return ChatHistoryDB.getChats(uid, timestamp, n);
  }

  Future<void> sendChat(String uidTo, String content, MessageType type) async {
    Message chat = Message(
        uid: uidTo,
        messageType: type,
        content: content,
        timestamp: Timestamp.now().millisecondsSinceEpoch,
        status: ChatStatus.Sending);

    // add chat to SQL
    await ChatHistoryDB.insert(chat);
    _sink.add(chat);

    try {
      await store.doc('/Users/$uidTo/Chats/0').set(
          {chat.id.toString(): chat.toFirestoreMap()}, SetOptions(merge: true));
      chat = chat.copyFrom(status: ChatStatus.Sent);
      print('Chat sent successfully');
    } catch (e) {
      // change status to send failed
      chat = chat.copyFrom(status: ChatStatus.SendFailed);
      print('Failed to send chat: $e');
    } finally {
      await ChatHistoryDB.update(chat);
      _sink.add(chat);
    }
  }

  Future<List<Message>> retrieveRecentContacts() async {
    return ChatHistoryDB.getRecentContacts();
  }
}

class ChatNotifier extends ChangeNotifier {
  ChatHistoryService _service;

  ChatNotifier() {
    _service = ChatHistoryService();
  }

  Stream<Message> getChatStream(String uid) =>
      _service.stream.takeWhile((chat) => chat.uid == uid);

  Future<List<Message>> retrieveChats(String uid, int timestamp, int n) {
    return _service.retrieveChats(uid, timestamp, n);
  }

  Future<void> sendChat(String uidTo, String msg) {
    return _service.sendChat(uidTo, msg, MessageType.Text);
  }

  Future<void> sendFile(String uidTo, String msg) {
    return _service.sendChat(uidTo, msg, MessageType.File);
  }

  Future<List<Message>> retrieveRecentContacts() {
    return _service.retrieveRecentContacts();
  }
}
