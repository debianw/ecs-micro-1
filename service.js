const express = require('express');
const app = express();
const port = 9000;

app.get('/', (req, res) => {
  res.json({ instance: 'hello micro-1 , waly, test #1.1'});
});

app.listen(port, () => {
  console.log(`Micro #1 listening on port ${port}`);
});
