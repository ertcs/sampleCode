import 'dart:async';
import 'dart:io';

import 'package:autoly/app_services/firestoredbservice.dart';
import 'package:autoly/app_services/realtimedbsearvice.dart';
import 'package:autoly/model/car_ad.dart';
import 'package:autoly/sign_in_page_widgets/firebaseauthservice.dart';
import 'package:autoly/ui/adchatwidgets/chat_common_widgets/deletedmsgitemother.dart';
import 'package:autoly/ui/adchatwidgets/chat_common_widgets/deletedmsgitemself.dart';
import 'package:autoly/ui/widgets/setup_dialog_ui.dart';
import 'package:autoly/utilities/theme_const.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:autoly/utilities/common_const.dart';
import 'package:flutter/services.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'chat_common_widgets/chat_file_attachment_items.dart';
import 'chat_common_widgets/chat_input_widget.dart';
import 'chat_common_widgets/online_dot.dart';
import 'chat_common_widgets/others_chat_item.dart';
import 'chat_common_widgets/self_chat_item.dart';
import 'chat_common_widgets/voicemsgplayer.dart';
import 'chat_data_service/chatdataservice.dart';
import 'chat_models/chat_msg_model.dart';
import 'chat_models/chatsessionmodel.dart';
import 'chat_utilites/chat_utilitesNstrings.dart';
import 'chat_common_widgets/chat_image_item.dart';




class ChatPage extends StatefulWidget {
  final ChatSessionModel chatData;
  final MsgContentModel forwardData;

  ChatPage({Key key, @required this.chatData, this.forwardData}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ChatSessionModel chatDataUpdate;
  Stream<ChatSessionModel> chatSessionStream;
  Stream<List<MsgContentModel>> msgDataStream;
  DatabaseReference dbRef;
  String userId = AuthService().currentUser().uid;
  bool isReply = false;
  MsgContentModel replyMsgData;
  String otherUserName = "";
  ScrollController _scrollController = new ScrollController();
  bool isSellerResponded=false;
  bool isFirst = true;
  String otherUserId;

  Future<File> _downloadFile(MsgContentModel msg) async {
    try {
      String dir = (await getApplicationDocumentsDirectory()).path;
      File file = new File('$dir/${msg.content}');
      bool isFileExist = await file.exists();
      if (isFileExist) {
        return file;
      }
      var httpClient = new HttpClient();
      var request = await httpClient.getUrl(Uri.parse(msg.fileUrl));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  void showSnackBarError(String errorMsg) {
    final snackBar = SnackBar(
      content: Text(
        errorMsg,
        style: TextStyle(color: Colors.red, fontSize: 18),
      ),
    );
    ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(snackBar);
  }

  Widget chatItemWithMenu({Size size, Widget child, bool isDownloadable, MsgContentModel msgModel}) {
    List<FocusedMenuItem> menuList = [
      FocusedMenuItem(
          backgroundColor: Color(0xffe4e4e4),
          title: Text(
            entText.reply,
            style: TextStyle(color: Color(0xff5c5c5c), fontWeight: FontWeight.bold),
          ),
          trailingIcon: Icon(
            FontAwesomeIcons.reply,
            color: Color(0xff5c5c5c),
          ),
          onPressed: () {
            isReply = true;
            replyMsgData = msgModel;
            setState(() {});
          }),
      FocusedMenuItem(
          backgroundColor: Color(0xffe4e4e4),
          title: Text(entText.forward, style: TextStyle(color: Color(0xff5c5c5c), fontWeight: FontWeight.bold)),
          trailingIcon: Icon(
            FontAwesomeIcons.share,
            color: Color(0xff5c5c5c),
          ),
          onPressed: () {
            Navigator.pop(context, msgModel);
          }),
      FocusedMenuItem(
          backgroundColor: Color(0xffe4e4e4),
          title:
              Text(isDownloadable ? entText.download : entText.copy, style: TextStyle(color: Color(0xff5c5c5c), fontWeight: FontWeight.bold)),
          trailingIcon: Icon(
            isDownloadable ? Icons.download_rounded : Icons.copy,
            color: Color(0xff5c5c5c),
          ),
          onPressed: () async {
            if (isDownloadable) {
              File downloadFile = await _downloadFile(msgModel);
              if (downloadFile != null) {

                OpenResult result = await OpenFile.open(downloadFile.path);
                switch (result.type) {
                  case ResultType.done:
                    // TODO: Handle this case.
                    break;
                  case ResultType.fileNotFound:
                    showSnackBarError(entText.error_fileNotFound);
                    break;
                  case ResultType.noAppToOpen:
                    showSnackBarError(entText.error_no_app_to_open_file);
                    break;
                  case ResultType.permissionDenied:
                    showSnackBarError(entText.error.permissionDenied);
                    break;
                  case ResultType.error:
                    showSnackBarError(entText.error.unKnowError);
                    break;
                }
              } else {
              
              }
            } else {
              Clipboard.setData(new ClipboardData(text: msgModel.content));
            }
          }),
      FocusedMenuItem(
          backgroundColor: Color(0xffe4e4e4),
          title: Text(
            entText.delete,
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          trailingIcon: Icon(
            Icons.delete,
            color: Colors.redAccent,
          ),
          onPressed: () {
            ChatDataService().deleteUserChatItem(chatId: msgModel.docId);
          }),
    ];

    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: chatDataUpdate.isAllowed
          ? FocusedMenuHolder(
              menuWidth: MediaQuery.of(context).size.width * 0.50,
              blurSize: 5.0,
              menuItemExtent: 45,
              menuBoxDecoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.all(Radius.circular(15.0))),
              duration: Duration(milliseconds: 100),
              animateMenuItems: true,
              blurBackgroundColor: Colors.grey.withOpacity(0.7),
              openWithTap: false,
              menuOffset: 10.0,
              bottomOffsetHeight: 80.0,
              menuItems: menuList,
              child: child,
              onPressed: () {},
            )
          : child,
    );
  }

  showPopupMenu({
    BuildContext context,
    String image,
    String title,
  }) async {
    CarAd carAd = await DBService().getAdCarById(widget.chatData.adDetails.adId);
    await DialogManager.showChatCarDialog(context, image, title, carAd.price.toString(), carAd.description);
  }

  // for voice msg - content = You got a voice msg
  // for attachment - content = Send send you a file
  // for image msg - content = Sender send you a image


  Map<String, dynamic> getReplyData({List<MsgContentModel> listData, String replyMsgId, ChatSessionModel model}) {
    MsgContentModel repliedMsgData;
    String ownerName;

    List<MsgContentModel> repliedMsgDataList = listData.where((element) => element.docId.compareTo(replyMsgId) == 0).toList();
    if (repliedMsgDataList.isNotEmpty) {
      repliedMsgData = repliedMsgDataList[0];
      ownerName = getReplyOwnerName(chatSessionModel: model, fromId: repliedMsgData.fromId);
    } else {
      //TODO: retrieve from firebase
    }

    Map<String, dynamic> data = {
      'data': repliedMsgData,
      'ownerName': ownerName,
    };
    return data;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                assetsImage.chatBackground,
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.transparent,
      
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            brightness: Brightness.light,
            centerTitle: true,
            title: StreamBuilder<ChatSessionModel>(
                stream: chatSessionStream,
                initialData: widget.chatData,
                builder: (context, snapshot) {
                  String currentStatus = '';
                  if (snapshot.hasData) {
                    chatDataUpdate = snapshot.data;
                    currentStatus = getOtherUserTypeStatus(chatSessionModel: chatDataUpdate);
                  }else{
                    chatDataUpdate = widget.chatData;
                  }
                  return StreamBuilder<Event>(
                    stream: dbRef.onValue,
                    builder: (context, snapshot) {
                      bool isOnline = false;
                      if (snapshot.connectionState == ConnectionState.active) {
                        if (snapshot.data.snapshot != null) {
                          if (snapshot.data.snapshot.value != null) {
                            UserRealTimeStatus userStatus = UserRealTimeStatus.fromJson(snapshot.data.snapshot.value);
                            if (currentStatus.isEmpty) {
                              if (userStatus.isOnline) {
                                isOnline = true;
                                currentStatus = entText.online;
                              } else {
                                isOnline = false;
                                currentStatus = getPassedTime(userStatus.lastSeen);
                              }
                            }
                          }
                        }
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            // textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                getOtherUsername(chatSessionModel: chatDataUpdate).getSubString(),
                                style: headline5Style(color: waterBlue,context: context),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10, left: 3),
                                child: OnlineDot(
                                  isOnline: isOnline,
                                ),
                              )
                            ],
                          ),
                          Text(
                            currentStatus,
                            style: TextStyle(
                              color: grayColor,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }),
            leading: InkWell(
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.arrow_back_ios,
                color: waterBlue,
                size: 25,
              ),
            ),

          ),
          body: StreamBuilder<List<MsgContentModel>>(
            stream: msgDataStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active){
                if (snapshot.hasData && snapshot.data.length > 0){
                  isFirst = snapshot.data.length==0;
                  isSellerResponded = snapshot.data.length>1;

                  // isSellerResponded = snapshot.data.where((element) => element.fromId.compareTo(otherUserId)==0).toList().isNotEmpty;

                }
              }
              return Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  // ad detail container
                  InkWell(
                    onTap: () {
                      showPopupMenu(
                        context: context,
                        image: chatDataUpdate.adDetails.adImage,
                        title: chatDataUpdate.adDetails.adTitle,
                      );
                    },
                    child: Container(
                      height: 80,
                      width: MediaQuery.of(context).size.width * 0.9,
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        //  border: Border.all(color: grayColor),
                        color: Colors.white54,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          CachedNetworkImage(
                            imageUrl: chatDataUpdate.adDetails.adImage,
                            width: 50,
                            height: 60,
                            fit: BoxFit.fill,
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  chatDataUpdate.adDetails.adTitle,
                                  style: subTitle1Style(context: context,color: duskTwo),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Text(entText.adDiscription_hint,
                                        style: captionTextStyle(context: context,color: Colors.black),
                                        maxLines: 6,
                                        textAlign: TextAlign.left,overflow: TextOverflow.ellipsis,),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // chat list
                  Expanded(
                    child: snapshot.data!=null&&snapshot.data.length > 0?
                    Padding(
                      padding: const EdgeInsets.only(right: 10, left: 6, bottom: 0),
                      child: ListView.builder(
                        controller: _scrollController,
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: snapshot.data.length,
                        reverse: true,
                        itemBuilder: (context, index) {
                          MsgContentModel msgModel = snapshot.data[index];
                          ChatDataService().updateMsgReadStatus(model: msgModel);
                          Map<String, dynamic> data = msgModel.isReplied
                              ? getReplyData(
                              listData: snapshot.data, replyMsgId: msgModel.replyMsgId, model: chatDataUpdate)
                              : null;
                          if (msgModel.fromId.compareTo(userId) == 0) {
                            if (msgModel.isDeleted) {
                              return SelfDeletedMsg();
                            }
                            switch (msgModel.messageType) {
                              case 0:
                                {
                                  return chatItemWithMenu(
                                    size: size,
                                    child: SelfChatItem(
                                      msgData: msgModel,
                                      repliedData: data,
                                    ),
                                    isDownloadable: false,
                                    msgModel: msgModel,
                                  );
                                }
                                break;
                              case 1:
                                {
                                  return chatItemWithMenu(
                                      size: size,
                                      child: ChatImageSelf(
                                        imageUrl: msgModel.fileUrl,
                                        isUploading: msgModel.isUploading,
                                        repliedData: data,
                                      ),
                                      isDownloadable: true,
                                      msgModel: msgModel);
                                }
                                break;
                              case 2:
                                {
                                  return chatItemWithMenu(
                                      size: size,
                                      child: SelfFileAttachmentItem(
                                        fileName: msgModel.content,
                                        downloadUrl: msgModel.fileUrl,
                                        repliedData: data,
                                      ),
                                      isDownloadable: true,
                                      msgModel: msgModel);
                                }
                                break;
                              case 3:
                                {
                                  return VoiceMsgPlayer(
                                    timeStamp: msgModel.timeStamp,
                                    isMe: true,
                                    audioUrl: msgModel.fileUrl,
                                  );
                                }
                                break;
                              default:
                                return chatItemWithMenu(
                                    size: size,
                                    child: SelfChatItem(
                                      msgData: msgModel,
                                    ),
                                    isDownloadable: false,
                                    msgModel: msgModel);
                            }
                          } else {
                            if (msgModel.isDeleted) {
                              return OtherDeletedMsgItem(
                                msgData: msgModel,
                              );
                            }
                            switch (msgModel.messageType) {
                              case 0:
                                {
                                  return chatItemWithMenu(
                                      size: size,
                                      child: OthersChatItem(
                                        msgData: msgModel,
                                        repliedData: data,
                                      ),
                                      isDownloadable: false,
                                      msgModel: msgModel);
                                }
                                break;
                              case 1:
                                {
                                  return chatItemWithMenu(
                                      size: size,
                                      child: ChatImageOther(
                                          isUploading: msgModel.isUploading,
                                          imageUrl: msgModel.fileUrl,
                                          hasRead: msgModel.hasRead,
                                          timeStamp: msgModel.timeStamp,
                                          repliedData: data),
                                      isDownloadable: true,
                                      msgModel: msgModel);
                                }
                              case 2:
                                {
                                  return chatItemWithMenu(
                                      size: size,
                                      child: OtherFileAttachmentItem(
                                        fileName: msgModel.content,
                                        hasRead: msgModel.hasRead,
                                        timeStamp: msgModel.timeStamp,
                                        repliedData: data,
                                      ),
                                      isDownloadable: true,
                                      msgModel: msgModel);
                                }
                                break;
                              case 3:
                                {
                                  return VoiceMsgPlayer(
                                    timeStamp: msgModel.timeStamp,
                                    isMe: false,
                                    audioUrl: msgModel.fileUrl,
                                  );
                                }
                                break;
                              default:
                                return chatItemWithMenu(
                                  size: size,
                                  child: OthersChatItem(
                                    msgData: msgModel,
                                  ),
                                  isDownloadable: false,
                                  msgModel: msgModel,
                                );
                            }
                          }
                        },
                      ),
                    ):Container(
                      child: Center(
                        child: Text(
                          entText.start_conversation,
                          style: TextStyle(fontSize: 21, color: grayColor),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(left: 4, right: 4),
                      child:  ChatInputWidget(
                        isFirst: isFirst,
                        isSellerResponded: isSellerResponded,
                        chatData: chatDataUpdate,
                        isReply: isReply,
                        msgData: replyMsgData,
                        msgOwnerName: replyMsgData?.fromId?.compareTo(AuthService().currentUser().uid) == 0
                            ? "You"
                            : getOtherUsername(chatSessionModel: chatDataUpdate).getSubString(),
                        cancelReply: () {
                          isReply = false;
                          setState(() {});
                        },
                        isAllowed: chatDataUpdate.isAllowed,
                      )
                  ),


                ],
              );
            }
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    updateUserOnlineStatus();
    chatDataUpdate = widget.chatData;
    otherUserId = getOtherUserUID(chatSessionModel: chatDataUpdate);
    dbRef = userOnlineStatus(userId:otherUserId);
    chatSessionStream = ChatDataService().chatSessionStream(docId: chatDataUpdate.docId);
    msgDataStream = ChatDataService().msgDataStream(messageId: chatDataUpdate.docId);
    if (widget.forwardData != null) {
      ChatDataService().sendForwardMsg(chatSessionModel: chatDataUpdate, forwardData: widget.forwardData);
    }

    super.initState();
  }
}