import React, { useEffect, useState } from "react";
import { listGuests, addGuest } from "./api.js";

// Wedding registry — a guest fills in name/address/phone, the couple sees the
// running list. Deliberately small; it's the demo vehicle for cairn, not a
// product.
export default function App() {
  const [guests, setGuests] = useState([]);
  const [form, setForm] = useState({ name: "", address: "", phone: "" });
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(true);

  async function refresh() {
    try {
      setGuests(await listGuests());
    } catch (e) {
      setError(e.message);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    refresh();
  }, []);

  function update(field) {
    return (e) => setForm({ ...form, [field]: e.target.value });
  }

  async function onSubmit(e) {
    e.preventDefault();
    setError("");
    try {
      await addGuest(form);
      setForm({ name: "", address: "", phone: "" });
      await refresh();
    } catch (e) {
      setError(e.message);
    }
  }

  return (
    <main className="wrap">
      <h1>💍 Wedding Registry</h1>
      <p className="sub">Add your details so we can send a thank-you after the big day.</p>

      <form className="card" onSubmit={onSubmit}>
        <label>
          Name
          <input value={form.name} onChange={update("name")} placeholder="Ada Lovelace" required />
        </label>
        <label>
          Address
          <input value={form.address} onChange={update("address")} placeholder="12 Analytical Way, London" required />
        </label>
        <label>
          Phone
          <input value={form.phone} onChange={update("phone")} placeholder="+44 20 7946 0000" required />
        </label>
        <button type="submit">Add me to the registry</button>
        {error && <p className="error">{error}</p>}
      </form>

      <section className="card">
        <h2>Guests ({guests.length})</h2>
        {loading ? (
          <p>loading…</p>
        ) : guests.length === 0 ? (
          <p className="muted">No guests yet — be the first!</p>
        ) : (
          <ul className="guests">
            {guests.map((g) => (
              <li key={g.id}>
                <strong>{g.name}</strong>
                <span>{g.address}</span>
                <span className="muted">{g.phone}</span>
              </li>
            ))}
          </ul>
        )}
      </section>
    </main>
  );
}
