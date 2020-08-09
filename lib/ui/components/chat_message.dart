import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {

  ChatMessage(this.data, this.mine);

  final Map<String, dynamic> data;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: [
          !mine ?
            CircleAvatar(
            backgroundImage: NetworkImage(data["senderPhotoUrl"]),
            )
           : Container (),
         Expanded(
           child:  Padding(
             padding: mine ? EdgeInsets.only(right: 16.0) : EdgeInsets.only(left: 16.0),
             child: Column(
                 crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                 children: [
                   Text(data["senderName"], style: TextStyle(
                       color: Colors.grey,
                       fontSize: 13,
                       fontWeight: FontWeight.w500,
                   ),
                     textAlign: mine ? TextAlign.end : TextAlign.start,
                     overflow: TextOverflow.ellipsis,
                   ),
                   data["imgUrl"] != null ?
                   Image.network(data["imgUrl"],
                   width: 250)
                       :
                   Text(data["text"], style: TextStyle(color: Colors.red, fontSize: 16),),
                   //Text(data["sendTime"].toString(), style: TextStyle(color: Colors.grey, fontSize: 10),),
                 ]
             ),
           ),
         ),
          mine ?
          CircleAvatar(
            backgroundImage: NetworkImage(data["senderPhotoUrl"]),
          )
              : Container (),
        ],
      ),
    );
  }
}
