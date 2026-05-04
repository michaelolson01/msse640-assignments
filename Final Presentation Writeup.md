# Final Presentation

## Target Testing Applications

- All my project applications were created using ![Claude](https://claude.ai) with ![Aidermacs](https://github.com/MatthewZMD/aidermacs) in ![Emacs](https://www.gnu.org/software/emacs/).

Screenshot:
![Traffic Light Simulator](VibeCodeProject3/Traffic_Light_Simulator.png)

## Summary of Results:

### Project 1: Unit Testing

For the unit testing, I had claude build the simple triangle test program in common lisp. After it had built the program, I had it build the unit tests for the program. As you can, see, they worked successfully. 

### Project 2: Postman

For the Integration tests with Postman, I continued to use the triangle program, but this time released it as an API. One of the test was to give an example of a post for the test, so I had Claude create a very simple User Account API where a user can add a person, remove a person, get a list of people, and get a single person. I used this quick user API to create the post and a few more get requests.

### Project 3: Jmeter

For the performance testing with Jmeter, I took the user API written in project 2, and created tests for it in Postman. The only test it failed was the stress test, and when I told Claude about the failure, it rebuild the database read and writing part of the backend of the API so it would not fail until it was beyond what the API was expected to handle.

### Project 4: Selenium

For the selenium testing, I did not use any AI, I installed and ran the online boutique microservices-demo. After that I installed the Selenium IDE on my firefox and ran that.

## Short Demo of one of the tests:

For the demo, I will be showing the triangle test (project 1) that I did. On the top right, you can see the code for the triangle test. On the bottom right, is the testing code. On the top left, you can see the test has run, and on the bottom left, you can see a sample of the program running.

## Analysis of Agentic AI coding tools

Agentic tools are very useful for creating code for things that are very specific, and it has been trained well on. For instance, Claude was very good at writing the code for the third vibe project in Javascript, but the entire time I was using it to write in common lisp, it made errors, and often did not understand some of the normal patterns used in common lisp. For all the testing I used the AI on, it did well. I am sure it has been well trained in use of Unit tests, Postman, and Jmeter. I never used it for the Selenium testing, but I am sure if I used the desktop version instead of the Firefox version, I could have had Claude write the tests for me there.
