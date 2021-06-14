import * as functions from "firebase-functions";
import * as admin from 'firebase-admin';
admin.initializeApp(functions.config().functions);


export const sendChatNotification  = functions.firestore.document('../{msgId}').onCreate(async(sanpChat,context)=>{

    if (!context.auth){
      return console.log('non authenticte user invoking function')
    }
    console.log('----------------function start--------------------')
    try{
    const doc = sanpChat.data();
  
    const content = doc.content
    const fromId = doc.fromId
    const toId = doc.toId
    const adTitle = doc.adTitle
    const imageUrl = doc.notificationThumbnail;
    const messageId=doc.messageId;
    const docId = sanpChat.id;
    const idNumber = doc.idNumber;
   
    const recInfo = await admin.firestore().collection('users').doc(toId).get();
  
    if(!recInfo.data().isNotificationEnable){
      console.log('notification is slient');
      return null;
    }
  
    const senderInfo = await admin.firestore().collection('users').doc(fromId).get();
    
  
    var mToken = recInfo.data().pushToken;
    const isiOS = recInfo.data().isiOS;
    const userType = recInfo.data().userType;
  
    var iOSPayload = {
      notification: {
        title: adTitle,
        body: content,
        sound:"car_alarm.aiff",
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      },
      data: {
        title: adTitle,
        body: content,
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
        message: content,
        imageUrl:imageUrl,
        notificationType:"chatMsg",
        userName:senderInfo.data().userName,
        userImage:senderInfo.data().imageUrl,
        messageId:messageId,
        docId:docId,
        senderId:fromId,
        msgIdNumber: idNumber,
    },
    };
  
    var androidPayload = {
      data: {
        title: adTitle,
        body: content,
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
        message: content,
        imageUrl:imageUrl,
        notificationType:"chatMsg",
        userName:senderInfo.data().userName,
        userImage:senderInfo.data().imageUrl,
        messageId:messageId,
        docId:docId,
        senderId:fromId,
        msgIdNumber: idNumber,
    },
    };
  
    if(userType===1){
      console.log('notification sent to topic');
      return await admin.fcm.sendToTopic(toId,androidPayload);
    }
  
    
     if(isiOS){
      console.log('notification sent to ios device');
      return await admin.fcm.sendToDevice(mToken,iOSPayload);
     }
     console.log('notification sent to android device');
     return await admin.fcm.sendToDevice(mToken,androidPayload);
  
    }catch(e){
      console.log('Notification error');
      return console.log(e);
    }
  
  });