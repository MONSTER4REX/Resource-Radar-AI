import { Request } from 'express';
/**
 * Validate that an incoming request is genuinely from Twilio
 * using Twilio's request signature validation.
 */
export declare function validateTwilioRequest(req: Request): boolean;
