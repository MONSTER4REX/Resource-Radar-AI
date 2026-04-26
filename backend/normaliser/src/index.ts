import express from "express";
import { startListening } from "./pubsub-consumer.js";
import dotenv from "dotenv";

dotenv.config();

const app = express();
const port = process.env.PORT || 8080;

app.use(express.json());

// Health check endpoint
app.get("/health", (req, res) => {
    res.status(200).send("OK");
});

// Start Pub/Sub consumer
startListening();

app.listen(port, () => {
    console.log(`Normaliser service listening on port ${port}`);
});
