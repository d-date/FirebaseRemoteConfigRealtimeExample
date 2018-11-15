import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

exports.pushConfig = functions.remoteConfig.onUpdate(versionMetadata => {
  // Create FCM payload to send data message to PUSH_RC topic.
  const payload: admin.messaging.MessagingPayload = {
    data: {
      'CONFIG_STATE': 'STALE'
    }
  };

  const options: admin.messaging.MessagingOptions = {
    contentAvailable: true
  }
  // Use the Admin SDK to send the ping via FCM.
  return admin.messaging()
  .sendToTopic('PUSH_RC', payload, options)
  .then(resp => {
    console.log(resp);
    return null;
  });
});
