const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// Import our logging functions
const eventLogs = require('./event-logs');
const announcementLogs = require('./announcement-logs');
const clubLogs = require('./club-logs');
const userLogs = require('./user-logs');
const mapMarkerLogs = require('./map-marker-logs');
const utils = require('./utils');

// Export all functions
exports.logEventChanges = eventLogs.logEventChanges;
exports.logAnnouncementChanges = announcementLogs.logAnnouncementChanges;
exports.logClubChanges = clubLogs.logClubChanges;
exports.logUserChanges = userLogs.logUserChanges;
exports.logMapMarkerChanges = mapMarkerLogs.logMapMarkerChanges;