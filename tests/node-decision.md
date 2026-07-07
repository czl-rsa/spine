## Node 3 — sync or via a queue?  [GOLDEN·decision]
**Crystal:** move processing to a queue: a worker handles jobs asynchronously.
**Why:** peak load must not block the user-facing response.
**Rejected:** a synchronous call in the request — simpler, but tanks latency under peak.
