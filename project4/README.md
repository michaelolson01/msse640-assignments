# Selenium Testing

Installing the online-boutique:
If I would have know how much this needs to change my system, I would have put it in it's own virtual machine.

## Setting up the microservices-demo: OnlineBoutique Demo

1. Setup a google project, and have it allowed to use billing.
- Gross, What is google going to charge me for now?

2. Waiting 10 minutes for it to install.
- Coffee, and more coffee. Probably a donut or two.

3. Attaching kubernetes was quick, and watching the pods start up:

``` shell
watch -d -n 10 kubectl get pods
```

## Recording the tests:

1. I installed the Selenium IDE in Firefox from the extensions shop.

2. Added the test, named it to Online Boutique Test

3. Added the URL given by `kubectl get service frontend-external | awk '{print $4}'`

4. Recorded myself clicking the chosen item.

5. Added `Command: Assert Text`
- Used the Select button to select the right element
- Entered the expected value in the `Value` box.

## Recording the test running:

1. Used `simplescreenrecorder` to record the Selenium IDE running the test, and passing.

*Note: empty the cart before the test runs, or the test will fail because the item is added to the cart more than once,*

![Video of the Test Running](Selenium-Boutique-2026-05-01_21.31.23.mp4)
