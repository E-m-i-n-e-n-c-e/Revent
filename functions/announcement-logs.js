const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { createLogEntry } = require('./utils');

// Log all writes to announcements collection
exports.logAnnouncementChanges = functions
  .region('asia-south1')
  .firestore
  .document('announcements/{clubId}')
  .onWrite(async (change, context) => {
    const clubId = context.params.clubId;
    const beforeData = change.before.exists ? change.before.data() : null;
    const afterData = change.after.exists ? change.after.data() : null;

    // Determine operation type
    let operation = 'unknown';
    if (!beforeData && afterData) {
      operation = 'create_club_announcements';
    } else if (beforeData && afterData) {
      const beforeList = beforeData && beforeData.announcementsList ? beforeData.announcementsList : [];
      const afterList = afterData && afterData.announcementsList ? afterData.announcementsList : [];

      if (afterList.length > beforeList.length) {
        operation = 'add_announcement';
      } else if (afterList.length < beforeList.length) {
        operation = 'delete_announcement';
      } else {
        operation = 'update_announcement';
      }
    } else if (beforeData && !afterData) {
      operation = 'delete_club_announcements';
    }

    // Create log entry
    return createLogEntry({
      collection: 'announcements',
      documentId: clubId,
      operation,
      beforeData,
      afterData,
      context
    });
  });