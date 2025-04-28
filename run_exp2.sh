#!/bin/bash
# Script to run connectivity tests with all parameter combinations

# Create a results directory with timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
RESULTS_DIR="experiment2_results_${TIMESTAMP}"
mkdir -p "$RESULTS_DIR"

echo "[$(date)] Starting data plane performance tests. Results will be saved to $RESULTS_DIR"

# Run for multiple iterations
for e in $(seq 1 2); do  # Running 2 iterations instead of 16 to save time
    echo "[$(date)] Starting iteration $e"
    
    # Test with different numbers of UEs
    for ue_count in 1 2 4 6 8 10; do
        echo "[$(date)] Running test with $ue_count UEs"
        
        # Start the experiment
        echo "[$(date)] Setting up 5G environment with $ue_count UEs"
        ./run.sh -c 1 -e 2 -g $ue_count -v

        # Wait for connections to establish
        CONNECTION_WAIT_TIME=$((1*60))
        echo "[$(date)] Waiting $CONNECTION_WAIT_TIME seconds for connections to establish..."
        sleep $CONNECTION_WAIT_TIME
        
        # Run iPerf for each UE
        echo "[$(date)] Starting iPerf tests..."       
        for j in $(seq 0 $(($ue_count - 1))); do
            echo "[$(date)] Running iPerf test for UE $j"
            docker exec my5grantester$j sh -c "IP=\$(ip -4 addr show uetun1 | grep -oP '(?<=inet\s)\d+(\.\d+){3}') && iperf -c iperf --bind \$IP -t 60 -i 1 -y C" > "$RESULTS_DIR/my5grantester-iperf-$e-1-$ue_count-$j.csv" &
        done
        
        # Wait for iPerf tests to complete (60 seconds test + buffer)
        echo "[$(date)] Waiting for iPerf tests to complete..."
        sleep $((80))
        
        # Check if files were created successfully
        for j in $(seq 0 $(($ue_count - 1))); do
            if [ -s "$RESULTS_DIR/my5grantester-iperf-${e}-1-${ue_count}-${j}.csv" ]; then
                echo "[$(date)] Successfully collected data for UE $j"
            else
                echo "[$(date)] WARNING: Data collection may have failed for UE $j"
            fi
        done

        echo "Collecting experiment $ue_count data from influxdb"
        docker exec influxdb sh -c "influx query 'from(bucket:\"database\") |> range(start:-5m)' --raw" > "$RESULTS_DIR/my5grantester-iperf-influxdb-$e-1-$ue_count.csv"

        # Clean up before next test
        echo "[$(date)] Cleaning environment..."
        bash <(curl -s https://raw.githubusercontent.com/PORVIR-5G-Project/my5G-RANTester-Scripts/main/stop_only.sh)
        
        # Wait before starting next test
        echo "[$(date)] Waiting 30 seconds before next test..."
        sleep 30
    done
done

docker image prune --filter="dangling=true" -f
docker volume prune -f
echo "[$(date)] All tests completed! Results are saved in $RESULTS_DIR"
