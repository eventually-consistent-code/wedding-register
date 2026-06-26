// Tiny API client. Same-origin /api is proxied to the backend in dev and routed
// by the ALB in AWS, so no base URL is needed.

export async function listGuests() {
  const res = await fetch("/api/guests");
  if (!res.ok) throw new Error("could not load guests");
  return res.json();
}

export async function addGuest(guest) {
  const res = await fetch("/api/guests", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(guest),
  });
  if (!res.ok) {
    const body = await res.json().catch(() => ({}));
    throw new Error(body.error || "could not add guest");
  }
  return res.json();
}
