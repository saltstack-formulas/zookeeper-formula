#!/bin/bash
set -ev

rm -rf vendor
git clone https://github.com/saltstack-formulas/sun-java-formula vendor
bundle exec kitchen verify
