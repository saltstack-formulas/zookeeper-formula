#!/bin/bash
set -ev

rm -rf vendor/sun-java-formula
git clone https://github.com/saltstack-formulas/sun-java-formula vendor/sun-java-formula
bundle exec kitchen verify
