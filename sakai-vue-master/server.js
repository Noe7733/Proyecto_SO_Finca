const express = require('express');
const http = require('http');
const socketIO = require('socket.io');

const app = express();
const server = http.createServer(app);
const io = socketIO(server);

io.on('connection', (socket) => {
    console.log('Usuario conectado');

    socket.on('disconnect', () => {
        console.log('Usuario desconectado');
    });

    socket.on('message', (message) => {
        console.log(`Mensaje recibido: ${message}`);
        io.emit('message', message);
    });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
    console.log(`Servidor Socket.io escuchando en el puerto ${PORT}`);
});
