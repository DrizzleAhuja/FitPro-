const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cors = require('cors');
const bcrypt = require('bcryptjs');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());

// MongoDB Connection
mongoose.connect('mongodb://localhost:27017/fitproplus', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
  .then(() => console.log('MongoDB connected'))
  .catch(err => console.log(err));

// Schemas
const UserSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
});

const WorkoutPlanSchema = new mongoose.Schema({
  email: { type: String, required: true },
  fitnessGoal: { type: String, required: true },
  gender: { type: String, required: true },
  trainingMethod: { type: String, required: true },
  workoutType: { type: String, required: true },
  strengthLevel: { type: String, required: true },
  planContent: { type: String, required: true },
  date: { type: Date, default: Date.now }
});

const BMISchema = new mongoose.Schema({
  email: { type: String, required: true },
  age: { type: Number, required: true },
  gender: { type: String, required: true },
  weight: { type: Number, required: true },
  heightFeet: { type: Number, required: true },
  heightInches: { type: Number, required: true },
  bmi: { type: Number, required: true },
  category: { type: String, required: true },
  date: { type: Date, default: Date.now }
});

const BMRSchema = new mongoose.Schema({
  email: { type: String, required: true },
  age: { type: Number, required: true },
  gender: { type: String, required: true },
  weight: { type: Number, required: true },
  height: { type: Number, required: true },
  bmr: { type: Number, required: true },
  activityLevels: { type: Object, required: true },
  date: { type: Date, default: Date.now }
});

const User = mongoose.model('User', UserSchema);
const WorkoutPlan = mongoose.model('WorkoutPlan', WorkoutPlanSchema);
const BMI = mongoose.model('BMI', BMISchema);
const BMR = mongoose.model('BMR', BMRSchema);

// Routes
app.post('/signup', async (req, res) => {
  try {
    const { name, email, password } = req.body;
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: 'Email already exists' });
    }
    const hashedPassword = await bcrypt.hash(password, 12);
    const user = new User({ name, email, password: hashedPassword });
    await user.save();
    res.status(201).json({ message: 'User created successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Something went wrong' });
  }
});

app.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }
    res.status(200).json({
      message: 'Login successful',
      userId: user._id,
      email: user.email
    });
  } catch (error) {
    res.status(500).json({ message: 'Something went wrong' });
  }
});

app.post('/save-workout-plan', async (req, res) => {
  try {
    const { email, fitnessGoal, gender, trainingMethod, workoutType, strengthLevel, planContent } = req.body;

    const workoutPlan = new WorkoutPlan({
      email,
      fitnessGoal,
      gender,
      trainingMethod,
      workoutType,
      strengthLevel,
      planContent
    });

    await workoutPlan.save();
    res.status(201).json({ message: 'Workout plan saved successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error saving workout plan' });
  }
});

app.get('/workout-history', async (req, res) => {
  try {
    const { email } = req.query;
    const history = await WorkoutPlan.find({ email })
      .sort({ date: -1 })
      .limit(10);
    res.status(200).json(history);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching workout history' });
  }
});

app.post('/save-bmi', async (req, res) => {
  try {
    const { email, age, gender, weight, heightFeet, heightInches, bmi, category } = req.body;

    const bmiRecord = new BMI({
      email,
      age,
      gender,
      weight,
      heightFeet,
      heightInches,
      bmi,
      category
    });

    await bmiRecord.save();
    res.status(201).json({ message: 'BMI record saved successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error saving BMI record' });
  }
});

app.get('/bmi-history', async (req, res) => {
  try {
    const { email } = req.query;
    const history = await BMI.find({ email })
      .sort({ date: -1 })
      .limit(10);
    res.status(200).json(history);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching BMI history' });
  }
});

app.post('/save-bmr', async (req, res) => {
  try {
    const { email, age, gender, weight, height, bmr, activityLevels } = req.body;

    const bmrRecord = new BMR({
      email,
      age,
      gender,
      weight,
      height,
      bmr,
      activityLevels
    });

    await bmrRecord.save();
    res.status(201).json({ message: 'BMR record saved successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error saving BMR record' });
  }
});

app.get('/bmr-history', async (req, res) => {
  try {
    const { email } = req.query;
    const history = await BMR.find({ email })
      .sort({ date: -1 })
      .limit(10);
    res.status(200).json(history);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching BMR history' });
  }
});

app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
