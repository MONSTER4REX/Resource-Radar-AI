import twilio from 'twilio';
const AUTH_TOKEN = process.env.TWILIO_AUTH_TOKEN || '';
/**
 * Validate that an incoming request is genuinely from Twilio
 * using Twilio's request signature validation.
 */
export function validateTwilioRequest(req) {
    // Skip validation in development
    if (process.env.NODE_ENV === 'development') {
        return true;
    }
    const twilioSignature = req.headers['x-twilio-signature'];
    if (!twilioSignature) {
        return false;
    }
    const url = `${req.protocol}://${req.get('host')}${req.originalUrl}`;
    return twilio.validateRequest(AUTH_TOKEN, twilioSignature, url, req.body);
}
//# sourceMappingURL=validate-twilio.js.map