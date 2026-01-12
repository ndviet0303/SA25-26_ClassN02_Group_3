require('dotenv').config();
const express = require('express');
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const nodemailer = require('nodemailer');
const admin = require('firebase-admin');
const cors = require('cors');
const fs = require('fs');

const app = express();

let db;

if (!admin.apps.length) {
  try {
    let credential;
    let config = {};
    
    if (fs.existsSync('./serviceAccountKey.json')) {
      const serviceAccount = require('./serviceAccountKey.json');
      credential = admin.credential.cert(serviceAccount);
      config.projectId = serviceAccount.project_id;
      console.log('✅ Using service account key file');
    } else if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
      credential = admin.credential.applicationDefault();
      config.projectId = process.env.FIREBASE_PROJECT_ID;
      console.log('✅ Using Application Default Credentials');
    } else if (process.env.FIREBASE_PROJECT_ID) {
      config.projectId = process.env.FIREBASE_PROJECT_ID;
      try {
        credential = admin.credential.applicationDefault();
        console.log('✅ Using Application Default Credentials with project ID');
      } catch (adcError) {
        throw new Error('No Firebase credentials found. Please configure serviceAccountKey.json or GOOGLE_APPLICATION_CREDENTIALS');
      }
    } else {
      throw new Error('No Firebase credentials found. Please configure one of: serviceAccountKey.json, GOOGLE_APPLICATION_CREDENTIALS, or FIREBASE_PROJECT_ID');
    }

    if (credential) {
      const initConfig = { credential };
      if (config.projectId || process.env.FIREBASE_PROJECT_ID) {
        initConfig.projectId = config.projectId || process.env.FIREBASE_PROJECT_ID;
      }
      admin.initializeApp(initConfig);
    } else {
      admin.initializeApp(config);
    }
    
    db = admin.firestore();
    console.log('✅ Firebase Admin initialized successfully');
  } catch (error) {
    console.error('❌ Firebase Admin initialization failed:', error.message);
    console.error('\n📝 Setup instructions:');
    console.error('   1. Download service account key from Firebase Console');
    console.error('      https://console.firebase.google.com/project/_/settings/serviceaccounts/adminsdk');
    console.error('   2. Save as: backend/serviceAccountKey.json');
    console.error('   3. Or set GOOGLE_APPLICATION_CREDENTIALS env variable');
    console.error('   4. Or add FIREBASE_PROJECT_ID to .env file\n');
    process.exit(1);
  }
} else {
  db = admin.firestore();
}

app.use(cors());
app.use('/webhook', express.raw({ type: 'application/json' }));
app.use(express.json());

// --- OTP Email Helpers ---
const otpTransporter = nodemailer.createTransport({
  host: 'smtp.gmail.com',
  port: 465,
  secure: true,
  auth: {
    user: process.env.OTP_EMAIL_USER || 'vnhat.dev@gmail.com',
    pass: process.env.OTP_EMAIL_APP_PASSWORD || 'cuok psrl pouf swgq',
  },
  logger: true,
  debug: true,
});

otpTransporter.verify((error, success) => {
  if (error) {
    console.error('❌ SMTP transporter verify failed:', error.message);
  } else {
    console.log('✅ SMTP transporter is ready to send emails');
  }
});

function generateOtp() {
  return Math.floor(1000 + Math.random() * 9000).toString(); // 4 digits
}

async function sendOtpEmail(to, code) {
  const mailOptions = {
    from: `Nozie App <${process.env.OTP_EMAIL_USER || 'vnhat.dev@gmail.com'}>`,
    to,
    subject: 'Your password reset code',
    text: `Your OTP code is ${code}. It expires in 10 minutes.`,
    html: `<p>Your OTP code is <b>${code}</b>. It expires in 10 minutes.</p>`,
  };
  try {
    const info = await otpTransporter.sendMail(mailOptions);
    console.log('📧 OTP email sent:', info.messageId);
  } catch (err) {
    console.error('❌ Failed to send OTP email:', err.message);
    throw err;
  }
}

async function findUserByEmail(email) {
  try {
    const cleaned = String(email).trim();
    return await admin.auth().getUserByEmail(cleaned);
  } catch (e) {
    console.warn('getUserByEmail failed:', {
      email,
      message: e?.message,
      code: e?.code,
      project: admin.app().options?.projectId,
    });
    return null;
  }
}

// POST /auth/forgot-password/send-otp { email }
app.post('/auth/forgot-password/send-otp', async (req, res) => {
  try {
    const { email: rawEmail } = req.body || {};
    const email = typeof rawEmail === 'string' ? rawEmail.trim().toLowerCase() : rawEmail;
    if (!email) return res.status(400).json({ error: 'Email is required' });

    console.log('[send-otp] request for email:', email, 'project:', admin.app().options?.projectId);

    const code = generateOtp();
    const now = admin.firestore.Timestamp.now();
    const expiresAt = admin.firestore.Timestamp.fromMillis(now.toMillis() + 10 * 60 * 1000);

    const docRef = db.collection('password_resets_email').doc(email);
    await docRef.set(
      {
        email,
        code,
        attempts: 0,
        maxAttempts: 5,
        createdAt: now,
        expiresAt,
        verified: false,
      },
      { merge: true }
    );

    console.log('[send-otp] stored code for email:', email, 'expiresAt:', expiresAt.toDate());
    await sendOtpEmail(email, code);
    res.json({ ok: true });
  } catch (error) {
    console.error('send-otp error:', error);
    res.status(500).json({ error: error.message });
  }
});

// POST /auth/forgot-password/verify-otp { email, code }
app.post('/auth/forgot-password/verify-otp', async (req, res) => {
  try {
    const { email: rawEmail, code } = req.body || {};
    const email = typeof rawEmail === 'string' ? rawEmail.trim().toLowerCase() : rawEmail;
    if (!email || !code) return res.status(400).json({ error: 'Email and code are required' });

    console.log('[verify-otp] email:', email, 'code:', code);
    const docRef = db.collection('password_resets_email').doc(email);
    const snap = await docRef.get();
    if (!snap.exists) return res.status(400).json({ error: 'No reset request' });

    const data = snap.data();
    const nowMs = Date.now();
    if (data.expiresAt && data.expiresAt.toMillis() < nowMs) {
      return res.status(400).json({ error: 'Code expired' });
    }
    if (data.attempts >= (data.maxAttempts || 5)) {
      return res.status(429).json({ error: 'Too many attempts' });
    }
    const attempts = (data.attempts || 0) + 1;
    const ok = data.code === code;

    if (!ok) {
      await docRef.set({ attempts }, { merge: true });
      return res.status(400).json({ error: 'Invalid code' });
    }

    const resetToken = require('crypto').randomBytes(24).toString('hex');
    await docRef.set({ verified: true, resetToken, verifiedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
    res.json({ ok: true, resetToken });
  } catch (error) {
    console.error('verify-otp error:', error);
    res.status(500).json({ error: error.message });
  }
});

// POST /auth/forgot-password/reset { email, resetToken, newPassword }
app.post('/auth/forgot-password/reset', async (req, res) => {
  try {
    const { email: rawEmail, resetToken, newPassword } = req.body || {};
    const email = typeof rawEmail === 'string' ? rawEmail.trim().toLowerCase() : rawEmail;
    if (!email || !resetToken || !newPassword) {
      return res.status(400).json({ error: 'email, resetToken, newPassword are required' });
    }

    const docRef = db.collection('password_resets_email').doc(email);
    const snap = await docRef.get();
    if (!snap.exists) return res.status(400).json({ error: 'No reset request' });
    const data = snap.data();
    if (!data.verified || data.resetToken !== resetToken) {
      return res.status(400).json({ error: 'Invalid resetToken' });
    }
    const nowMs = Date.now();
    if (data.expiresAt && data.expiresAt.toMillis() < nowMs) {
      return res.status(400).json({ error: 'Token expired' });
    }

    const user = await findUserByEmail(email); // may be null if not exists; we still return ok
    if (user) {
      await admin.auth().updateUser(user.uid, { password: newPassword });
    }
    await docRef.delete();
    res.json({ ok: true });
  } catch (error) {
    console.error('reset error:', error);
    res.status(500).json({ error: error.message });
  }
});

app.post('/create-payment', async (req, res) => {
  try {
    const { userId, movieId, amount, currency = 'usd' } = req.body;

    const transactionRef = db.collection('users').doc(userId).collection('transactions').doc();
    const transactionId = transactionRef.id;

    await transactionRef.set({
      userId,
      movieId,
      amount,
      currency,
      status: 'pending',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    let customerId;
    const customerSnapshot = await db.collection('users').doc(userId).get();
    
    if (customerSnapshot.exists && customerSnapshot.data().stripeCustomerId) {
      customerId = customerSnapshot.data().stripeCustomerId;
    } else {
      const customer = await stripe.customers.create({ metadata: { userId } });
      customerId = customer.id;
      await db.collection('users').doc(userId).set(
        { stripeCustomerId: customerId },
        { merge: true }
      );
    }

    const ephemeralKey = await stripe.ephemeralKeys.create(
      { customer: customerId },
      { apiVersion: '2024-11-20.acacia' }
    );

    const paymentIntent = await stripe.paymentIntents.create({
      amount: Math.round(amount * 100),
      currency,
      customer: customerId,
      automatic_payment_methods: { enabled: true },
      metadata: { transactionId, userId, movieId },
    });

    res.json({
      clientSecret: paymentIntent.client_secret,
      ephemeralKey: ephemeralKey.secret,
      customerId,
      transactionId,
    });
  } catch (error) {
    console.error('Error creating payment:', error);
    res.status(500).json({ error: error.message });
  }
});

app.post('/webhook', async (req, res) => {
  const sig = req.headers['stripe-signature'];
  const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;

  let event;

  try {
    event = stripe.webhooks.constructEvent(req.body, sig, webhookSecret);
  } catch (err) {
    console.error('Webhook signature verification failed:', err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  try {
    if (event.type === 'payment_intent.succeeded') {
      const paymentIntent = event.data.object;
      const { transactionId, userId, movieId } = paymentIntent.metadata || {};

      if (transactionId && userId) {
        const chargeId = paymentIntent.charges?.data?.[0]?.id || 
                        paymentIntent.latest_charge || 
                        null;

        const updateData = {
          status: 'succeeded',
          paidAt: admin.firestore.FieldValue.serverTimestamp(),
          stripePaymentIntentId: paymentIntent.id,
        };

        if (chargeId) {
          updateData.chargeId = chargeId;
        }

        await db.collection('users').doc(userId).collection('transactions').doc(transactionId).update(updateData);

        if (userId && movieId) {
          // Create/Update purchase
          await db
            .collection('users')
            .doc(userId)
            .collection('purchases')
            .doc(movieId)
            .set({
              movieId,
              transactionId,
              purchasedAt: admin.firestore.FieldValue.serverTimestamp(),
            }, { merge: true });

          // Create notification
          const notifRef = db
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .doc();

          await notifRef.set({
            id: notifRef.id,
            type: 'purchase',
            title: 'Purchase Successful! 🎬',
            description: 'Your payment succeeded and the movie was added to your library.',
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            deepLink: `movie:${movieId}`,
            metadata: {
              movieId,
              transactionId,
              stripePaymentIntentId: paymentIntent.id,
            },
            read: false,
          });
        }
      }
    } else if (event.type === 'payment_intent.payment_failed') {
      const paymentIntent = event.data.object;
      const { transactionId, userId } = paymentIntent.metadata || {};

      if (transactionId && userId) {
        const updateData = {
          status: 'failed',
          failedAt: admin.firestore.FieldValue.serverTimestamp(),
        };

        if (paymentIntent.last_payment_error?.message) {
          updateData.errorMessage = paymentIntent.last_payment_error.message;
        }

        await db.collection('users').doc(userId).collection('transactions').doc(transactionId).update(updateData);
      }
    } else if (event.type === 'payment_intent.canceled') {
      const paymentIntent = event.data.object;
      const { transactionId, userId } = paymentIntent.metadata || {};

      if (transactionId && userId) {
        await db.collection('users').doc(userId).collection('transactions').doc(transactionId).update({
          status: 'canceled',
          canceledAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
    } else {
      console.log(`Unhandled webhook event type: ${event.type}`);
    }

    res.json({ received: true });
  } catch (error) {
    console.error('Webhook handler error:', error);
    console.error('Error stack:', error.stack);
    console.error('Event type:', event?.type);
    console.error('Event data:', JSON.stringify(event?.data, null, 2));
    res.status(500).json({ error: error.message });
  }
});

app.get('/transaction/:userId/:transactionId', async (req, res) => {
  try {
    const { userId, transactionId } = req.params;
    const doc = await db.collection('users').doc(userId).collection('transactions').doc(transactionId).get();

    if (!doc.exists) {
      return res.status(404).json({ error: 'Transaction not found' });
    }

    res.json({ id: doc.id, ...doc.data() });
  } catch (error) {
    console.error('Error fetching transaction:', error);
    res.status(500).json({ error: error.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
}); 