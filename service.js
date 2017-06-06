const os = require('os');
const express = require('express');
const app = express();
const port = 9000;

app.get('/', (req, res) => {
  res.json({ 
    instance: 'hello micro-1 , waly, test #5',
    hostname: os.hostname()
  });
});

app.get('/micro-1', (req, res) => {
  res.json({ 
    micro: '/micro-1/*',
    hostname: os.hostname()
  });
});

app.listen(port, () => {
  console.log(`Micro #1 listening on port ${port}`);
});
