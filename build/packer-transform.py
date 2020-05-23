#!/usr/bin/env python3
""" Converts a YAML packer file to JSON """

from sys import stdout, stdin
import argparse
import json
import yaml


parser = argparse.ArgumentParser(
    description='Processes / converts a yaml-format Packer template')
parser.add_argument('--add-breakpoint', dest='breakpoint',
                    action='store_const', const=True, default=False,
                    help='add a breakpoint at the end')


if __name__ == '__main__':
    args = parser.parse_args()

    yaml_object = yaml.safe_load(stdin)
    if args.breakpoint:
        yaml_object["provisioners"].append({"type": "breakpoint"})
    json.dump(yaml_object, stdout, indent=2)


