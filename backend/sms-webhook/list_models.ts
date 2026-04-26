import { GoogleGenerativeAI } from "@google/generative-ai";
import * as dotenv from 'dotenv';
dotenv.config();

async function run() {
    console.log(`Using key: ${process.env.GEMINI_API_KEY?.substring(0, 10)}...`);
    try {
        const response = await fetch(`https://generativelanguage.googleapis.com/v1beta/models?key=${process.env.GEMINI_API_KEY}`);
        const data = await response.json();
        if (data.models) {
             console.log("Models:", data.models.map((m: any) => m.name));
        } else {
             console.log("Response:", data);
        }
    } catch (e) {
        console.error(e);
    }
}
run();
