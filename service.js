const os = require('os');
const express = require('express');
const app = express();
const port = 9000;

app.get('/', (req, res) => {
  res.json({ 
    instance: 'hello micro-1 , waly, test #3',
    hostname: os.hostname()
  });
});

app.listen(port, () => {
  console.log(`Micro #1 listening on port ${port}`);
});
