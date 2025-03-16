const admin = require('firebase-admin');

// Helper function to create a log entry
exports.createLogEntry = async function({
  collection,
  documentId,
  operation,
  beforeData,
  afterData,
  context
}) {
  try {
    // Get user info from auth context or metadata
    let userId = 'system';
    let userEmail = 'system';

    // Try to get user from auth context
    if (context.auth) {
      userId = context.auth.uid;
      userEmail = context.auth.token.email;
    }
    // If not available, try to get from metadata in the document
    else if (afterData && afterData._metadata) {
      const metadata = afterData._metadata;
      if (metadata.userId) userId = metadata.userId;
      if (metadata.userEmail) userEmail = metadata.userEmail;

      // Remove metadata from the logged data to keep it clean
      delete afterData._metadata;
    }

    // Create log entry
    const logEntry = {
      collection,
      documentId,
      operation,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      userId,
      userEmail,
      beforeData,
      afterData
    };

    // Add to admin_logs collection
    return admin.firestore().collection('admin_logs').add(logEntry);
  } catch (error) {
    console.error('Error creating log entry:', error);
    // Don't throw - we don't want to interrupt the main operation
    return null;
  }
};