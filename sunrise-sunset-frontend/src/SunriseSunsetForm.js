import { useState } from "react";
import "./styles.css";

const SunriseSunsetForm = ({ fetchSunriseSunset }) => {
  const [location, setLocation] = useState("");
  const [startDate, setStartDate] = useState("");
  const [endDate, setEndDate] = useState("");

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!location || !startDate || !endDate) {
      alert("Please fill in all fields!");
      return;
    }
    fetchSunriseSunset(location, startDate, endDate);
  };

  return (
    <form onSubmit={handleSubmit} className="form-container" style={{ textAlign: "left" }}>
      <label style={{ display: "block" }}>
        Location: 
        <input
          type="text"
          placeholder="e.g. Lisbon"
          value={location}
          onChange={(e) => setLocation(e.target.value)}
          required
        />
      </label>
      <label style={{ display: "block" }}>
        Start Date: 
        <input
          type="date"
          value={startDate}
          onChange={(e) => setStartDate(e.target.value)}
          required
        />
      </label>
      <label style={{ display: "block" }}>
        End Date: 
        <input
          type="date"
          value={endDate}
          onChange={(e) => setEndDate(e.target.value)}
          required
        />
      </label>
      <button type="submit">🔍 Search</button>
    </form>
  );
};

export default SunriseSunsetForm;
