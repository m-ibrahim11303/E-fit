import 'package:flutter/material.dart';
import 'package:step_sync/step_sync.dart'; // Import your package

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Step Counter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StepCounterScreen(),
    );
  }
}

class StepCounterScreen extends StatefulWidget {
  @override
  _StepCounterScreenState createState() => _StepCounterScreenState();
}

class _StepCounterScreenState extends State<StepCounterScreen> {
  // Create an instance of StepCounter
  final StepCounter stepCounter = StepCounter();

  @override
  void initState() {
    super.initState();
    stepCounter.updateSteps(); // Start listening to step updates
  }

  @override
  void dispose() {
    super.dispose();
    // No need to call dispose() on the StepCounter instance
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Step Counter'),
      ),
      body: Center(
        child: StreamBuilder<int>(
          stream: stepCounter.stepStream, // Listen to the step count stream
          builder: (context, snapshot) {
            // Handle the stream's data
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Display the current step count
                  Text(
                    'Steps Taken: ${snapshot.data}',
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(height: 20),
                  // Button to reset the step count
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        stepCounter
                            .resetSteps(); // Reset step count when the button is pressed
                      });
                    },
                    child: Text('Reset Steps'),
                  ),
                ],
              );
            } else {
              return Text('No data available');
            }
          },
        ),
      ),
    );
  }
}
