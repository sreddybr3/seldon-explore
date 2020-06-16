#!/bin/bash

vegeta attack -rate=40 -duration=5s -timeout=100s -targets=targets.txt -insecure | vegeta report