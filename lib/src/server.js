const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

// Connect to MongoDB
mongoose.connect('mongodb://localhost:27017/chatapp', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

// Define a schema for chat messages
const chatSchema = new mongoose.Schema({
  role: String, // "user" or "bot"
  text: String, // The message content
  timestamp: { type: Date, default: Date.now }, // Timestamp of the message
});

// Create a model for the chat collection
const Chat = mongoose.model('Chat', chatSchema);

// API to save a chat message
app.post('/api/chat', async (req, res) => {
  const { role, text } = req.body;
  const chatMessage = new Chat({ role, text });
  await chatMessage.save();
  res.status(201).json({ message: 'Chat saved successfully' });
});

// API to fetch chat history
app.get('/api/chat', async (req, res) => {
  const chats = await Chat.find().sort({ timestamp: 1 }); // Sort by timestamp
  res.json(chats);
});

// Start the server
const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});