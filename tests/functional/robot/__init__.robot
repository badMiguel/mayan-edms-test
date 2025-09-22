*** Settings ***
Documentation   Project-wide suite setup

Library         Process

Resource        resources/keywords/common.resource
Resource        resources/variables.resource
Suite Setup     Init Setup

*** Keywords ***
Init Setup
    Get Headers
    Run Process     python3     scripts/seed.py
