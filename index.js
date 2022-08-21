
const express = require("express");
const uuid = require('uuid');
const app = express();
// This is your test secret API key.
const stripe = require("stripe")('sk_test_51H..........');

var PORT = process.env.PORT || 8080;

app.use(express.static("public"));
app.use(express.json());

const calculateOrderAmount = (items) => {
  return items["amount"]*1;
};

app.post("/create-payment-intent", async (req, res) => {
  const items = req.body;

  // Create a PaymentIntent with the order amount and currency
  const paymentIntent = await stripe.paymentIntents.create({
    amount: calculateOrderAmount(items),
    currency: "usd",
    automatic_payment_methods: {
      enabled: true,
    },
  });

  res.send({
    clientSecret: paymentIntent.client_secret,
    token: uuid.v4(),
  });
});

app.listen(PORT, () => console.log('Node server listening on port ${PORT}!'));
