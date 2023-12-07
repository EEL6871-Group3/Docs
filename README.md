# Readme file for whole project.

1. [Job Queue](#job-queue)
2. [Middleware](#middleware)
3. [Local Controller](#local-controller)
4. [Global Controller](#global-controller)
5. [Logging (Bonus Task)](#logging-(bonus-task))

# 1. Job Queue

## Overview
This Python script generates stress-ng jobs with random parameters based on specified ranges. The generated jobs are appended to a file, creating a job queue for stress testing.

## Source Code Explanation
The source code contains a Python script that takes command-line arguments to define the ranges for stress-ng job parameters. The generated jobs include options for I/O operations (--io), virtual memory stress (--vm and --vm-bytes), and a timeout duration (--timeout). The generated commands are then written to a file, creating a job queue.

## Usage
Execute the script with the following command-line arguments:

bash
python job_generation.py <io_min> <io_max> <vm_min> <vm_max> <vm_bytes_min> <vm_bytes_max> <timeout_min> <timeout_max> <num_of_jobs>
Example:

```bash
python job_generation.py 0 5 0 5 0 4 10 30 30
```
The generated stress-ng commands will be appended to the job_list.txt file by default.

# 2. Middleware
Middleware for Kubernetes Node Scaling and Stress Testing
## Overview
This middleware is designed to facilitate dynamic scaling of nodes in a Kubernetes cluster and stress testing individual nodes, when instructed by the controller. The primary functionalities include:

1. Cluster Scaling:
    - Start Node: Add a new node to the cluster.
    - Delete Node: Remove an existing node from the cluster.
    - Node Count: Get the number of currently running nodes.

2. Node Scaling:
    - Spin Up Pods: Launch stress-ng pods on specific nodes with customizable stress parameters.
    - Retrieve CPU Usage: Obtain CPU usage percentage for each node.
    - Pod count: Return running pod count for a particular node.
    - Delete pods: Deletes completed or failed pods.

# Middleware Implementation and brief function description

Middleware is implemented as a REST API to bridge the gap between the controller and the cluster. Some of the functions that middleware implements are scaling up and scaling down via the spin_up_pod and delete_pod method.
In order to run the middleware just type the following command 
Python3 middleware_api.py
After this you can call the various endpoints using python requests -

## The brief description of all the task performed by the Middleware is provided below

1. parse_input(input_str):
    - Parses the input string containing stress-ng arguments
    - Extracts argument name-value pairs using regex
    - Returns a dict with the extracted arguments

2. get_node_capacity(node_name):
    - Gets the CPU capacity in nanocores for the given node
    - Runs kubectl command to get node info in JSON format
    - Parses CPU capacity from the node info
    - Returns CPU capacity in nanocores

3. spin_up_pod(args, pod_name, node_name):
    - Creates a Kubernetes Pod manifest
    - Configures the manifest with stress-ng container and arguments
    - Assigns a unique name and specifies node to schedule pod on
    - Calls Kubernetes API to create the Pod on the cluster
    - Returns a message with the pod creation status

4. delete_pods():
    - Lists all pods in "default" namespace
    - Deletes any completed pods (Succeeded or Failed phase)
    - Returns a list with names of deleted pods


5. @app.route("/cpu") / get_cpu():
    - Utilizes Metric server API endpoint to get CPU usage on nodes
    - Calls Kubernetes metrics API to get node usage stats
    - Loops through each node
    - Gets CPU usage in nanoseconds
    - Calculates CPU capacity of node in nanocores
    - Computes CPU usage percentage
    - Adds node and usage to dictionary
    - Returns JSON with dict mapping node name to CPU usage percentage

6. @app.route("/pod-num") / get_pod_num():
    - API endpoint that when called will:
    - Delete any completed pods
    - List remaining pods
    - Return total pod count and deleted pods

7. @app.route('/pod') / handle_post():
    - Endpoint to create a new stress pod
    - Parses input parameters
    - Calls spin_up_pod() to create pod
    - Returns JSON message with result

8. @app.route("/nodes") / get_nodes():

    - Returns a list of the names of nodes currently running in the cluster (excluding the master node)
    - Calls the Kubernetes API to get all nodes
    - Loops through nodes and appends the name to a list if not the master node
    - Returns success=True and list of node names
    - Handles any errors and returns success=False with error message

9. evict_pods(node_name, api_instance):
    - Helper function to evict all pods on a given node
    - Gets all pods and filters to only those scheduled on the node
    - Calls Kubernetes API to delete/evict each pod
    - Logs and handles errors for each eviction

10. @app.route('/delete-node') / delete_node():

    - Endpoint to delete a Kubernetes node for cluster scale down
    - Gets node name from request payload
    - Calls evict_pods() to evict all pods first
    - Calls Kubernetes API to delete the node
    - Returns success or error message

11. @app.route('/start-node') / start_node():

    - Endpoint to add/start a new Kubernetes node to scale up cluster
    - Gets node name from request payload
    - Creates Node API object with node name
    - Calls Kubernetes API to create the Node resource
    - Returns success or error message

# API endpoints and call to functions - 
1. Get CPU Usage
    - Endpoint: /cpu
    - Method: GET
    - Description: Retrieve CPU usage percentage for each node in the cluster.
    - Example API Call (Python Requests):
```py
import requests

response = requests.get('http://localhost:5001/cpu')
cpu_data = response.json()
print(cpu_data)
```

2. Spin Up Pods
    - Endpoint: /pod
    - Method: POST
    - Description: Launch stress-ng pods on a specific node with given stress parameters.
    - Example API Call (Python Requests):
```py
import requests

payload = {
    "job": "stress-ng --io 2 --vm 8 --vm-bytes 4G --timeout 2m",
    "name": "example-pod",
    "node": "node1.group-3-project.ufl-eel6871-fa23-pg0.utah.cloudlab.us"
}

response = requests.post('http://localhost:5001/pod', json=payload)
result = response.json()
print(result)
```

3. Delete Pods
    - Endpoint: /delete-pods
    - Method: GET
    - Description: Initiate deletion of completed/failed pods.
    - Example API Call (Python Requests):
```py
import requests

response = requests.get('http://localhost:5001/delete-pods')
deleted_pods = response.json()
print(deleted_pods)
```

4. Get Pod Count on a Node
    - Endpoint: /pod-num
    - Method: POST
    - Description: Get the number of pods running on a specific node.
    - Example API Call (Python Requests):
```py
import requests

payload = {"node": "node1.group-3-project.ufl-eel6871-fa23-pg0.utah.cloudlab.us"}

response = requests.post('http://localhost:5001/pod-num', json=payload)
pod_info = response.json()
print(pod_info)
```

5. Get Nodes
    - Endpoint: /nodes
    - Method: GET
    - Description: Retrieve the list of nodes currently running in the cluster.
    - Example API Call (Python Requests):
```py
import requests

response = requests.get('http://localhost:5001/nodes')
nodes_info = response.json()
print(nodes_info)
```

6. Delete Node
    - Endpoint: /delete-node
    - Method: POST
    - Description: Remove a node from the cluster for scaling down.
    - Example API Call (Python Requests):

```py
import requests

payload = {"node": "node1.group-3-project.ufl-eel6871-fa23-pg0.utah.cloudlab.us"}

response = requests.post('http://localhost:5001/delete-node', json=payload)
result = response.json()
print(result)
```
7. Start Node
    - Endpoint: /start-node
    - Method: POST
    - Description: Add a new node to the cluster for scaling up.
    - Example API Call (Python Requests):
```py
import requests

payload = {"node": "node1.group-3-project.ufl-eel6871-fa23-pg0.utah.cloudlab.us"}

response = requests.post('http://localhost:5001/start-node', json=payload)
result = response.json()
print(result)
```

# RUN
```bash
python3 middleware_api.py
```
This will make api go live on http://128.110.217.71:5001 and http://127.0.0.1:5001

# 3. Local Controller

## Components
The controller has these components:

* Closed loop
  - Periodically update the max_pod by the closed loop function, based on the current CPU(get the CPU from the middleware API) and the reference input
  - The controller won't render a job if it's within `job_delay` seconds after some pod has been started or deleted, unless we have added a pod but the CPU usage is already too high, vice versa.
* Job renderer
  - only used when the local controller is run independantly
  - Read the job list
  - Periodically (every 15 seconds) render a new job
  - Get the current pod number from the middleware. The middleware API for getting the current pod number will delete every pod that has already finished its job
  - If the current pod number is greater or equal to the max_pod, don’t render the job. It will try to render it in the next iteration. Else, create a new pod to run the job to be rendered(by calling the middleware API)
* Data collector
    - Periodically (at the same rate as the closed loop) save the current CPU and max_pod to a file
* Reference input API
    - A running Flask app that provides an API that allows us to change the reference input
* Job API
    - An API to start a job
    - can be called by the global controller to start a new pod
    - if the current pod number is equal to max_pod, no job will be rendered and a "fail" message will be sent to the global controller
The first three components are run as three independent threads.	
The controller will save the CPU and max_pod data in two files for further plotting or analysis.

## Set up

The settings is listed at the top of the "local_controller.py" file.

```Python
sample_rate = 5  # The closed loop system will sleep for this much of X seconds
reference_input = 0.8  # CPU usage, from 0 to 100
job_sleep_time = 15  # read a job every X seconds
job_file_name = "job_list.txt"
cpu_res_file_name = "cpu.txt"
max_pod_res_file_name = "maxpod.txt"
job_list = []
node_name = "k8s-master"
cur_pod_id = 0
max_pod_upperbound = 12
job_delay = 15  # number of seconds that we believe a the CPU is changed after a job is started, i.e., we need to wait at least that time before we start the closed loop function
read_jobs = False  # if read a job from a file and render the jobs

# API
cpu_api = "http://128.110.217.71:5001/cpu"
pod_num_api = "http://128.110.217.71:5001/pod-num"  # GET
create_pod_api = "http://128.110.217.71:5001/pod"  # POST
```

## API exposed

`localhost:5004/job` POST, to add a new job to the local controller

# run
python3 local_controller.py

# 4. Global Controller

## Components
* CPU sampler
    - sample the current CPU of each running nodes
    - compute the average CPU usage as the cluster CPU, store it
* controller
    - if the recent `number_cpu_data_used` cluster CPU are all greater than the cpu_bar, scale up
    - check the lastest created node, if it's not running any job and it has been at least `node_start_delay` seconds, delete it(scaling down)
* job renderer
    - read from the job list
    - try to assign the job to the running nodes in the order of the created time of the nodes. That is, assign the job to the earliest node possible, which will make the last node empty if possible to support scaling down
    - if no node is available, waite for the next iteration to render the job

## Settings
Settings are at the start of the `global_controller.py` file

```Python
# APIs
get_nodes_api = "http://localhost:5001/nodes"
start_node_api = "http://localhost:5001/start-node"
delete_node_api = "http://localhost:5001/delete-node"
cpu_api = "http://localhost:5001/cpu"

# settings
sample_time = 5  # every X seconds, save the CPU usage of each node
loop_sleep_time = (
    3  # every X seconds, based on the CPU usage, make a scaling up/down decision
)
master_node = "k8s-master"
worker_nodes = [
    "k8s-worker1",
    "k8s-worker2",
]  # list of the two workers, in the order of jobs assignemnt priority, e.g., job will be assigned to master node, if unable, to the worker1, then worker2
node_job_api = {
    "k8s-master": "http://localhost:5001/job",
    "k8s-worker1": "http://localhost:5001/job",
    "k8s-worker2": "http://localhost:5001/job",
}
node_pod_api = {
    "k8s-master": "http://localhost:5001/pod-num",
    "k8s-worker1": "http://localhost:5001/pod-num",
    "k8s-worker2": "http://localhost:5001/pod-num",
}
cpu_bar = 0.8
number_cpu_data_used = (
    6  # use the previous X number of cpu to see if we need to scale up
)
node_start_delay = (
    30  # no scaling down decision in X seconds after a scaling up decision
)
job_assign_time = 15  # every X seconds, schedule a job
job_file_name = "job_list.txt"
```

## run
`Python3 global_controller.py`.
Notice that the `job_list.txt` file must exists in the working directory where the controller is run.

# 5. Logging (Bonus Task)

# Fluent Bit Integration Guide

This guide outlines the steps to integrate Fluent Bit for log management in Kubernetes environment, focusing on middleware, local-controller and container logs.

## Introduction to Logging

- **Categories**: INFO, DEBUG, ERROR, and CRITICAL.
- **Implementation**: Logging statements added in both the controller and middleware.
- **Logging Level**: Set to DEBUG for comprehensive log collection.
- **Log Files**: Individual `out.log` files for middleware and controller.

## 2. Setting Up Fluent Bit

- **Install Helm**
curl -fsSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

- **Add the Fluent Helm Charts repo**
helm repo add fluent https://fluent.github.io/helm-charts

- **Install default Fluent Bit chart**
helm upgrade --install fluent-bit fluent/fluent-bit

- **Modify the default Fluent Bit ConfigMap to collect specific logs:**
[INPUT]
   Name tail
   Path /home/k8s-user/middleware/out.log
   Parser docker
   Tag middleware
   Refresh_Interval 10

[INPUT]
   Name tail
   Path /home/k8s-user/local-controller/out.log
   Parser docker_no_time
   Tag local-controller
   Refresh_Interval 10

[FILTER]
   Name grep
   Match local-controller
   Regex log ^(.*scaling up.*|.*scaling down.*)$

[OUTPUT]
    Name stdout
    Match *
    Format json
    Json_date_key timestamp
    Json_date_format iso8601

- **Update the daemonset.yaml to include necessary volume mounts:**
- mountPath: /home/k8s-user/middleware 
  name: middleware-logs
  readOnly: true

- mountPath: /home/k8s-user/local-controller
  name: localcontroller-logs
  readOnly: true

- hostPath:
    path: /home/k8s-user/middleware
    type: “”
    name: middleware-logs

- hostPath:
    path: /home/k8s-user/local-controller
    type: “”
    name: localcontroller-logs

- **Apply the updated DaemonSet configuration with Kubernetes:**
kubectl apply -f fluent-bit-ds.yaml

- **Check Fluent Bit pods and their logs:**
kubectl get pods -n default
kubectl logs <fluent-bit-pod-name> -n default