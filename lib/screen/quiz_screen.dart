import 'dart:async';
import 'package:api_quiz_app/screen/result_screen.dart';
import 'package:flutter/material.dart';
import '../api_services.dart';
import '../constants.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late Future quiz;
  int seconds = 30;
  var currentQuestionIndex = 0;
  Timer? timer;
  bool isLoaded = false;
  bool optionSelected = false; // New flag to track if an option is selected
  var optionsList = [];
  int correctAnswers = 0;
  int incorrectAnswers = 0;

  @override
  void initState() {
    super.initState();
    quiz = getQuiz();
    startTimer();
  }

  var optionsColor = [
    Colors.white,
    Colors.white,
    Colors.white,
    Colors.white,
    Colors.white,
  ];

  resetColors() {
    optionsColor = [
      Colors.white,
      Colors.white,
      Colors.white,
      Colors.white,
      Colors.white,
    ];
  }

  resetOptionSelected() {
    optionSelected = false;
  }

  startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (seconds > 0) {
          seconds--;
        } else {
          gotoNextQuestion();
        }
      });
    });
  }

  gotoNextQuestion() {
    setState(() {
      isLoaded = false;
      currentQuestionIndex++;
      resetColors();
      resetOptionSelected(); // Reset the flag when moving to the next question
      timer!.cancel();
      seconds = 30;
      startTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue,
              blue, 
              darkBlue,
            ],
          ),
        ),
        child: FutureBuilder(
          future: quiz,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            // for error handling 
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Error:${snapshot.error}",
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              );
            } else if (snapshot.hasData) {
              var data = snapshot.data["results"];
      
              if (isLoaded == false) {
                optionsList = data[currentQuestionIndex]["incorrect_answers"];
                optionsList.add(data[currentQuestionIndex]["correct_answer"]);
                optionsList.shuffle();
                isLoaded = true;
              }
      
          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: Colors.white, 
                            width: 3,
                          ),
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                      ),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            "$seconds",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          ),
                          SizedBox(
                            width: 70,
                            height: 70,
                            child: CircularProgressIndicator(
                              value: seconds / 30,
                              valueColor:
                                  const AlwaysStoppedAnimation(Colors.white),
                            ),
                          ),
                        ],
                      ),
                     
                    ],  
                  ),
                  const SizedBox(height: 20),
                  Image.asset("assets/images/ideas.png", width: 200,),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Question ${currentQuestionIndex + 1} of ${data.length}",
                      style: const TextStyle(
                        color: lightgrey,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    data[currentQuestionIndex]["question"],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: optionsList.length,
                    itemBuilder: (BuildContext context, int index) {
                      var correctAnswer =
                          data[currentQuestionIndex]['correct_answer'];
                  
                      return GestureDetector(
                        onTap: () {
                          if (!optionSelected) {
                            setState(() {
                              optionSelected = true; // Set the flag to true
                              if (correctAnswer.toString() ==
                                  optionsList[index].toString()) {
                                optionsColor[index] = Colors.green;
                                correctAnswers++;
                              } else {
                                optionsColor[index] = Colors.red;
                                incorrectAnswers++;
                              }
                              if (currentQuestionIndex < 
                                  data.length - 1) {
                                Future.delayed(const Duration(seconds: 1), () {
                                  gotoNextQuestion();
                                });
                              } else {
                                timer!.cancel();
                                Navigator.push(
                                  context, 
                                  MaterialPageRoute(
                                    builder: (context)=>ResultScreen(
                                      correctAnswers, 
                                      incorrectAnswers, 
                                      currentQuestionIndex+1,
                                    ),
                                  ),
                                );
                                //here you can do whatever you want with the results
                              }
                            });
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width - 100,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: optionsColor[index],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            optionsList[index].toString(),
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        } else {
          return const Center(
            child: Text("No Data Found"),
          );
        }
      },
    ),
  ),
    );
  }
}
