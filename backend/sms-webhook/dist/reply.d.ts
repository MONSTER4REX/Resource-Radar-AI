/**
 * Send an SMS reply to the sender via Twilio.
 */
export declare function sendReply(from: string, to: string, message: string): Promise<void>;
