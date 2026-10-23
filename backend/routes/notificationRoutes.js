const express = require('express');
const router = express.Router();
const { getNotifications, markRead, markAllRead, sendDelayNotification } = require('../controllers/notificationController');
const authenticate = require('../middleware/auth');

router.use(authenticate);

router.get('/', getNotifications);
router.patch('/read-all', markAllRead);
router.patch('/:id/read', markRead);
router.post('/delay', sendDelayNotification);

module.exports = router;
