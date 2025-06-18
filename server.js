require('dotenv').config();

const express = require('express');
const cors = require('cors');
const path = require('path');
const db = require('./database/db');

const app = express();
const PORT = 3000;

app.use(cors({
    origin: '*',
    methods: ['GET','POST'],
    allowedHeaders: ['Content-Type']
}));
app.use(express.json()); 
app.use(express.static(path.join(__dirname, 'public')));

// get all landmarks (for pins in app.js)
app.get('/api/landmarks', async (req, res) => {
    try {
        const [results] = await db.query('SELECT * FROM landmarks');
        res.json(results);
    } catch (err) {
        res.status(500).json({ success: false, error: err.message });
    }
});

// get the model path (for viwer.html)
app.post('/api/glb-path', async (req, res) => {
    const { building_code } = req.body;
    if (!building_code) {
        return res.status(400).json({ success: false, error: 'Missing building_code' });
    }

    try {
        const [exactMatch] = await db.query(
            'SELECT * FROM landmarks WHERE building_code = ?',
            [building_code]
        );

        if (exactMatch.length > 0) {
            return res.json({
                success: true,
                matched_by: 'exact_match',
                building_code: exactMatch[0].building_code,
                glb_file: exactMatch[0].glb_file,
            });
        }

        // last 5 digits of the code
        const lastFive = building_code.slice(-5);

        const [partialMatch] = await db.query(
            'SELECT * FROM landmarks WHERE digits = ?',
            [lastFive]
        );

        if (partialMatch.length > 0) {
            return res.json({
                success: true,
                matched_by: 'partial_match',
                matched_digits: lastFive,
                building_code: partialMatch[0].building_code,
                glb_file: partialMatch[0].glb_file,
            });
        }

        // no match found
        return res.json({ success: false, error: 'No matching building code or digits' });

    } catch (error) {
        console.error(error);
        return res.status(500).json({ success: false, error: 'Internal server error' });
    }
});

// start server
app.listen(PORT, () => {
    console.log(`API running on http://localhost:${PORT}`);
});