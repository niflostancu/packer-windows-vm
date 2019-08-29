#!/usr/bin/env ruby

require 'yaml'
require 'json'

# Converts the YAML template to packer-compatible JSON,
# + a few object processing routines (for image reuse). 

configuration = YAML.load($stdin)
$stdout.puts(configuration.to_json)

