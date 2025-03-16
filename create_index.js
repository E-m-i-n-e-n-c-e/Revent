const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function createIndex() {
  try {
    console.log('Creating index for notifications collection...');

    // The index creation is handled by Firebase automatically when you deploy the firestore.indexes.json file
    // This script is just to verify that the index exists

    console.log('Index creation request sent. It may take a few minutes for the index to be fully created.');
    console.log('You can check the status of your indexes in the Firebase console:');
    console.log('https://console.firebase.google.com/project/event-manager-dfd26/firestore/indexes');

    // Perform a test query to trigger index creation if it doesn't exist
    const cutoffTime = new Date();
    cutoffTime.setHours(cutoffTime.getHours() - 48);

    await db.collection('notifications')
      .where('userId', '==', 'test-user-id')
      .where('time', '>=', cutoffTime)
      .orderBy('time', 'desc')
      .limit(1)
      .get();

    console.log('Test query executed. If the index does not exist, it will be created automatically.');
  } catch (error) {
    console.error('Error:', error);
    if (error.code === 'failed-precondition' && error.message.includes('index')) {
      console.log('Index does not exist yet. Firebase will create it automatically.');
      console.log('Please check the Firebase console for the status of the index creation.');
    }
  }
}

createIndex();