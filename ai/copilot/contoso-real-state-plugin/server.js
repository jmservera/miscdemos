import express from "express";
import getListings from "./get-listings.js"
import path from "path";
import cors from "cors";

const app = express();

//add logging to app
app.use((req, res, next) => {
    console.log(`${req.method} request for ${req.url}`);
    if(req.query){
      console.log(`query: ${JSON.stringify(req.query)}`);
    }
    next();
  });

app.use(cors({ origin: "https://www.bing.com" }));

app.get("/openapi.yaml", (req, res) => {
    res.sendFile(path.resolve() + "/openapi.yaml");
  });

app.get("/get-listings", (req, res) => {
    const city = req.query.city;
    const bedrooms = parseInt(req.query.bedrooms);
    const bathrooms = parseInt(req.query.bathrooms);
    const amenities = req.query.amenities;

    try {
      const listings = getListings(city, bedrooms, bathrooms, amenities);
      res.send(listings);
    } catch (e) {
      //log error
      console.error(e);
      res.status(400).send({ error: e.message });
    }
  });

app.post("/reserve-property", (req, res) => {
    res.send({ status: "success" });
  });

  app.get("/.well-known/ai-plugin.json", (req, res) => {
  res.sendFile(path.resolve() + "/ai-plugin.json");
});

app.get("/logo.png", (req, res) => {
  res.sendFile(path.resolve() + "/logo.png");
});

app.listen(8080);