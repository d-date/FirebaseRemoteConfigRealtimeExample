import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

exports.pushConfig = functions.remoteConfig.onUpdate(versionMetadata => {
  // Create FCM payload to send data message to PUSH_RC topic.
  const payload = {
    topic: "PUSH_RC",
    data: {
      "CONFIG_STATE": "STALE"
    }
  };
  // Use the Admin SDK to send the ping via FCM.
  return admin.messaging().send(payload).then(resp => {
    console.log(resp);
    return null;
  });
});
