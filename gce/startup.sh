#!/bin/bash
# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# install jq
apt-get update
apt-get -y install jq

# access secret from secretsmanager
secrets=$(gcloud secrets versions access latest --secret="runner-secret")
# set secrets as env vars
# shellcheck disable=SC2206
secretsConfig=($secrets)
for var in "${secretsConfig[@]}"; do
export "${var?}"
done
# github runner version
GH_RUNNER_VERSION="2.319.1"
GH_RUNNER_HASH=3f6efb7488a183e291fc2c62876e14c9ee732864173734facc85a1bfb1744464
# get actions binary
curl -o actions.tar.gz --location "https://github.com/actions/runner/releases/download/v${GH_RUNNER_VERSION}/actions-runner-linux-x64-${GH_RUNNER_VERSION}.tar.gz"
echo "3f6efb7488a183e291fc2c62876e14c9ee732864173734facc85a1bfb1744464  actions.tar.gz" | shasum -a 256 -c
mkdir /runner
mkdir /runner-tmp
tar -zxf actions.tar.gz --directory /runner
cd /runner
./config --url https://github.com/delphiio --token ${GITHUB_TOKEN}
./run.sh
