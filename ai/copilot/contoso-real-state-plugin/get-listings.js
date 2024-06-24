import listings from "./listings.json" assert { type: "json" };

// Return only the first 5 results.
const RESULT_LIMIT = 5;

export default function getListings(city, bedrooms, bathrooms, amenities, question) {
  console.log(`Original utterance: ${question}`);

  return listings.filter(listing => {
    const cityMatch = city
      ? listing.city.toLowerCase() === city.toLowerCase()
      : true;

    const bedroomsMatch = bedrooms
      ? listing.bedrooms === bedrooms
      : true;

    const bathroomsMatch = bathrooms
      ? listing.bathrooms === bathrooms
      : true;

      
    const amenitiesMatch = amenities && amenities.length
      ? Array.isArray(amenities)
      ? amenities.every(amenity => listing.amenities.includes(amenity))
      : listing.amenities.includes(amenities)
      : true;

    return cityMatch && bedroomsMatch && bathroomsMatch && amenitiesMatch;
  }).slice(0, RESULT_LIMIT);
}