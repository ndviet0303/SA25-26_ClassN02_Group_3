/**
 * Fake data import: ~10k users into identitydb, customers + interests into customerdb.
 * Run: npm install && node import.js
 * Env: IDENTITY_DB_URL, CUSTOMER_DB_URL (or defaults localhost), IMPORT_USER_COUNT (default 10000).
 */

import pg from 'pg';
const { Client } = pg;

const PASSWORD_HASH = process.env.IMPORT_PASSWORD_HASH || '$2a$10$EU0Cbmh5Z9xUEZmGcvWISOV2kMpHTf/KPosv0bSNuB3WkvxUymy/C';
const USER_COUNT = Math.min(Number(process.env.IMPORT_USER_COUNT) || 10000, 100000);
const BATCH_SIZE = 2000;

const IDENTITY_URL = process.env.IDENTITY_DB_URL || 'postgresql://sa:password@localhost:5432/identitydb';
const CUSTOMER_URL = process.env.CUSTOMER_DB_URL || 'postgresql://sa:password@localhost:5432/customerdb';

// Genres for interests (slug + name)
const GENRES = [
  { slug: 'action', name: 'Hành động' },
  { slug: 'comedy', name: 'Hài' },
  { slug: 'drama', name: 'Chính kịch' },
  { slug: 'horror', name: 'Kinh dị' },
  { slug: 'thriller', name: 'Giật gân' },
  { slug: 'romance', name: 'Tình cảm' },
  { slug: 'sci-fi', name: 'Khoa học viễn tưởng' },
  { slug: 'animation', name: 'Hoạt hình' },
  { slug: 'documentary', name: 'Tài liệu' },
  { slug: 'adventure', name: 'Phiêu lưu' },
  { slug: 'fantasy', name: 'Giả tưởng' },
  { slug: 'mystery', name: 'Bí ẩn' },
];

const FIRST_NAMES = [
  'An', 'Bình', 'Chi', 'Dũng', 'Giang', 'Hà', 'Hùng', 'Lan', 'Minh', 'Nam',
  'Nga', 'Phương', 'Quân', 'Tâm', 'Thu', 'Trung', 'Tú', 'Vy', 'Yến', 'Alex',
  'Jordan', 'Taylor', 'Morgan', 'Casey', 'Riley', 'Avery', 'Quinn', 'Sam',
];

const LAST_NAMES = [
  'Nguyễn', 'Trần', 'Lê', 'Phạm', 'Hoàng', 'Phan', 'Vũ', 'Đặng', 'Bùi', 'Đỗ',
  'Nghiêm', 'Lý', 'Kim', 'Park', 'Chen', 'Smith', 'Johnson', 'Williams', 'Brown', 'Lee',
];

const COUNTRIES = ['VN', 'US', 'KR', 'JP', 'TH', 'SG', 'GB', 'FR', 'DE', 'AU'];
const GENDERS = ['MALE', 'FEMALE', 'OTHER'];

function pick(arr) {
  return arr[Math.floor(Math.random() * arr.length)];
}

function randomDate(fromYear = 1980, toYear = 2005) {
  const y = fromYear + Math.floor(Math.random() * (toYear - fromYear + 1));
  const m = 1 + Math.floor(Math.random() * 12);
  const d = 1 + Math.floor(Math.random() * 28);
  return `${y}-${String(m).padStart(2, '0')}-${String(d).padStart(2, '0')}`;
}

function randomPhone() {
  const n = () => Math.floor(Math.random() * 10);
  if (Math.random() > 0.5) return `0${n()}${n()}${n()}${n()}${n()}${n()}${n()}${n()}${n()}${n()}`;
  return `+84${n()}${n()}${n()}${n()}${n()}${n()}${n()}${n()}${n()}${n()}`;
}

function generateFullName() {
  return `${pick(FIRST_NAMES)} ${pick(LAST_NAMES)}`;
}

async function runIdentityImport(client) {
  console.log('\n--- Identity DB: users + user_roles ---');
  const roleRes = await client.query(`SELECT id FROM roles WHERE name = 'USER' LIMIT 1`);
  if (roleRes.rows.length === 0) {
    throw new Error('Role USER not found in identitydb. Run identity-service once to create roles.');
  }
  const roleId = roleRes.rows[0].id;

  const now = new Date().toISOString().slice(0, 19).replace('T', ' ');
  const pad = Math.max(5, String(USER_COUNT).length);
  const insertUsers = `
    INSERT INTO users (username, email, password, status, failed_login_attempts, created_at, updated_at)
    SELECT
      'fakeuser' || lpad(i::text, $3, '0'),
      'fakeuser' || lpad(i::text, $3, '0') || '@nozie.local',
      $1,
      'ACTIVE',
      0,
      $2::timestamp,
      $2::timestamp
    FROM generate_series(1, $4::int) i
    ON CONFLICT (username) DO NOTHING
    RETURNING id, username
  `;
  const userRes = await client.query(insertUsers, [PASSWORD_HASH, now, pad, USER_COUNT]);
  let userIds = userRes.rows.map((r) => r.id);
  if (userIds.length === 0) {
    const sel = await client.query(
      `SELECT id FROM users WHERE username LIKE 'fakeuser%' ORDER BY id LIMIT $1`,
      [USER_COUNT]
    );
    userIds = sel.rows.map((r) => r.id);
    console.log(`Users: 0 new (using ${userIds.length} existing fake users)`);
  } else {
    console.log(`Users: ${userIds.length} rows (ids ${userIds[0]}..${userIds[userIds.length - 1]})`);
  }

  if (userIds.length === 0) {
    console.log('No user ids to link roles. Skip user_roles.');
    return [];
  }

  for (let i = 0; i < userIds.length; i += BATCH_SIZE) {
    const chunk = userIds.slice(i, i + BATCH_SIZE);
    await client.query(
      `INSERT INTO user_roles (user_id, role_id) SELECT unnest($1::bigint[]), $2
       ON CONFLICT (user_id, role_id) DO NOTHING`,
      [chunk, roleId]
    );
  }
  console.log(`user_roles: ${userIds.length} rows (role_id=${roleId})`);
  return userIds;
}

async function runCustomerImport(client, userIds) {
  if (userIds.length === 0) return;
  console.log('\n--- Customer DB: customers + customer_interests ---');

  const now = new Date().toISOString().slice(0, 19).replace('T', ' ');
  const customerRows = userIds.map((userId) => {
    const fullName = generateFullName();
    return {
      userId,
      fullName,
      dateOfBirth: randomDate(),
      gender: pick(GENDERS),
      country: pick(COUNTRIES),
      phoneNumber: randomPhone(),
      bio: `Profile for ${fullName}.`,
      isSubscribed: false,
      subscriptionStatus: 'FREE',
      createdAt: now,
      updatedAt: now,
    };
  });

  const customerIds = [];
  for (let i = 0; i < customerRows.length; i += BATCH_SIZE) {
    const chunk = customerRows.slice(i, i + BATCH_SIZE);
    const userIdsChunk = chunk.map((r) => r.userId);
    const fullNames = chunk.map((r) => r.fullName);
    const dobs = chunk.map((r) => r.dateOfBirth);
    const genders = chunk.map((r) => r.gender);
    const countries = chunk.map((r) => r.country);
    const phones = chunk.map((r) => r.phoneNumber);
    const bios = chunk.map((r) => r.bio);
    const subs = chunk.map((r) => r.isSubscribed);
    const statuses = chunk.map((r) => r.subscriptionStatus);
    const created = chunk.map(() => now);
    const updated = chunk.map(() => now);

    const insertCustomer = `
      INSERT INTO customers (user_id, full_name, date_of_birth, gender, country, phone_number, bio, is_subscribed, subscription_status, created_at, updated_at)
      SELECT * FROM unnest($1::bigint[], $2::text[], $3::text[], $4::text[], $5::text[], $6::text[], $7::text[], $8::boolean[], $9::text[], $10::timestamp[], $11::timestamp[])
      AS t(user_id, full_name, date_of_birth, gender, country, phone_number, bio, is_subscribed, subscription_status, created_at, updated_at)
      ON CONFLICT (user_id) DO UPDATE SET
        full_name = EXCLUDED.full_name,
        date_of_birth = EXCLUDED.date_of_birth,
        gender = EXCLUDED.gender,
        country = EXCLUDED.country,
        phone_number = EXCLUDED.phone_number,
        bio = EXCLUDED.bio,
        updated_at = EXCLUDED.updated_at
      RETURNING id, user_id
    `;
    const res = await client.query(insertCustomer, [
      userIdsChunk,
      fullNames,
      dobs,
      genders,
      countries,
      phones,
      bios,
      subs,
      statuses,
      created,
      updated,
    ]);
    customerIds.push(...res.rows.map((r) => ({ id: r.id, userId: r.user_id })));
  }
  console.log(`Customers: ${customerIds.length} rows`);

  const interestRows = [];
  for (const c of customerIds) {
    const numInterests = 1 + Math.floor(Math.random() * 5);
    const used = new Set();
    for (let k = 0; k < numInterests; k++) {
      const g = pick(GENRES);
      if (used.has(g.slug)) continue;
      used.add(g.slug);
      interestRows.push({ customerId: c.id, slug: g.slug, name: g.name });
    }
  }

  for (let i = 0; i < interestRows.length; i += BATCH_SIZE) {
    const chunk = interestRows.slice(i, i + BATCH_SIZE);
    const customerIdsArr = chunk.map((r) => r.customerId);
    const slugs = chunk.map((r) => r.slug);
    const names = chunk.map((r) => r.name);
    const created = chunk.map(() => now);

    const insertInterest = `
      INSERT INTO customer_interests (customer_id, genre_slug, genre_name, created_at)
      SELECT * FROM unnest($1::bigint[], $2::text[], $3::text[], $4::timestamp[])
      AS t(customer_id, genre_slug, genre_name, created_at)
      ON CONFLICT (customer_id, genre_slug) DO NOTHING
    `;
    await client.query(insertInterest, [customerIdsArr, slugs, names, created]);
  }
  console.log(`customer_interests: ${interestRows.length} rows`);
}

async function main() {
  const dryRun = process.argv.includes('--dry-run');
  if (dryRun) {
    console.log('Dry run. Would import', USER_COUNT, 'users. Set env and run without --dry-run.');
    return;
  }

  console.log('Config: users=', USER_COUNT, 'identity=', IDENTITY_URL, 'customer=', CUSTOMER_URL);

  const identityClient = new Client({ connectionString: IDENTITY_URL });
  const customerClient = new Client({ connectionString: CUSTOMER_URL });

  try {
    await identityClient.connect();
    await customerClient.connect();

    const userIds = await runIdentityImport(identityClient);
    await runCustomerImport(customerClient, userIds);

    console.log('\nDone.');
  } catch (e) {
    console.error(e);
    process.exit(1);
  } finally {
    await identityClient.end();
    await customerClient.end();
  }
}

main();
