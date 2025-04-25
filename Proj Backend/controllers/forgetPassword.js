import nodemailer from "nodemailer";
import { User } from "../models/user.js";


let otpStore = {}; 

const generateOTP = () => Math.floor(100000 + Math.random() * 900000).toString();

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "efit.lums@gmail.com",
    pass: "mggs zkng nwrk rmqh"
  },
});

export const sendForgotPasswordOTP = async (req, res) => {
  const { email } = req.body;

  if (!email) return res.status(400).json({ error: "Email is required" });

  const user = await User.findOne({ email });
  if (!user) return res.status(404).json({ error: "User not found" });

  const otp = generateOTP();
  const expiresAt = Date.now() + 5 * 60 * 1000; // OTP expires in 5 minutes

  otpStore[email] = { code: otp, expiresAt };

  const mailOptions = {
    from: process.env.EMAIL_USER,
    to: email,
    subject: "E-Fit Password Reset OTP",
    html: `<p>Your OTP is: <strong>${otp}</strong></p>`,
  };

  try {
    await transporter.sendMail(mailOptions);
    res.status(200).json({ message: "OTP sent successfully" });
  } catch (err) {
    res.status(500).json({ error: "Failed to send OTP" });
  }
};

export const verifyForgotPasswordOTP = (req, res) => {
  const { email, code } = req.body;

  if (!email || !code) return res.status(400).json({ error: "Email and code required" });

  const record = otpStore[email];
  if (!record || record.code !== code || Date.now() > record.expiresAt) {
    return res.status(400).json({ error: "Invalid or expired OTP "});
  }

  res.status(200).json({ message: "OTP verified" });
};

export const resetForgotPassword = async (req, res) => {
  const { email, code, newPassword } = req.body;

  if (!email || !code || !newPassword) return res.status(400).json({ error: "Email and new password are required" });

  const user = await User.findOne({ email });
  if (!user) return res.status(404).json({ error: "User not found" });

  user.password = newPassword
  await user.save();

  delete otpStore[email]; // Cleanup OTP after successful reset
  res.status(200).json({ message: "Password reset successfully" });
};
