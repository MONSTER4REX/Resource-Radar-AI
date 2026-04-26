import { Telegraf } from 'telegraf';
import express from 'express';
import dotenv from 'dotenv';
import { parseSignalWithGemini } from './parse-signal.js';
import { publishToIngestion } from './publish.js';

dotenv.config();

const BOT_TOKEN = process.env.TELEGRAM_BOT_TOKEN;
if (!BOT_TOKEN) {
    console.error('ERROR: TELEGRAM_BOT_TOKEN is missing in .env');
    process.exit(1);
}
console.log(`Token loaded: ${BOT_TOKEN.substring(0, 5)}...`);

const bot = new Telegraf(BOT_TOKEN);
const app = express();
const PORT = process.env.PORT || 8003;

// --- Health Check ---
app.get('/health', (_req, res) => {
    res.json({ status: 'ok', service: 'telegram-signal-bot' });
});

// --- Bot Logic ---

// Start command
bot.command('start', (ctx) => {
    ctx.reply(
        'Welcome to ResourceRadar AI Signal Bot. 🆘\n\n' +
        'Please report any humanitarian needs by sending a message describing:\n' +
        '1. What is needed (food, water, etc.)\n' +
        '2. Where it is needed (Area/Ward)\n' +
        '3. How many people are affected\n\n' +
        '📍 Tip: You can also share your current location for faster response!'
    );
});

// Handle text messages
bot.on('text', async (ctx) => {
    const text = ctx.message.text;
    const senderId = `tg_${ctx.from.id}`;
    
    console.log(`Telegram message from ${ctx.from.username || senderId}: "${text}"`);
    
    try {
        const parsed = await parseSignalWithGemini(text, senderId);
        
        if (!parsed.is_valid_signal) {
            await ctx.reply('Thank you. We received your message but couldn\'t identify a specific need signal. Please try to include: what is needed, where, and for how many people.');
            return;
        }

        await publishToIngestion({
            ward_id: parsed.ward_id,
            city_id: parsed.city_id || 'default_city',
            need_type: parsed.need_type,
            people_count: parsed.people_count,
            urgency_raw: parsed.urgency_raw,
            notes: parsed.original_text,
            reporter_id: senderId,
            reporter_role: 'community_member',
            source_channel: 'telegram',
        });

        await ctx.reply(
            `✅ Signal Logged!\n\n` +
            `Type: ${parsed.need_type}\n` +
            `Location: ${parsed.ward_id}\n` +
            `People: ~${parsed.people_count}\n` +
            `Urgency: ${parsed.urgency_raw}/5\n\n` +
            `Help is on the way!`
        );
    } catch (error) {
        console.error('Error processing Telegram text:', error);
        await ctx.reply('Sorry, I had trouble processing that report. Please try again later.');
    }
});

// Handle location messages
bot.on('location', async (ctx) => {
    const { latitude, longitude } = ctx.message.location;
    const senderId = `tg_${ctx.from.id}`;
    
    console.log(`Location pin from ${senderId}: ${latitude}, ${longitude}`);
    
    try {
        // For locations, we create a specialized signal
        await publishToIngestion({
            ward_id: 'gps_coordinate',
            city_id: 'default_city',
            need_type: 'unknown_location_pin',
            people_count: 1,
            urgency_raw: 3,
            notes: 'User shared GPS location pin.',
            reporter_id: senderId,
            reporter_role: 'community_member',
            source_channel: 'telegram',
            latitude,
            longitude,
        });

        await ctx.reply('📍 GPS Location received! Please now send a text message describing what is needed at this location.');
    } catch (error) {
        console.error('Error processing Telegram location:', error);
    }
});

// --- Startup ---

app.listen(PORT, () => {
    console.log(`Health check server listening on port ${PORT}`);
});

console.log('📡 Connecting to Telegram...');
bot.launch().then(() => {
    console.log('🚀 Telegram Signal Bot is running!');
}).catch((err) => {
    console.error('❌ Failed to launch Telegram Bot:', err);
});

// Enable graceful stop
process.once('SIGINT', () => bot.stop('SIGINT'));
process.once('SIGTERM', () => bot.stop('SIGTERM'));

export default app;
