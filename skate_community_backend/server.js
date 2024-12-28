// server.js
import dotenv from 'dotenv';
import express, { json } from 'express';
import { createServer } from 'http';
import cors from 'cors';
import { Server } from 'socket.io';

// LET OP: pg is CommonJS, dus we halen 'Pool' eruit via destructuring.
import pg from 'pg';
const { Pool } = pg;

// Laad de .env-variabelen
dotenv.config();

// Maak de server aan
const app = express();
const server = createServer(app);
const io = new Server(server);

// Middleware
app.use(cors());
app.use(json());

// ------------------------------
// 1. Verbind met Supabase-Postgres
// ------------------------------
const pool = new Pool({
  connectionString: process.env.SUPABASE_DB_URL,
  // Voorbeeld: "postgresql://postgres:YOUR_PASSWORD@db.xxxxxx.supabase.co:5432/postgres"
});

// Test of de connectie werkt
pool.connect((err, client, release) => {
  if (err) {
    console.error('Fout bij verbinden met Supabase-Postgres:', err);
  } else {
    console.log('Verbonden met Postgres (Supabase)');
    release();
  }
});

// ------------------------------
// 2. Routes (Express) - voorbeeld
// ------------------------------
// (Nog leeg, maar hier kun je straks je app.get(...) / app.post(...) etc. zetten.)

// ------------------------------
// 3. Socket.IO - voorbeeld
// ------------------------------
io.on('connection', (socket) => {
  console.log('Client connected:', socket.id);

  socket.on('locationUpdate', (data) => {
    console.log('locationUpdate:', data);
    io.emit('locationUpdate', data);
  });

  socket.on('disconnect', () => {
    console.log('Client disconnected:', socket.id);
  });
});

// ------------------------------
// 4. Start server
// ------------------------------
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Server + Socket.IO listening on port ${PORT}`);
});
