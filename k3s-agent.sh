#!/usr/bin/env bash
TOKEN="YOUR TOKEN HERE"
SERVER="127.0.0.1"

sudo nohup k3s agent --server https://${SERVER}:6443 --token ${TOKEN} > /tmp/k3s-agent.log &
