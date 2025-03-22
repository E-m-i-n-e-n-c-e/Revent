const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { createLogEntry, sendEmail } = require('./utils');

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

        // Get the new announcement (it's at the start of the list)
        const newAnnouncement = afterList[0];

        try {
          // Get club name
          const clubDoc = await admin.firestore().collection('clubs').doc(clubId).get();
          const clubName = clubDoc.exists ? clubDoc.data().name : 'Unknown Club';

          // Get all users
          // const usersSnapshot = await admin.firestore().collection('users').get();
          // const userEmails = usersSnapshot.docs
          //   .map(doc => doc.data().email)
          //   .filter(email => email); // Filter out any undefined/null emails
          const userEmails = ['kssakhilraj@gmail.com','kesavar23bcd18@iiitkottayam.ac.in','kumarha23bec8@iiitkottayam.ac.in','harshahyper2011@gmail.com','harshtiwarilm10@gmail.com'];

          // Prepare email content
          const subject = `New Announcement from ${clubName}`;
          const html = `
            <div style="font-family: Arial, sans-serif; max-width: 600px;">
              <p style="font-size: 16px; margin-bottom: 8px;">Hey there! 👋</p>
              <p style="font-size: 16px; margin-bottom: 8px;">${clubName} just posted a new announcement:</p>
              <p style="font-size: 16px; margin-bottom: 16px;">${newAnnouncement.title}</p>
              <p style="margin-bottom: 24px;">
                <a href="https://event-manager-dfd26.web.app/app"
                   style="background-color: #4285f4; color: white; padding: 10px 20px;
                          text-decoration: none; border-radius: 4px; display: inline-block;">
                  Check it out
                </a>
              </p>
              <p style="color: #666; font-size: 12px; margin-top: 24px;">Sent by Revent</p>
            </div>
          `;

          // Send emails in batches of 50 to avoid rate limits
          const batchSize = 50;
          for (let i = 0; i < userEmails.length; i += batchSize) {
            const batch = userEmails.slice(i, i + batchSize);
            await Promise.all(batch.map(email => sendEmail(email, subject, html)));
          }
        } catch (error) {
          console.error('Error sending announcement emails:', error);
        }
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