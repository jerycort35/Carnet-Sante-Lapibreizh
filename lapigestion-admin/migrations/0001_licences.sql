CREATE TABLE licences (
 id TEXT PRIMARY KEY, key_hash TEXT NOT NULL UNIQUE, recipient TEXT NOT NULL,
 tier TEXT NOT NULL CHECK(tier IN ('1','2','3','4','owner')),
 status TEXT NOT NULL DEFAULT 'active' CHECK(status IN ('active','revoked')),
 revision INTEGER NOT NULL DEFAULT 1, device_hash TEXT, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL
);
CREATE UNIQUE INDEX unique_owner ON licences(tier) WHERE tier='owner';
CREATE TABLE challenges (nonce TEXT PRIMARY KEY, expires INTEGER NOT NULL);
CREATE TABLE rate_limits (bucket TEXT PRIMARY KEY, count INTEGER NOT NULL, expires INTEGER NOT NULL);
CREATE TABLE audit (id INTEGER PRIMARY KEY AUTOINCREMENT, at INTEGER NOT NULL, actor TEXT NOT NULL, action TEXT NOT NULL, licence_id TEXT);
