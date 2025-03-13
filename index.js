const express = require('express');
const bodyParser = require('body-parser');
const session = require('express-session');
const helmet = require('helmet');
const pgConnect = require('connect-pg-simple');
const dotenv = require('dotenv');

/* Load environment variables from .env file */
dotenv.config();

/* Check required environment variables */
if (!process.env.DATABASE_URL) {
    console.error("❌ ERROR: DATABASE_URL is not set in .env file.");
    process.exit(1);
}

if (!process.env.SESSION_SECRET) {
    console.error("❌ ERROR: SESSION_SECRET is not set in .env file.");
    process.exit(1);
}

const PORT = process.env.PORT || 4000;
const SERVER_ADDRESS = process.env.SERVER_ADDRESS || '127.0.0.1';

/* Init express */
const app = express();

/* Init helmet and CORS */
app.use(helmet({ contentSecurityPolicy: false }));

/* Set view engine */
app.set('view engine', 'ejs');

/* Middleware setup */
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

/* Serve static files */
app.use(express.static('./public'));

/* Session setup */
const pgSession = pgConnect(session);
app.use(session({
    store: new pgSession({
        conString: process.env.DATABASE_URL,
    }),
    secret: process.env.SESSION_SECRET,
    resave: false,
    saveUninitialized: false,
    cookie: { maxAge: 30 * 24 * 60 * 60 * 1000 }, // 30 days
}));

/* Setup routes */
const routes = require('./routes');
app.use(routes);

/* Start server */
app.listen(PORT, () => {
    console.log(`✅ Express server running on port ${PORT} in ${app.settings.env} mode`);
    console.log(`🌍 Open in browser: \x1b[36mhttp://${SERVER_ADDRESS}:${PORT}\x1b[0m`);
});

module.exports = app;
