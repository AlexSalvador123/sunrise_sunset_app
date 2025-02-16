rails s - por a correr o backend
npm start - por a correr o frontend
sudo service postgresql start - inicializar a base de dados

# Sunrise & Sunset App

## To run Backend

   Navigate to sunrise_sunset(backend directory) and run the following command lines

   rails db:create
   rails db:migrate
   rails s

## To run Frontend 

   Navigate to sunrise-sunset-frontend(frontend directory) and run the following command lines

   rnpm start


## Environment Variables

You need an API key for geolocation services. Add the following to your `.env` file:

```
GEO_API_KEY=your_opencagedata_api_key
```