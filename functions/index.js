import { onDocumentCreated } from "firebase-functions/v2/firestore";
import nodemailer from "nodemailer";

const gmailEmail = "gtvprimeofficial@gmail.com"
const gmailPassword = "duqb vapf vazv mita"

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: gmailEmail,
    pass: gmailPassword,
  },
});

export const sendWelcomeEmail = onDocumentCreated("users/{userId}", async (event) => {
  const snapshot = event.data;

  if (!snapshot) {
    console.log("No data associated with the event");
    return;
  }

  const data = snapshot.data();
  const email = data.email;
  const displayName = data.name || 'User';

  const mailOptions = {
    from: gmailEmail,
    to: email,
    subject: 'Welcome to TaskTracking!',
    text: `Hello ${displayName}, welcome to TaskTracking! We hope you enjoy the experience.`,
    html: `
          <div style="font-family: Arial, sans-serif; line-height: 1.6;">
            <h2>Welcome to Our App, ${displayName}!</h2>
            <p>We're thrilled to have you on board. Here are some features you can explore:</p>
            <ul>
              <li>Manage your tasks easily.</li>
              <li>Get real-time updates.</li>
            </ul>
            <p>If you have any questions, feel free to <a href="mailto:${gmailEmail}">contact us</a>.</p>
            <p>Best regards,<br>The GTV Team</p>
            <footer style="margin-top: 20px; font-size: 0.8em; color: gray;">
              <p>If you didn't sign up for this account, please ignore this email.</p>
            </footer>
          </div>
        `,
  };

  try {
    await transporter.sendMail(mailOptions);
    console.log('Welcome email sent to:', email);
  } catch (error) {
    console.error('Error sending welcome email:', error);
  }
});
