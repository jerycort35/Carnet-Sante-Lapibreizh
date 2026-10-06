-- Ajoute le mode Essai 7 jours sans modifier les licences existantes.
CREATE TABLE licences_v2 (
 id TEXT PRIMARY KEY, key_hash TEXT NOT NULL UNIQUE, recipient TEXT NOT NULL,
 tier TEXT NOT NULL CHECK(tier IN ('trial','1','2','3','4','owner')),
 status TEXT NOT NULL DEFAULT 'active' CHECK(status IN ('active','revoked')),
 revision INTEGER NOT NULL DEFAULT 1, device_hash TEXT, activated_at INTEGER,
 created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL
);
INSERT INTO licences_v2(id,key_hash,recipient,tier,status,revision,device_hash,activated_at,created_at,updated_at)
 SELECT id,key_hash,recipient,tier,status,revision,device_hash,NULL,created_at,updated_at FROM licences;
DROP TABLE licences;
ALTER TABLE licences_v2 RENAME TO licences;
CREATE UNIQUE INDEX unique_owner ON licences(tier) WHERE tier='owner';
