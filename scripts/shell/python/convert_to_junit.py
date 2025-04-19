#!/usr/bin/env python3
import json
import xml.etree.ElementTree as ET
import sys

def to_junit(input_json, output_xml):
    with open(input_json) as f:
        tests = json.load(f)

    # root <testsuites> (you could wrap multiple suites here)
    testsuites = ET.Element("testsuites")
    # single suite named “TestEZ”
    failures = sum(1 for t in tests if not t.get("success", False))
    suite = ET.SubElement(
        testsuites, "testsuite",
        name="TestEZ",
        tests=str(len(tests)),
        failures=str(failures),
    )

    for t in tests:
        classname = ".".join(t.get("path", []))
        name      = t.get("method", "")
        tc = ET.SubElement(
            suite, "testcase",
            classname=classname,
            name=name
        )
        if not t.get("success", False):
            failure = ET.SubElement(
                tc, "failure",
                message=t.get("message", "")
            )
            failure.text = t.get("trace", "")

    tree = ET.ElementTree(testsuites)
    tree.write(output_xml, encoding="utf-8", xml_declaration=True)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: convert_to_junit.py input.json output.xml", file=sys.stderr)
        sys.exit(1)
    to_junit(sys.argv[1], sys.argv[2])
