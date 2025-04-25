import { User } from "../models/user.js";
import { UserMeals } from "../models/userMeals.js";
import { waterLog } from "../models/waterlog.js";
import { UserExercise } from "../models/userExercise.js";


// Save user meals
export const saveMeals = async (req, res) => {
  try {
    const { email, items } = req.body;

    // Basic validation
    if (!email || !items || !Array.isArray(items) || items.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Email and items array are required'
      });
    }
    const users = await User.find({ email: email });

    if (users.length === 0) {
      return res.status(404).json({ error: "User not found" });
    }

    const mealsToSave = items.map(item => ({
      userEmail: email,
      name: item.name,
      calories: item.calories,
      protein: item.protein,
    }));

    const savedMeals = await UserMeals.insertMany(mealsToSave);

    const totals = {
      calories: items.reduce((sum, item) => sum + item.calories, 0),
      protein: items.reduce((sum, item) => sum + item.protein, 0)
    };

    return res.status(201).json({
      success: true,
      message: 'Meals saved successfully',
      data: {
        count: savedMeals.length,
        totals,
        meals: savedMeals.map(meal => ({
          id: meal._id,
          name: meal.name,
          calories: meal.calories,
          protein: meal.protein,
          timestamp: meal.timestamp
        }))
      }
    });

  } catch (error) {
    return res.status(500).json({
      success: false,
      message: 'Failed to save meals',
      error: error.message
    });
  }
};

// Diet history for user
export const getDietHistory = async (req, res) => {
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

    const meals = await UserMeals.find({ userEmail: email })
      .sort({ timestamp: -1 });

    if (!meals || meals.length === 0) {
      return res.status(200).json({
        success: true,
        data: {
          numberOfDays: 0,
          days: []
        }
      });
    }

    // Grouping meals by day
    const mealsByDay = {};
    meals.forEach(meal => {
      const dateStr = meal.timestamp.toISOString().split('T')[0];
      if (!mealsByDay[dateStr]) {
        mealsByDay[dateStr] = [];
      }
      mealsByDay[dateStr].push(meal);
    });

    // Formatting the data to match frontend structure
    const todayStr = new Date().toISOString().split('T')[0];
    const yesterdayStr = new Date(Date.now() - 86400000).toISOString().split('T')[0];

    const days = Object.keys(mealsByDay).map(dateStr => {
      const dayMeals = mealsByDay[dateStr];

      let dayName;
      if (dateStr === todayStr) {
        dayName = "Today";
      } else if (dateStr === yesterdayStr) {
        dayName = "Yesterday";
      } else {
        dayName = new Date(dateStr).toLocaleDateString('en-US', {
          weekday: 'long',
          month: 'short',
          day: 'numeric'
        });
      }


      return {
        name: dayName,
        noOfMeals: dayMeals.length,
        meals: dayMeals.map(meal => ({
          [meal.name]: `Calories(kcal): ${meal.calories}\nProtein(grams): ${meal.protein}`
        }))
      };
    });

    const responseData = {
      numberOfDays: days.length,
      days: days
    };

    return res.status(200).json({
      success: true,
      data: responseData
    });

  } catch (error) {
    return res.status(500).json({
      success: false,
      message: 'Failed to fetch diet history',
      error: error.message
    });
  }
};


export const logWater = async (req, res) => {
  const { email, amount } = req.body;

  if (!email || !amount) {
    return res.status(400).json({ message: 'Email and amount are required' });
  }

  const users = await User.find({ email: email });

  if (users.length === 0) {
    return res.status(404).json({ error: "User not found" });
  }

  try {
    // Create a new water log entry
    const newWaterLog = new waterLog({
      email,
      amount,
    });

    await newWaterLog.save();

    res.status(200).json({ message: 'Water intake logged successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};


export const saveExercises = async (req, res) => {
  try {
    const { email, exercises } = req.body;
    if (!email || !exercises || !Array.isArray(exercises) || exercises.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Email and exercises array are required'
      });
    }

    const users = await User.find({ email: email });

    if (users.length === 0) {
      return res.status(404).json({ error: "User not found" });
    }

    // Prepare exercises data for bulk insert
    const exercisesToSave = exercises.map(exerciseItem => {
      const exercise = exerciseItem.exercise;
      return {
        userEmail: email,
        name: exercise.name,
        timer: exercise.timer,
        typeOfExercise: exercise.typeOfExercise,
        sets: exerciseItem.setData.map(set => ({
          setNumber: set.set,
          value: Number(set.value),
          type: set.type,
          weight: set.weight ? Number(set.weight) : null
        }))
      };
    });

    const savedExercises = await UserExercise.insertMany(exercisesToSave);

    return res.status(201).json({
      success: true,
      message: 'Exercises saved successfully',
      data: {
        count: savedExercises.length,
        exercises: savedExercises.map(exercise => ({
          id: exercise._id,
          name: exercise.name,
          type: exercise.typeOfExercise,
          sets: exercise.sets.map(set => ({
            setNumber: set.setNumber,
            value: set.value,
            type: set.type,
            weight: set.weight
          })),
          timestamp: exercise.timestamp
        }))
      }
    });

  } catch (error) {
    return res.status(500).json({
      success: false,
      message: 'Failed to save exercises',
      error: error.message
    });
  }
};

export const getWorkoutHistory = async (req, res) => {
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

    // Get exercises from database, sorted by timestamp (newest first)
    const exercises = await UserExercise.find({ userEmail: email })
      .sort({ timestamp: -1 });

    if (!exercises || exercises.length === 0) {
      return res.status(200).json({
        success: true,
        data: {
          numberOfDays: 0,
          days: []
        }
      });
    }

    // Group exercises by day
    const exercisesByDay = {};
    exercises.forEach(exercise => {
      const dateStr = exercise.timestamp.toISOString().split('T')[0];
      if (!exercisesByDay[dateStr]) {
        exercisesByDay[dateStr] = [];
      }
      exercisesByDay[dateStr].push(exercise);
    });

    // Formatting the data for frontend
    const todayStr = new Date().toISOString().split('T')[0];
    const yesterdayStr = new Date(Date.now() - 86400000).toISOString().split('T')[0]; // subtract 1 day in ms

    const days = Object.keys(exercisesByDay).map(dateStr => {
      const dayExercises = exercisesByDay[dateStr];

      let dayName;
      if (dateStr === todayStr) {
        dayName = "Today";
      } else if (dateStr === yesterdayStr) {
        dayName = "Yesterday";
      } else {
        dayName = new Date(dateStr).toLocaleDateString('en-US', {
          weekday: 'long',
          month: 'short',
          day: 'numeric'
        });
      }


      return {
        name: dayName,
        noOfExercises: dayExercises.length,
        exercises: dayExercises.map(exercise => {
          // Format sets information
          const setsInfo = exercise.sets.map(set => {
            let setText = `Set ${set.setNumber}: `;
            if (exercise.timer) {
              setText += `${set.value} minutes`;
            } else {
              setText += `${set.value} reps`;
              if (set.weight) {
                setText += ` (${set.weight} kg)`;
              }
            }
            return setText;
          }).join('\n');

          return {
            [exercise.name]: setsInfo
          };
        })
      };
    });

    const responseData = {
      numberOfDays: days.length,
      days: days
    };

    return res.status(200).json({
      success: true,
      data: responseData
    });

  } catch (error) {
    return res.status(500).json({
      success: false,
      message: 'Failed to fetch workout history',
      error: error.message
    });
  }
};


export const getStreaks = async (req, res) => {
  try {
    const { email } = req.query;

    if (!email) {
      return res.status(400).json({
        success: false,
        message: 'Email is required'
      });
    }

    const users = await User.find({ email });
    if (users.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    const exercises = await UserExercise.find({ userEmail: email }).sort({ timestamp: -1 });

    if (!exercises || exercises.length === 0) {
      return res.status(200).json({ success: true, streak: 0 });
    }

    // Extract dates with at least one exercise
    const exerciseDatesSet = new Set(
      exercises.map(ex => ex.timestamp.toISOString().split('T')[0])
    );

    let streak = 0;
    let currentDate = new Date();

    // Check backwards from today
    while (true) {
      const dateStr = currentDate.toISOString().split('T')[0];
      if (exerciseDatesSet.has(dateStr)) {
        streak += 1;
        // Move to previous day
        currentDate.setDate(currentDate.getDate() - 1);
      } else {
        break;
      }
    }

    return res.status(200).json({ success: true, streak });

  } catch (error) {
    return res.status(500).json({
      success: false,
      message: 'Failed to get streak',
      error: error.message
    });
  }
};
