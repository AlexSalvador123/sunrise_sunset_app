import { useState } from "react";
import SunriseSunsetForm from "./SunriseSunsetForm";
import { Line } from "react-chartjs-2";
import { Chart as ChartJS, CategoryScale, LinearScale, PointElement, LineElement, Title, Tooltip, Legend } from "chart.js";
import "./styles.css";

ChartJS.register(CategoryScale, LinearScale, PointElement, LineElement, Title, Tooltip, Legend);

const SunriseSunsetDisplay = () => {
  const [data, setData] = useState(null);
  const [error, setError] = useState("");

  const fetchSunriseSunset = async (location, startDate, endDate) => {
    setError("");
    setData(null);

    try {
      const response = await fetch(
        `http://localhost:3000/api/sunrise_sunset?location=${location}&start_date=${startDate}&end_date=${endDate}`
      );
      const result = await response.json();

      if (response.ok) {
        setData(result);
      } else {
        setError(result.error || "Error fetching data");
      }
    } catch (err) {
      setError("Error connecting to the server");
    }
  };

  
  const chartData = data
    ? {
        labels: data.map((item) => item.date),
        datasets: [
          {
            label: "Sunrise Time",
            data: data.map((item) => new Date(item.sunrise).getHours() + new Date(item.sunrise).getMinutes() / 60),
            borderColor: "#ffcc00",
            backgroundColor: "rgba(255, 204, 0, 0.2)",
            tension: 0.3,
          },
          {
            label: "Sunset Time",
            data: data.map((item) => new Date(item.sunset).getHours() + new Date(item.sunset).getMinutes() / 60),
            borderColor: "#ff5733",
            backgroundColor: "rgba(255, 87, 51, 0.2)",
            tension: 0.3,
          },
        ],
      }
    : null;

  return (
    <div className="container">
      <h4>Enter the parameters to retrieve sunrise and sunset timings for your selected location.</h4>

      <SunriseSunsetForm fetchSunriseSunset={fetchSunriseSunset} />

      {error && <p className="error">{error}</p>}

      {data && (
        <div className="data-container">
          <table>
            <thead>
              <tr>
                <th>Date</th>
                <th>Sunrise</th>
                <th>Sunset</th>
                <th>Golden Hour</th>
              </tr>
            </thead>
            <tbody>
              {data.map((item, index) => (
                <tr key={index}>
                  <td>{item.date}</td>
                  <td>{item.sunrise}</td>
                  <td>{item.sunset}</td>
                  <td>{item.golden_hour}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
};

export default SunriseSunsetDisplay;
