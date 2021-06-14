'use strict';
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();



exports.qrCheckIn = functions.https.onCall(async(data,context)=>{

  // check if user is authenticated and not using email as registration
  if (!context.auth || context.auth.token.email) {
    console.log('unauthenticated user tried accessing ')
    return {
      'response':'Permission-denied',
      'status':'ERROR',
      'detail':'Unauthenticated user',
      'code': 1001
    }
  }

  console.log('authenticated user is accessing ')

  const uid = context.auth.uid;
  const retailId = data.retailId;
  console.log(`retail Id: ${retailId} uid:${uid}`);
  const isValidCharacters = RegExp("^[a-zA-Z0-9-:]+$").test(retailId);
 // check if porvided qr code is valid
  if(!isValidCharacters){
    console.log('unauthenticated user tried accessing ')
    return {
      'response':'failed-precondition',
      'status':'ERROR',
      'detail':'QR CODE NOT VALID',
      'code': 1002
    }
  }

  console.log('QR Code String is valid')

  const retailRef = admin.firestore().collection('businessInfo').doc(retailId);
  const retailSanp = await retailRef.get();
  if(!retailSanp.exists){
    console.log('provide string is not retail ref ')
    return {
      'response':'QR code is not valid',
      'status':'ERROR',
      'detail':'QR code not valid',
      'code': 1005
  
    }
  }

   // check if user is register via app and had info user data
  const userInfoSnapshot = await admin.firestore().collection('users').doc(uid).get();
  if(!userInfoSnapshot.exists){
    console.log('authenticated user is not register')
    return {
      'response':'Permission-denied',
      'status':'ERROR',
      'detail':'Unauthenticated user !',
      'code': 1003
    }
  }
  console.log('user is register')


  const alreadyInSnap = await admin.firestore().collection('CheckInActivity')
  .where('customerUid','==',uid).where('isCheckOut','==',false).where('isWaiting','==',false).where('placeId','==',retailId).get();

  if(alreadyInSnap.size>0){
    // when user is showing checkedIn with this retail Id
    console.log('customer checked In')
    return {
      'response':`${userInfoSnapshot.data().displayName} is already check in`,
      'status':'ERROR',
      'detail':'You are already checked-in',
      'code': 1004
  
    }
  }




  const totalPersonsInWaiting = retailSanp.data().srNumber-retailSanp.data().lastSrNoIn;
  const totalAvailableSpot = retailSanp.data().maxGuest-retailSanp.data().currentCount;

  // checking if there is spot availale, iswating will check if user can directly checkin
  const isWaitingEnable = totalPersonsInWaiting>=totalAvailableSpot;

  if(isWaitingEnable){
    console.log('waiting is enable')
    const waitingListSnapshot = await admin.firestore().collection('CheckInActivity')
    .where('customerUid','==',uid).where('isCheckOut','==',false).where('isWaiting','==',true).where('placeId','==',retailId).get();
   
    
    let isInWaitingList = false;
    if(waitingListSnapshot.size>0){
      console.log('customer is in waiting list')
      // waiting list is enable and customer is in waiting list, check if customer is can checkIn if spot avaiable, 
      isInWaitingList = true;
      const listData=waitingListSnapshot.docs[0].data();
      const activityModelRef = admin.firestore().collection('CheckInActivity').doc(`${waitingListSnapshot.docs[0].id}`);

      const waitNumber = retailSanp.data().srNumber-listData.srNumber;
      const  canCheckIn = waitNumber<=totalAvailableSpot;

      if(canCheckIn){
        console.log('customer is in waiting list and can check in')
         // waiting list is enable and customer is in waiting list and can check
        return admin.firestore().runTransaction(async (transcation)=>{

          try {
            const updateRetailSnap = await transcation.get(retailRef);    
            const retailModel = {
              'lastSrNoIn': updateRetailSnap.data().lastSrNoIn + 1,
              'currentCount': updateRetailSnap.data().currentCount + 1,
            };
    
            const activityModel = {

              'checkInDate': admin.firestore.FieldValue.serverTimestamp(),
              'isWaiting': false,
              'isCheckOut': false,
            };
    
            transcation.update(retailRef, retailModel);
            transcation.update(activityModelRef, activityModel);
            console.log(`transactionResult:ok`);
            return {
              'response': 'checked from waiting list',
              'status': 'OK',
              'detail': 'Checked-In',
              'code': 2000
            };
          }
          catch (err) {
            console.log('Transaction failure:', err);
            return {
              'response': `enable to compelte transaction ${err}`,
              'status': 'ERROR',
              'detail': 'Checked-In Failed - Try again',
              'code': 1006
            };
          }
      
        })

      }
      console.log('customer is in waiting list and cannot checkIn ')
        // waiting list is enable and customer is in waiting list, can not check
      return {
        'response':'User is in waiting list and can not check in',
        'status':'ERROR',
        'detail':'You are in waiting, please wait for ur turn',
        'code': 1007
        
      }
    }

    // wating is enable and customer is not in waiting, add customer to waiting list
    console.log('wating is enable and customer is not in waiting adding to waiting list ')

    return admin.firestore().runTransaction(async (transcation)=>{
      // const docRef = admin.firestore().collection('CheckInActivity').doc();

      try {
        const updateRetailSnap = await transcation.get(retailRef);
        const activityModelRef = admin.firestore().collection('CheckInActivity').doc();


        const retailModel = {
          'srNumber': updateRetailSnap.data().srNumber + 1,
        };

        const activityModel = {
          'placeName': updateRetailSnap.data().name,
          'checkInDate': admin.firestore.FieldValue.serverTimestamp(),
          'checkOutDate': admin.firestore.FieldValue.serverTimestamp(),
          'isWaiting': true,
          'isCheckOut': false,
          'placeId': updateRetailSnap.data().uid,
          'docKey': `${activityModelRef.id}`,
          'customerUid': uid,
          'displayName': userInfoSnapshot.data().displayName,
          'srNumber': updateRetailSnap.data().srNumber + 1,
        };

        transcation.update(retailRef, retailModel);
        transcation.set(activityModelRef, activityModel);
        console.log(`transactionResult:${result.data}`);
        return {
          'response': 'checked in waiting list',
          'status': 'OK',
          'detail': `Please wait in Q. Waiting No: ${updateRetailSnap.data().srNumber + 1}`,
          'code': 2001  
          
        };
      }
      catch (err) {
        console.log('Transaction failure:', err);
        return {
          'response': `enable to compelte transaction ${err}`,
          'status': 'ERROR',
          'detail': 'Checked-In Failed. Try again!',
          'code': 1006
        };
      }
  
    })


  }

  console.log('there is not waiting list, check in customer')

  return admin.firestore().runTransaction(async (transcation)=>{

    try {
      const updateRetailSnap = await transcation.get(retailRef);
      const activityModelRef = admin.firestore().collection('CheckInActivity').doc();


      const retailModel = {
        'srNumber': updateRetailSnap.data().srNumber + 1,
        'lastSrNoIn': updateRetailSnap.data().lastSrNoIn + 1,
        'currentCount': updateRetailSnap.data().currentCount + 1,
      };

      const activityModel = {
        'placeName': updateRetailSnap.data().name,
        'checkInDate': admin.firestore.FieldValue.serverTimestamp(),
        'checkOutDate': admin.firestore.FieldValue.serverTimestamp(),
        'isWaiting': false,
        'isCheckOut': false,
        'placeId': updateRetailSnap.data().uid,
        'docKey': `${activityModelRef.id}`,
        'customerUid': uid,
        'displayName': userInfoSnapshot.data().displayName,
        'srNumber': updateRetailSnap.data().srNumber + 1,
      };

      transcation.update(retailRef, retailModel);
      transcation.set(activityModelRef, activityModel);
      console.log(`transactionResult:${result.data}`);
      return {
        'response': 'direct checked in',
        'status': 'OK',
        'detail': "Checked-In",
        'code': 2000        
      };
    }
    catch (err) {
      console.log('Transaction failure:', err);
      return {
        'response': `enable to compelte transaction ${err}`,
        'status': 'ERROR',
        'detail': 'Checked-In Failed. Try again!',
        'code': 1006
      };
    }

  })
}); 

