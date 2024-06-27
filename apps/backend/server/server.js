const express = require('express');
const app = express();
const cors = require('cors')

const corsOptions = {
  origin: 'http://localhost:8080', // Allow requests from your frontend
  credentials: true, // Allow cookies to be sent
  optionsSuccessStatus: 200 // Some legacy browsers (IE11, various SmartTVs) choke on 204
};

app.use(express.json());
app.use('/', require('./route/postsRoute'));
app.use(cors(corsOptions))
app.use(function (error, req, res, next) {
	if (error.message === 'Post already exists') {
		return res.status(409).send(e.message);
	}
	if (error.message === 'Post not found') {
		return res.status(404).send(e.message);
	}
	res.status(500).send(error.message);
  
});

app.listen(3000);
