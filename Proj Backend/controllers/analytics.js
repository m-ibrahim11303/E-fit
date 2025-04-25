import { User } from "../models/user.js";
import { UserMeals } from "../models/userMeals.js";
import { waterLog } from '../models/waterlog.js'; // <-- Import this

export const getDietAnalytics = async (req, res) => {
    try {
        const { email } = req.query;

        if (!email) {
            return res.status(400).json({
                success: false,
                message: 'Email is required'
            });
        }

        const users = await User.find({ email: email });
        if (users.length === 0) {
            return res.status(404).json({ error: "User not found" });
        }

        const today = new Date();
        today.setHours(0, 0, 0, 0);
        const weekAgo = new Date(today);
        weekAgo.setDate(today.getDate() - 6);

        // Fetch last 7 days of data (including today)
        const meals = await UserMeals.find({
            userEmail: email,
            timestamp: { $gte: weekAgo }
        });

        const waterLogs = await waterLog.find({
            email: email,
            timestamp: { $gte: weekAgo }
        });

        const dailyTotals = [];
        const dateLabels = [];

        for (let i = 0; i < 7; i++) {
            const date = new Date(today);
            date.setDate(today.getDate() - (6 - i));

            const startOfDay = new Date(date);
            startOfDay.setHours(0, 0, 0, 0);
            const endOfDay = new Date(date);
            endOfDay.setHours(23, 59, 59, 999);

            const label = i === 6 ? "Today" : date.toLocaleDateString("en-US", { weekday: "short" });

            // Filter for this specific day
            const mealsOnDay = meals.filter(
                meal => meal.timestamp >= startOfDay && meal.timestamp <= endOfDay
            );
            const waterOnDay = waterLogs.filter(
                log => log.timestamp >= startOfDay && log.timestamp <= endOfDay
            );

            const calories = mealsOnDay.reduce((sum, m) => sum + m.calories, 0);
            const protein = mealsOnDay.reduce((sum, m) => sum + m.protein, 0);
            const water = waterOnDay.reduce((sum, w) => sum + w.amount, 0);

            dailyTotals.push({ label, calories, protein, water });
        }

        const xLabels = dailyTotals.map(d => d.label);
        const calorieYVals = dailyTotals.map(d => d.calories);
        const proteinYVals = dailyTotals.map(d => d.protein);
        const waterYVals = dailyTotals.map(d => d.water);

        const responseData = [
            {
                title: "Calories",
                x_vals: xLabels,
                y_vals: calorieYVals,
                xlabel: "Day",
                ylabel: "Calories (kcal)"
            },
            {
                title: "Proteins",
                x_vals: xLabels,
                y_vals: proteinYVals,
                xlabel: "Day",
                ylabel: "Protein (g)"
            },
            {
                title: "Water Intake",
                x_vals: xLabels,
                y_vals: waterYVals,
                xlabel: "Day",
                ylabel: "Water (ml)"
            }
        ];

        return res.status(200).json({
            success: true,
            data: responseData
        });

    } catch (error) {
        console.error("Error in getDietAnalytics:", error);
        return res.status(500).json({
            success: false,
            message: "Failed to get diet analytics",
            error: error.message
        });
    }
};
