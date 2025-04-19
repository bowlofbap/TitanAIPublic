#!/usr/bin/env python3
import json
import xml.etree.ElementTree as ET
import sys

def extract_tests(plan_node, result_node, path=None):
    path = path or []
    tests = []

    phrase = plan_node.get("phrase", "Unnamed")
    current_path = path + [phrase]

    plan_children = plan_node.get("children", [])
    result_children = result_node.get("children", [])

    # If this is a test
    if plan_node.get("type") == "It":
        success = result_node.get("status") == "Success"
        errors = result_node.get("errors", [])
        message = errors[0].get("message", "") if errors else ""
        trace = errors[0].get("trace", "") if errors else ""

        tests.append({
            "classname": ".".join(current_path[:-1]) or "Unnamed",
            "name": phrase,
            "success": success,
            "message": message,
            "trace": trace
        })

    # Recurse into children
    for plan_child, result_child in zip(plan_children, result_children):
        tests.extend(extract_tests(plan_child, result_child, current_path))

    return tests

def to_junit(input_json_path, output_xml_path):
    with open(input_json_path) as f:
        data = json.load(f)

    plan_children = data["planNode"]["children"]
    result_children = data["children"]

    tests = []
    for plan_node, result_node in zip(plan_children, result_children):
        tests.extend(extract_tests(plan_node, result_node))

    testsuites = ET.Element("testsuites")
    testsuite = ET.SubElement(
        testsuites, "testsuite",
        name="TestEZ",
        tests=str(len(tests)),
        failures=str(sum(1 for t in tests if not t["success"]))
    )

    for t in tests:
        tc = ET.SubElement(
            testsuite, "testcase",
            classname=t["classname"],
            name=t["name"]
        )
        if not t["success"]:
            failure = ET.SubElement(tc, "failure", message=t["message"])
            failure.text = t["trace"]

    tree = ET.ElementTree(testsuites)
    tree.write(output_xml_path, encoding="utf-8", xml_declaration=True)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: convert_to_junit.py input.json output.xml", file=sys.stderr)
        sys.exit(1)
    to_junit(sys.argv[1], sys.argv[2])
