# my5G-RANTester-Scripts

Scripts to run my5G-RANTester (changes made to replicate results for free5gc only. includes changes to several versions of outdated dependencies.)

## How to run

1. On Ubuntu Server **20.04 LTS**, install Linux Kernel **v5.4.90** following [this tutorial](https://www.how2shout.com/linux/how-to-change-default-kernel-in-ubuntu-22-04-20-04-lts/).

2. Run Experiments with free5GC v3.0.6 or v3.2.1

     ```bash
     sudo -s
     ```

     ```bash
     ./run.sh -c 1
     ./run.sh -c 2
     ```

3. Run Specific Experiments for Paper Replication
   ```bash
   ./run_exp1.sh # Don't forget to ./stop_and_clear.sh before running new experiment
   ./run_exp2.sh # Don't forget to ./stop_and_clear.sh before running new experiment
   ```

## Capture analytics logs and export to .csv file

1. Run the `capture_and_parse_logs.sh` script:

   ```bash
   sudo -s
   ```

   ```bash
   ./capture_and_parse_logs.sh my5grantester_logs.csv
   ```

## How to stop containers and clear data

1. Run the `stop_and_clear.sh` script:

   ```bash
   sudo -s
   ```

   ```bash
   ./stop_and_clear.sh
   ```

## Tips on Debugging

Try to run ```docker prune system``` every now and then to free storage space.
