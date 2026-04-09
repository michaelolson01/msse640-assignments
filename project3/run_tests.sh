#!/bin/bash
set -e

echo Cleaning old runs
rm -rf report_load_10 report_load_50 report_load_100 *.jtl

echo Running tests

~/Downloads/apache-jmeter-5.6.3/bin/jmeter -n -t ./JMeter-Users-Load-10.jmx -l results-load-10.jtl -e -o ./report_load_10/
~/Downloads/apache-jmeter-5.6.3/bin/jmeter -n -t ./JMeter-Users-Load-50.jmx -l results-load-50.jtl -e -o ./report_load_50/ 
~/Downloads/apache-jmeter-5.6.3/bin/jmeter -n -t ./JMeter-Users-Load-100.jmx -l results-load-100.jtl -e -o ./report_load_100/
~/Downloads/apache-jmeter-5.6.3/bin/jmeter -n -t ./JMeter-Users-Stress-100.jmx -l results-stress-100.jtl -e -o ./report_stress-100/
~/Downloads/apache-jmeter-5.6.3/bin/jmeter -n -t ./JMeter-Users-Stress-200.jmx -l results-stress-200.jtl -e -o ./report_stress-200/
~/Downloads/apache-jmeter-5.6.3/bin/jmeter -n -t ./JMeter-Users-Stress-300.jmx -l results-stress-300.jtl -e -o ./report_stress-300/
~/Downloads/apache-jmeter-5.6.3/bin/jmeter -n -t ./JMeter-Users-Endurance-5m.jmx -l results-endurance-5m.jtl -e -o ./report_endurance-5m/
~/Downloads/apache-jmeter-5.6.3/bin/jmeter -n -t ./JMeter-Users-Endurance-10m.jmx -l results-endurance-10m.jtl -e -o ./report_endurance-10m/
~/Downloads/apache-jmeter-5.6.3/bin/jmeter -n -t ./JMeter-Users-Endurance-15m.jmx -l results-endurance-15m.jtl -e -o ./report_endurance-15m/

echo Finished tests
