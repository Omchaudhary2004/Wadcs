const express = require('express');
const dbConnect = require('./mongodb');
const app = express();
const port = 3000;

app.use(express.json());

// Test endpoint to verify MongoDB connection
app.get('/test', async (req, res) => {
    try {
        const collection = await dbConnect();
        const data = await collection.find({}).toArray();
        res.json(data);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.listen(port, () => {
    console.log(`Server is running on http://localhost:${port}`);
}); 