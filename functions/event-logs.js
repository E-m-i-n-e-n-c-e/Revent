const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { createLogEntry } = require('./utils');

// Log all writes to events collection
exports.logEventChanges = functions
  .region('asia-south1')
  .firestore
  .document('events/{eventId}')
  .onWrite(async (change, context) => {
    const eventId = context.params.eventId;
    const beforeData = change.before.exists ? change.before.data() : null;
    const afterData = change.after.exists ? change.after.data() : null;

    // Determine operation type
    let operation = 'unknown';
    if (!beforeData && afterData) operation = 'create_event';
    else if (beforeData && afterData) operation = 'update_event';
    else if (beforeData && !afterData) operation = 'delete_event';

    // Create log entry
    return createLogEntry({
      collection: 'events',
      documentId: eventId,
      operation,
      beforeData,
      afterData,
      context
    });
  });