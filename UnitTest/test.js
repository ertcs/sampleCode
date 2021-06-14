const assert = require('assert');
const firebase = require('@firebase/testing');

const dbName ='autoly-inc';


const loginedGuestUser = {uid:'guest_uid',};
const loginbasicUser = {uid:'basic_uid',email:'basicUser@autoly.io',};
const loginsubcriber = {uid:'subscriber_uid',email:'basicUser@autoly.io',stripPlan:'basic'};

function getDBLink(userAuth){
    // get database reference with read and write access set by rules
    return firebase.initializeTestApp({projectId:dbName,auth:userAuth}).firestore();
}

function getAdminAccess(){
    // get database reference with admin role 
    return firebase.initializeAdminApp({projectId:dbName});
}

beforeEach(async()=>{
    // clear all data before each test
    await firebase.clearFirestoreData({projectId:dbName});
});

it('reject read from database without login',async()=>{
    const db = getDBLink(null);
    const userDoc = db.collection('user').doc('my_uid');
    await firebase.assertFails(userDoc.get());

});

it('reject create document without login',async()=>{
    const db = getDBLink(null);
    const userDoc = db.collection('user').doc('my_uid');
    await firebase.assertFails(userDoc.set({'myName':'testUser'}));

});


it('reject update to privacypolicy document',async()=>{
    const db = getDBLink(null);
    const privacypolicyDoc = db.collection('privacypolicy').doc('ppID');
    await firebase.assertFails(privacypolicyDoc.update({'privacyText':' a long text'}))
});

it('reject document edit /create to other user doc',async()=>{
    const db = getDBLink(loginedGuestUser);
    const userCollectionDoc = db.collection('users').doc('user_abc');
    await firebase.assertFails(userCollectionDoc.update({'name':'guest_user'}));
});

it('reject all query / getting unlimited data list',async()=>{
    const db = getDBLink(loginedGuestUser);
    const adCollection = db.collection('ads');
    await firebase.assertFails(adCollection.get());
});

it('allow get documents as long as length is less than 20',async()=>{
    const db = getDBLink(loginedGuestUser);
    const adCollection = db.collection('ads').limit(19);
    await firebase.assertFails(adCollection.get());
});

it('reject guest user creating ads document',async()=>{
    const db = getDBLink(loginedGuestUser);
    const adCollection = db.collection('ads').doc();
    await firebase.assertFails(adCollection.set({'testID':'testId'}));

});

it('reject deleted ads doc my other user',async()=>{
    const db = getDBLink(loginedGuestUser);
    const adCollection = db.collection('ads').doc('p4dcey7bay7dvaw');
    await firebase.assertFails(adCollection.delete());
    
});

it('allow /create/edit/update on user own document',async()=>{
    const db = getDBLink(loginbasicUser);
    const docId=  'basic_uid';
    const userDoc = db.collection('users').doc(docId);
    await firebase.assertSucceeds(userDoc.set({'userId':docId}));

});

it('reject if document id change on update',async()=>{
    // create ads document with admin sdk
    const adminAccess = getAdminAccess();
    const docId = 'ad_doc_test_id';
    await adminAccess.collection('ads').doc(docId).set({'docId':docId,'sellerUid':basic_uid,});

    // update ads document created by admin sdk
    const db = getDBLink(loginbasicUser);
    const docId=  'basic_uid';
    const adsDoc = db.collection('ads').doc(docId);
    await firebase.assertFails(adsDoc.set({'docId':'any_random_id','sellerUid':basic_uid,}))
});

