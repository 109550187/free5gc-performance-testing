#!/bin/bash
# Script to run connectivity tests with all parameter combinations

echo "Running connectivity tests"

# Run for 2 iterations (instead of 10 to save time) - adjust as needed
for e in $(seq 1 10); do
    echo "Starting iteration $e"
    
    # Test both cores if needed (2 = free5GC)
    for c in 2; do
        echo "Running free5GC tests (iteration $e)"
        
        # Test different delays between connections
        for w in 500 400 300 200 100; do
            echo "Testing with delay = $w ms"
            
            # Test different numbers of gNBs
            for i in 1 3 5 7 9 11; do
                echo "Running experiment with $i gNBs (delay=$w ms)"
                
                # Run the experiment
                ./run.sh -c $c -e 1 -g $i -u $((100*$i)) -t 60 -w $w -v

                echo "Waiting for experiment to finish"
                # Sleep time depends on number of gNBs and delay between connections
                # Higher gNB count and lower delay needs more time
                sleep $((90 + $i*30 - $w/10))

                echo "Collecting experiment data"
                bash <(curl -s https://raw.githubusercontent.com/PORVIR-5G-Project/my5G-RANTester-Scripts/main/capture_and_parse_logs.sh) my5grantester-logs-$e-$c-$w-$i.csv

                echo "Clear experiment environment"
                bash <(curl -s https://raw.githubusercontent.com/PORVIR-5G-Project/my5G-RANTester-Scripts/main/stop_and_clear.sh)
                
                # Wait a bit between experiments
                sleep 15
            done
        done
    done
done

echo "All experiments completed!"
