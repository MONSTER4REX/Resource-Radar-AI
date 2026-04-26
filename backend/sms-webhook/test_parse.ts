import { parseSignalWithGemini } from './src/parse-signal.js';
import dotenv from 'dotenv';
dotenv.config();

async function run() {
    const text = "We need urgent medical supplies and clean water for about 30 people near Bandra Railway Station, Mumbai. Please hurry";
    console.log("Testing text:", text);
    try {
        const result = await parseSignalWithGemini(text, "test_sender");
        console.log("Result:", result);
    } catch (e) {
        console.error("Error:", e);
    }
}
run();
