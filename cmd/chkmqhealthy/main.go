/*
© Copyright IBM Corporation 2017

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

// chkmqhealthy checks that MQ is healthy, by checking the output of the "dspmq" command
package main

import (
	"os"
	"os/exec"
	"strings"

	"github.com/ibm-messaging/mq-container/internal/name"
)

func queueManagerHealthy() (bool, error) {
	name, err := name.GetQueueManagerName()
	if err != nil {
		return false, err
	}
	// Specify the queue manager name, just in case someone's created a second queue manager
	cmd := exec.Command("dspmq", "-n", "-m", name)
	// Run the command and wait for completion
	out, err := cmd.CombinedOutput()
	if err != nil {
		return false, err
	}
	if !strings.Contains(string(out), "(RUNNING)") {
		return false, nil
	}
	return true, nil
}

func main() {
	healthy, err := queueManagerHealthy()
	if err != nil {
		os.Exit(2)
	}
	if !healthy {
		os.Exit(1)
	}
	os.Exit(0)
}
