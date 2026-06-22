const express = require('express');
const cors = require('cors');
const http = require('http');
const { Server } = require('socket.io');

const app = express();
app.use(cors());
app.use(express.json());

const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST']
  }
});

const PORT = process.env.PORT || 3000;

// In-memory data store for demo
let menuItems = [
  {
    id: 'm1',
    name: 'Ceylon Lagoon Chili Crab',
    description: 'Fresh giant mud crab cooked with authentic Sri Lankan spices, thick spicy chili pepper sauce.',
    price: 24.50,
    imageUrl: 'https://images.unsplash.com/photo-1551248429-40975aa4de74?auto=format&fit=crop&w=600&q=80',
    category: 'Mains',
    rating: 4.9,
    is3dEnabled: true,
    model3dUrl: 'crab_model',
    tags: ['spicy', 'popular', 'recommended'],
    preparationTimeMinutes: 25,
    calories: 680
  },
  {
    id: 'm2',
    name: 'Colombo Premium Lamprais',
    description: 'Ghee rice baked in banana leaf with mixed meat curry, frikkadels, blachan, and deep-fried egg.',
    price: 14.90,
    imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=600&q=80',
    category: 'Mains',
    rating: 4.8,
    is3dEnabled: true,
    model3dUrl: 'lamprais_model',
    tags: ['popular', 'recommended'],
    preparationTimeMinutes: 20,
    calories: 820
  },
  {
    id: 'm3',
    name: 'Devilled Paneer Bowl',
    description: 'Crispy paneer tossed in fiery Sri Lankan sweet-sour devilled sauce with capsicums and red onions.',
    price: 11.20,
    imageUrl: 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?auto=format&fit=crop&w=600&q=80',
    category: 'Starters',
    rating: 4.6,
    is3dEnabled: false,
    tags: ['spicy'],
    preparationTimeMinutes: 12,
    calories: 450
  },
  {
    id: 'm4',
    name: 'Luminous Matcha Mousse',
    description: 'Decadent velvet-texture white chocolate matcha mousse topped with gold flake and raspberry coulis.',
    price: 8.50,
    imageUrl: 'https://images.unsplash.com/photo-1579372786545-d24232daf58c?auto=format&fit=crop&w=600&q=80',
    category: 'Desserts',
    rating: 4.9,
    is3dEnabled: true,
    model3dUrl: 'matcha_mousse',
    tags: ['recommended'],
    preparationTimeMinutes: 8,
    calories: 310
  },
  {
    id: 'm5',
    name: 'Passionfruit Ginger Mojito',
    description: 'Refreshing crush of local passionfruit juice, ginger extract, fresh mint, lime juice, and sparkling club soda.',
    price: 6.00,
    imageUrl: 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?auto=format&fit=crop&w=600&q=80',
    category: 'Beverages',
    rating: 4.7,
    is3dEnabled: false,
    tags: ['popular'],
    preparationTimeMinutes: 5,
    calories: 140
  }
];

let orders = [];
let reservations = [];

// REST Endpoints
app.get('/api/menu', (req, res) => {
  res.json(menuItems);
});

app.post('/api/orders', (req, res) => {
  const newOrder = req.body;
  orders.push(newOrder);
  // Broadcast new order to Kitchen Display System (KDS) & Admin
  io.emit('order:new', newOrder);
  res.status(201).json(newOrder);
});

app.post('/api/reservations', (req, res) => {
  const newRes = req.body;
  reservations.push(newRes);
  res.status(201).json(newRes);
});

app.post('/api/payments/charge', (req, res) => {
  const { amount, currency } = req.body;
  // Mock Stripe Payment Success
  res.json({
    success: true,
    chargeId: 'ch_' + Math.random().toString(36).substr(2, 9),
    amount,
    currency
  });
});

// Socket Connections
io.on('connection', (socket) => {
  console.log('Client connected:', socket.id);

  // Customer sending message to host
  socket.on('message:send', (data) => {
    socket.broadcast.emit('message:receive', data);
  });

  // Rider updates location
  socket.on('rider:location', (data) => {
    // Broadcast coordinates to customer app listening to tracking updates
    io.emit(`rider:location:${data.orderId}`, data);
  });

  // Kitchen / Admin status updates
  socket.on('order:update_status', (data) => {
    // Broadcast status update (preparing, ready, completed)
    io.emit(`order:status:${data.orderId}`, data);
  });

  socket.on('disconnect', () => {
    console.log('Client disconnected:', socket.id);
  });
});

server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
