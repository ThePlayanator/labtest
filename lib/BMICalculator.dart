//import 'dart:html';
import 'package:flutter/material.dart';
import 'package:labtest/sqldb.dart';

void main() {
  runApp(BMICalculator());
}

class BMI {
  final String name;
  final String height;
  final String weight;

  BMI(this.name, this.height, this.weight);
}

class BMICalculator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BMIList(),
    );
  }
}

class BMIList extends StatefulWidget {
  @override
  _BMIListState createState() => _BMIListState();
}

class _BMIListState extends State<BMIList> {
  final List<BMI> bmis = [];
  final TextEditingController nameController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController bmiStatusController = TextEditingController();
  final TextEditingController bmiValueController = TextEditingController();

  String? gender;

  void _calcBMI() {
    double bmi = 0;
    String name = nameController.text;
    String height = heightController.text;
    String weight = weightController.text;
    String Gender = gender?.toString() ?? '';
    String status='';

    if (height.isNotEmpty && weight.isNotEmpty) {
      setState(() {
        double newHeight = double.parse(height);
        double newWeight = double.parse(weight);
        newHeight = newHeight / 100;
        bmi = newWeight / (newHeight * newHeight);

        if (Gender == "male") {
          if (bmi < 18.5) {
            status = "Underweight. Careful during strong wind!";
          } else if (bmi >= 18.5 && bmi <= 24.9) {
            status = "That's ideal! Please maintain";
          } else if (bmi >= 25.0 && bmi <= 29.9) {
            status = "Overweight! Work out please";
          } else if (bmi >= 30.0) {
            status = "Whoa Obese! Dangerous mate!";
          }
        } else if (Gender == "female") {
          if (bmi < 16) {
            status =
                "Underweight. Careful during strong wind!";
          } else if (bmi >= 16 && bmi <= 22) {
            status = "That's ideal! Please maintain";
          } else if (bmi > 22 && bmi <= 27) {
            status = "Overweight! Work out please";
          } else if (bmi > 27.0) {
            status = "Whoa Obese! Dangerous mate!";
          }
        }
        _alertMessage(status);

        bmis.add(BMI(name, height, weight));

        nameController.clear();
        heightController.clear();
        weightController.clear();
        bmiValueController.text = bmi.toStringAsFixed(2);
      });
    }
  }

  void _alertMessage(String msg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Message"),
          content: Text(msg),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    retrievePreviousData();
  }

  Future<void> retrievePreviousData() async {
    List<Map<String, dynamic>> previousData =
        await SQLDB().queryAll('bitp3453_bmi');
    if (previousData.isNotEmpty) {
      Map<String, dynamic> latestData =
          previousData.last; //  take the last data in the list
      setState(() {
        nameController.text = latestData['username'];
        heightController.text = latestData['height'].toString();
        weightController.text = latestData['weight'].toString();
        bmiStatusController.text = latestData['bmi_status'];
        genderController.text = latestData['gender'];
      });
      SQLDB().insert('bmi', latestData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BMI Calculator'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Your Fullname',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: heightController,
                decoration: InputDecoration(
                  labelText: 'height in cm; 170',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: weightController,
                decoration: InputDecoration(
                  labelText: 'Weight in KG',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                readOnly: true,
                controller: bmiValueController,
                decoration: const InputDecoration(
                  labelText: 'BMI Value',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Male'),
                      leading: Radio(
                        value: 'male',
                        groupValue: gender,
                        onChanged: (value) {
                          setState(() {
                            gender = value.toString();
                            //genderController.text = gender.toString();
                          });
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('Female'),
                      leading: Radio(
                        value: 'female',
                        groupValue: gender,
                        onChanged: (value) {
                          setState(() {
                            gender = value.toString();
                            //genderController.text = gender.toString();
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _calcBMI,
              child: Text('Calculate BMI and Save'),
            ),
          ],
        ),
      ),
    );
  }
}
