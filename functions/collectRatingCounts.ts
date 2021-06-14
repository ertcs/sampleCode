import * as functions from "firebase-functions";
import * as admin from 'firebase-admin';
admin.initializeApp(functions.config().functions);

export const collectRatingCount = functions.firestore.document('../../../{docId}').onWrite(async(snapshot,context)=>{
    if (!context.auth){
        return console.log('non authenticte user invoking function')
      }
    try{
        // If the document does not exist, it has been deleted.
        var batch = admin.firestore().batch();
        const newDocument = snapshot.after.exists ? snapshot.after.data() : null;
        // Get an object with the previous document value (for update or delete)
        const oldDocument = snapshot.before.exists? snapshot.before.data():null;
      
        const whoRatedIdId = context.params.userId;
        var ratedCount;
        var adsId;
        var sellerId;
      
      
        if(oldDocument!==null){
          ratedCount = newDocument.rateCount - oldDocument.rateCount;
          adsId = oldDocument.adId;
          sellerId = oldDocument.sellerId;
        }else{
          ratedCount = newDocument.rateCount;
          adsId = newDocument.adId;
          sellerId = newDocument.sellerId;
        }
      
        const rateCountRef = admin.firestore().collection('').doc(adsId).collection('').doc('');
        let rateStatData = await rateCountRef.get();
      
        const masterCountRef = admin.firestore().collection('').doc(sellerId);
        let masterCountData = await masterCountRef.get();
      
        if(rateStatData.exists){
         
          var newData = {
            totalRating: admin.firestore.FieldValue.increment(ratedCount),
            listWhoRated:admin.firestore.FieldValue.arrayUnion(whoRatedIdId),
            numberOfReview:admin.firestore.FieldValue.increment(1)};
            console.log('adding new rating to existing document');
            batch.update(rateCountRef,newData);
            
        }else{
          console.log('adding new rating to new document');
          var updateData = {
            totalRating: ratedCount,
            listWhoRated:admin.firestore.FieldValue.arrayUnion(whoRatedIdId),
            lastViewedrating:0,
            numberOfReview:1};
            batch.set(rateCountRef,updateData);
        }
      
        if(masterCountData.exists){
          console.log('updating existing master document');
          var masterDataUpdate = {
            totalRating: admin.firestore.FieldValue.increment(ratedCount),
            lastViewedrating:admin.firestore.FieldValue.increment(0),
            numberOfReview:admin.firestore.FieldValue.increment(1)
          };
            batch.update(masterCountRef,masterDataUpdate);
        }else{
          console.log('creating master count doc and adding new rating count');
          var masterDataAll = {
            totalRating: ratedCount,
            lastViewedrating:0,
            numberOfReview:1};
          batch.set(masterCountRef,masterDataAll);
        }
      
        return await batch.commit();
        
        }catch(e){
          console.log(e);
          return console.log('collectRatingCount function ends with error');
      
        }
});

