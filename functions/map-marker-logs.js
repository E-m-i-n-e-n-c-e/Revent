const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { createLogEntry } = require('./utils');

// Log all writes to mapMarkers collection
exports.logMapMarkerChanges = functions
  .region('asia-south1')
  .firestore
  .document('mapMarkers/{markerId}')
  .onWrite(async (change, context) => {
    const markerId = context.params.markerId;
    const beforeData = change.before.exists ? change.before.data() : null;
    const afterData = change.after.exists ? change.after.data() : null;

    // Determine operation type
    let operation = 'unknown';
    if (!beforeData && afterData) operation = 'create_map_marker';
    else if (beforeData && afterData) operation = 'update_map_marker';
    else if (beforeData && !afterData) operation = 'delete_map_marker';

    // Create log entry
    return createLogEntry({
      collection: 'mapMarkers',
      documentId: markerId,
      operation,
      beforeData,
      afterData,
      context
    });
  });