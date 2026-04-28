import twilio from 'twilio';
const ACCOUNT_SID = process.env.TWILIO_ACCOUNT_SID || '';
const AUTH_TOKEN = process.env.TWILIO_AUTH_TOKEN || '';
const client = twilio(ACCOUNT_SID, AUTH_TOKEN);
/**
 * Send an SMS reply to the sender via Twilio.
 */
export async function sendReply(from, to, message) {
    try {
        await client.messages.create({
            body: message,
            from,
            to,
        });
        console.log(`Reply sent to ${to}`);
    }
    catch (error) {
        console.error(`Failed to send reply to ${to}:`, error);
    }
}
//# sourceMappingURL=reply.js.map