import 'dart:developer';

import '../../models/messages.dart';
import '../../services/realtime_db_service.dart';
import 'receiver_row_widget.dart';
import 'sender_row_view.dart';
import '../../view_model/chat_view_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatListView extends StatefulWidget {
  const ChatListView({Key? key, required this.scrollController})
      : super(key: key);

  final ScrollController scrollController;

  @override
  State<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ChatViewModel>(
      builder: (context, value, child) => FirebaseDatabaseQueryBuilder(
        query: RealtimeDBService()
            .db
            .ref('messages/${value.getSelectedConversation.id}'),
        pageSize: 20,
        builder: (context, snapshot, child) {
          if (snapshot.hasError) {
            return Text('error ${snapshot.error}');
          }

          List<Message> messagesList = _parseMessages(snapshot.docs, value);

          return ListView.builder(
            controller: widget.scrollController,
            reverse: true,
            itemCount: snapshot.docs.length,
            itemBuilder: (context, index) {
              if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
                snapshot.fetchMore();
              }
              widget.scrollController.addListener(() {
                if (widget.scrollController.position.pixels ==
                    widget.scrollController.position.maxScrollExtent) {
                  snapshot.fetchMore();
                  log('load more()');
                }
              });

              return messagesList[index].isSender
                  ? SenderRowView(messageData: messagesList[index])
                  : ReceiverRowView(messageData: messagesList[index]);
            },
          );
        },
      ),
    );
  }

  List<Message> _parseMessages(List<DataSnapshot> docs, ChatViewModel value) {
    List<Message> messagesList = [];
    if (docs.isNotEmpty) {
      for (DataSnapshot doc in docs) {
        final mapOfData = Map<String, dynamic>.from(doc.value as Map);
        Message parsedMessage = Message.fromJson(mapOfData);

        final isSender = parsedMessage.sentBy == value.user!.uid;

        parsedMessage = parsedMessage.copyWith(isSender: isSender);

        if (!isSender && !parsedMessage.seenBy.contains(value.user!.uid)) {
          value.markMessageAsRead(parsedMessage);
        }

        messagesList.add(parsedMessage);
      }
    }
    messagesList.sort((a, b) => DateTime.fromMillisecondsSinceEpoch(b.sentAt)
        .compareTo(DateTime.fromMillisecondsSinceEpoch(a.sentAt)));
    return messagesList;
  }
}
