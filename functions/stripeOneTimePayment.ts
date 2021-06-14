import * as functions from "firebase-functions";
import * as admin from 'firebase-admin';
admin.initializeApp(functions.config().functions);
import * as Stripe  from 'stripe';

const stripe = Stripe(functions.config().stripe.secretkey);


export const acceptOnTimePayment = functions.firestore.document('../../product_checkout/{docId}').onCreate(async(snapsot,context)=>{
   if (!context.auth){
      return console.log('non authenticte user invoking function')
    }
  try{

    
    const data = snapsot.data();
    const customer = data.customer; 
    const price = data.price; 
    const quantity =data.quantity; 
    const tax_rates = data.taxRate;
    const success_url = data.success_url; 
    const cancel_url = data.cancel_url;

    const payment_method_types = ['card'];

    const billing_address_collection = 'required';
    const allow_promotion_codes = true;

    let session = await stripe.checkout.sessions.create({
      billing_address_collection,
      payment_method_types,
      customer,
      line_items: [
        {
            price,
            quantity,
            tax_rates,
        },
    ],
      mode: 'payment',
      allow_promotion_codes,
      success_url,
      cancel_url,
  }, { idempotencyKey: context.params.id });
  await snapsot.ref.set({
      sessionId: session?.id,
      created: admin.firestore.Timestamp.now(),
  }, { merge: true });

  return console.log('checkoutSessionCreated');


  }catch(error){
    await snapsot.ref.set({ error: { message: error.message } }, { merge: true });
    return console.log('error create payment')
  }
});
