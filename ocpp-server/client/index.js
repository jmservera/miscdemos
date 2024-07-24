const WebSocket = require('ws');

// get server address from the console
const serverAddress = process.argv[2];
// get station name from the console
const stationName = process.argv[3];
// get station password from the console
const stationPassword = process.argv[4];

const wsOptions= {
  rejectUnauthorized: false,
  headers: {
    'Authorization': 'Basic ' + Buffer.from(stationName + ':' + stationPassword).toString('base64')
  }
};
// use websocket to connect to the server
const ws = new WebSocket(serverAddress+`/OCPP/${stationName}`, 'ocpp1.6', wsOptions);
// read user input from the console
const readline = require('readline').createInterface({
  input: process.stdin,
  output: process.stdout
});



// when the connection is established
ws.on('open', function open() {
  // send the station name and password to the server
  console.log("Connected to the server");
  ws.send(JSON.stringify({ stationName, stationPassword }));
});

// when the server sends a message
ws.on('message', function incoming(data) {
  //convert binary data to string
  const message = data.toString('utf8');
  // print the message to the console
  console.log(message);
});

// when the user types a message
readline.on('line', (input) => {
  // send the message to the server
  ws.send(input);
});

// when the connection is closed
ws.on('close', function close() {
  console.log('disconnected');
  // close the console
  readline.close();
});

// wait for the user to close the console
readline.on('close', () => {
    // close the websocket connection
    ws.close();
});


