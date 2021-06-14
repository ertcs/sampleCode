import * as functions from "firebase-functions";
import * as admin from 'firebase-admin';
admin.initializeApp(functions.config().functions);

import * as request from 'request-promise';
import * as SgMail  from '@sendgrid/mail';

const sgMail = SgMail.setApiKey(functions.config().sgMailConf.secretkey);

export const sendInviteEmail =functions.firestore.document('unRegisterUsers/{docId}').onCreate(async(snap,context)=>{

    if (!context.auth){
        return console.log('non authenticte user invoking function')
      }

  try{
  const documentId = context.params.docId;
  const docRef =  admin.firestore().collection('unRegisterUsers').doc(documentId);

  docRef.update({
    'status':"processing",
  });

  const snapShot = snap.data();
  const senderUid = snapShot.senderUid;
  const senderEmail = snapShot.fromEmaild;
  const toEmail = snapShot.toEmail;
  const dealerName = snapShot.dealerName;
  var inviteLink = snapShot.inviteLink;




  const reqUrl = admin.dynamicLinkUrl;

  const body ={
    "dynamicLinkInfo": {
      "domainUriPrefix": "https://app.autoly.io",
      "link": `https://app.autoly.io/invite?id=${documentId}`,
      "androidInfo": {
        "androidPackageName": "io.autoly.dealer"
      },
      "iosInfo": {
        "iosBundleId": "io.autoly.dealer"
      }
    }
  };

  await request({
    url: reqUrl,
    method: 'POST', json: true, body
  }, function (error, response) {
    if (error) {
      console.log('Error :', error)
      return docRef.update({
        "status":"failed",
        'message':'unable to create dynamic link'
        });
    
    } else {
        if (response && response.statusCode !== 200) {
          console.log('Error on Request :', response.body.error.message)
          return docRef.update({
            "status":"failed",
            'message':'unable to create dynamic link'
            });
             
        } else {
          inviteLink = response.body.shortLink;
            
        }
    }
  });

  const mailOptions = {
    from: 'support@autoly.io',
    to: toEmail,
    subject: `${dealerName} Invited you to join team on Autoly.io`,
    html: 'hmtlbody'
     };


  return   sgMail
     .send(mailOptions)
     .then(() => {
      docRef.update({
        "status":"ok",
        'message':'email sent',
        'inviteLink':inviteLink,
        'timeStamp':admin.firestore.FieldValue.serverTimestamp(),
       
      });
      return console.log('Email sent')
     })
     .catch((error) => {
      docRef.update({
        "status":"failed",
        'message':'error sending email, share link',
        'inviteLink':inviteLink,
      });
       return console.error(error)
     })   
  

}catch(e){
    return console.log(e)
    }    
  
});
