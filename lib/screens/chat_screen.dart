import 'package:com.agrobs/helpers/current_user.dart';
import 'package:com.agrobs/providers/languages.dart';
import 'package:com.agrobs/screens/color_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// import 'package:intl/intl.dart' as intl;

import '../widgets/messages.dart';
import '../widgets/new_message.dart';

class ChatScreen extends StatefulWidget {
  static const routeName = '/chat';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late String fromUserId;

  @override
  Widget build(BuildContext context) {
    final Map pushedMap = ModalRoute.of(context)!.settings.arguments as dynamic;
    fromUserId = pushedMap['from_user_id'];
    final fromUserName = pushedMap['from_user_fullname'];
    void _showModelSheet(BuildContext context) {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: EdgeInsets.symmetric(
              vertical: 8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: ListTile(
                    leading: Icon(Icons.music_note, color: Colors.amber),
                    title: Text('Tips for a safe deal'),
                    onTap: () {
                      // Handle Home tap
                      Navigator.pop(context);
                    },
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.flag),
                  title: Text(
                      'Be safe, take necessary precautions while meeting with buyers and sellers'),
                  onTap: () {
                    // Handle Home tap
                    Navigator.pop(context);
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.money),
                  title: Text('Do not enter UPI PIN while receiving money'),
                  onTap: () {
                    // Handle Work tap
                    Navigator.pop(context);
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.real_estate_agent_rounded),
                  title: Text('Never give money or product in advance'),
                  onTap: () {
                    // Handle School tap
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.flag),
                  title: Text('Report suspicious users to OLX'),
                  onTap: () {
                    // Handle School tap
                    Navigator.pop(context);
                  },
                ),
                Divider(),
                InkWell(
                  onTap: () {
                    // Handle School tap
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: EdgeInsets.all(10),
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: HexColor(),
                    ),
                    child: Center(
                      child: Text(
                        'Continue to chat'
                        // Provider.of<Languages>(context).selected['LOG IN']!
                        ,
                        textDirection: CurrentUser.textDirection,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.grey[800], //change your color here
        ),
        title: ListTile(
          leading: CircleAvatar(
            foregroundImage: NetworkImage(
              pushedMap['from_user_picture'] ??
                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRWmwCfIZexKkZuFni_fnWvm8mkOTzoRtlqgQ&usqp=CAU",
            ),
          ),
          title: Text(
            fromUserName,
            style: TextStyle(
              color: Colors.grey[800],
            ),
            // textDirection: CurrentUser.textDirection,
          ),
          subtitle: Text(pushedMap['status'] ?? ""),
        ),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_horiz,
            ),
            onPressed: () {
              _showModelSheet(context);
            },
          ),
        ],
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Messages(
                fromUserId: fromUserId,
              ),
            ),
          ),
          NewMessage(fromUserId: fromUserId),
        ],
      ),
    );
  }
}
