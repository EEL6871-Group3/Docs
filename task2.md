# Group project(Task 2)

# Questions for task two

Which model do we choose and why?

Which controller do you choose and why

How to create the two scenarios(weak load jobs → heavy load jobs, vice versa)

**delete the pod when finished?**

## modeling choosing

Implement the job.

Same tests → different models, choose the one with the best metrics.

## controller

TODO

## scenarios

weak load jobs → heavy load jobs, vice versa

# Implementation

1 job → 1 pod

## jobs: Pratiksha

one job(stress test) each line.

generate a reasonable list of jobs → distribution number of CPU workers (automatic)

func([(cpu=1, num=100, vm=xxx), (2, 150)]): return a list of stress tests(in a txt file), [:100] has a CPU worker number average at 1; [100:250] has a CPU worker number average at 2.

job queue(periodically (15s) call the controller)

## test the model: Sungjae

use the job queue to test different models.

others provide the model.

y(n+1) = a * y(n) + b * u(n)

## middleware: Chirayu

API for CPU usage: read from cluster, expose for the controller

scale up and scale down: create new pods or delete the pod that finishes. Create a new pod to run the new job; delete a pod that finished the job

dynamically create a pod that runs a certain job.

handle the max_pod

dynamically deploy new pods

Dum: write yaml file(defines a pod), use “apply -f”

remove pods that finish the job(?)

API:

get_CPU

## Controller: Yuqi

assign jobs(stress test)

read CPU usage

change max_pod → middleware

expose the API for the job queue

## Cluster

**metric server**

## mock metric server: Yuqi

use the python code to get the CPU usage.