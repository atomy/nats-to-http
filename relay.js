const { connect, StringCodec } = require('nats');
const axios = require('axios');

// Retrieve configuration from environment variables
const NATS_SERVER = process.env.NATS_SERVER;
const NATS_TOPIC = process.env.NATS_TOPIC;
const FORWARD_HTTP_URL = process.env.FORWARD_HTTP_URL;

// Validate required environment variables
if (!NATS_SERVER || !NATS_TOPIC || !FORWARD_HTTP_URL) {
    console.error("Missing required environment variables. Please set NATS_SERVER, NATS_TOPIC, and FORWARD_HTTP_URL.");
    process.exit(1);
}

// Connect to NATS
(async () => {
    try {
        const nc = await connect({ servers: NATS_SERVER });
        console.log(`Connected to NATS server: ${NATS_SERVER}`);

        // Set up string codec to decode/encode messages
        const sc = StringCodec();

        // Subscribe to the topic
        const sub = nc.subscribe(NATS_TOPIC);
        console.log(`Listening for messages on topic: ${NATS_TOPIC}`);

        for await (const msg of sub) {
            const message = sc.decode(msg.data);
            console.log(`Received message: ${message}`);

            // Forward the message to the HTTP endpoint
            try {
                const response = await axios.post(FORWARD_HTTP_URL, {
                    message: message,
                });

                console.log(`Message successfully forwarded. HTTP status: ${response.status}`);
            } catch (error) {
                console.error(`Failed to forward message: ${error.message}`);
            }
        }

        // Close the NATS connection when done
        await nc.drain();
    } catch (error) {
        console.error(`Error connecting to NATS: ${error.message}`);
    }
})();
