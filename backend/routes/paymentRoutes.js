const express = require('express');
const router = express.Router();
const { getPaymentDetails, confirmCashPayment, confirmUpiPayment } = require('../controllers/paymentController');
const authenticate = require('../middleware/auth');

router.use(authenticate);

router.get('/:bookingId', getPaymentDetails);
router.post('/:bookingId/cash', confirmCashPayment);
router.post('/:bookingId/upi', confirmUpiPayment);

module.exports = router;
