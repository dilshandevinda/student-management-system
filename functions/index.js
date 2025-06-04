const functions = require('firebase-functions');
const admin = require('firebase-admin');
const randomstring = require("randomstring");

admin.initializeApp();

exports.sendTemporaryPasswordAndCreateUser = functions.https.onCall(async (data, context) => {
  const name = data.name;
  const email = data.email;
  const username = data.username;
  const index = data.index;
  const contact = data.contact;
  const role = data.role;
  const uid = data.uid;

  const tempPassword = randomstring.generate(8);

  try {
    // Set the temporary password using admin.auth()
    await admin.auth().updateUser(uid, {
      password: tempPassword,
    });

    // Update user document in Firestore (without the temporary password)
    await admin.firestore().collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'username': username,
      'index': index,
      'contact': contact,
      'role': role,
      'uid': uid,
      // 'password': tempPassword, // DO NOT STORE TEMP PASSWORD
      'createdAt': admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });

    // Trigger the Email extension to send the email with the temporary password
    const userRecord = await admin.auth().getUser(uid); // Get user details
    await admin.firestore().collection('mail').add({ // Add email to 'mail' collection
      to: [userRecord.email],
      message: {
        subject: 'Welcome to EduConnect!',
        html: `Hi ${name},<br><br>Your account has been created. Your temporary password is: <b>${tempPassword}</b><br><br>Please log in and change your password immediately.<br><br>Thanks,<br>The EduConnect Team`,
      },
    });

    return { message: "Temporary password email sent and user document created." };
  } catch (error) {
    console.error("Error in sendTemporaryPasswordAndCreateUser:", error);
    throw new functions.https.HttpsError('internal', 'Failed to create user and send email.');
  }
});