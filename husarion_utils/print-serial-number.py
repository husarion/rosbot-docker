#!/usr/bin/env python3

import subprocess
import json
import hashlib
import string
import re


def get_cpu_id_from_ros_service():
    try:
        # Run the ROS service call command
        result = subprocess.run(
            ["ros2", "service", "call", "/get_cpu_id", "std_srvs/srv/Trigger"],
            capture_output=True,
            text=True,
            timeout=30,
        )

        # Regular expression to extract JSON from the response
        match = re.search(r"message='(\{.*\})'", result.stdout)
        if match:
            json_str = match.group(1)
            json_data = json.loads(json_str)
            cpu_id = json_data["cpu_id"]
            return cpu_id
        else:
            print("JSON response not found in the output.")
            return None
    except subprocess.SubprocessError as e:
        print(f"Error during ROS service call: {e}")
        return None
    except json.JSONDecodeError as e:
        print(f"JSON parsing error: {e}")
        return None


def hex_to_num(hex_str):
    # Check if the hex string is valid
    if not all(c in string.hexdigits for c in hex_str):
        raise ValueError("Invalid hex string")

    # Convert the hex string to bytes
    hex_bytes = bytes.fromhex(hex_str)

    # Compute the SHA-256 hash of the hex bytes
    hash = hashlib.sha256(hex_bytes).hexdigest()

    # Truncate the hash to 6 characters
    hash = hash[:6]

    # Return the hash as an ASCII string
    return hash


try:
    # Obtain CPU ID from ROS service
    cpu_id = get_cpu_id_from_ros_service()

    if cpu_id:
        # Calculate the serial number
        serial_number = hex_to_num(cpu_id)
        print(f"CPU ID: 0x{cpu_id}")
        print(f"Serial Number: {serial_number}")
    else:
        print("Failed to obtain CPU ID.")
except Exception as e:
    print(f"An error occurred: {e}")
