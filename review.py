import os
import re
from pathlib import Path
from google import genai

# Step 1: Connect to Gemini using the API key we stored earlier
client = genai.Client()

# Step 2: Point to the folder where our sample Terraform files live
folder = Path("sample-terraform")

# Step 3: The instructions we give Gemini for every file
instructions = """You are a cloud security and cost expert reviewing a Terraform file.
Look for:
1. Security issues (public access, open ports, hardcoded secrets, missing encryption)
2. Cost inefficiencies (oversized resources, unused resources, unnecessary redundancy)
3. Best-practice violations (missing tags, missing versioning, etc.)

For each issue found, respond in this exact format, one per line:
[SEVERITY: High/Medium/Low] Issue: <short description> | Fix: <short suggested fix>

If the file has no issues, just respond with: No issues found."""


def parse_line(line):
    """Takes one raw line of Gemini's answer and pulls out
    the severity, issue, and fix as separate pieces."""
    match = re.match(r"\[SEVERITY:\s*(\w+)\]\s*Issue:\s*(.+?)\s*\|\s*Fix:\s*(.+)", line)
    if match:
        severity, issue, fix = match.groups()
        return severity.strip(), issue.strip(), fix.strip()
    return None


def print_table(rows):
    """Prints a list of (severity, issue, fix) rows as a neat table."""
    if not rows:
        print("✅ No issues found.\n")
        return

    # Figure out how wide each column needs to be
    sev_width = max(len("SEVERITY"), max(len(r[0]) for r in rows))
    issue_width = max(len("ISSUE"), max(len(r[1]) for r in rows))
    fix_width = max(len("FIX"), max(len(r[2]) for r in rows))

    # Print header
    header = f"{'SEVERITY'.ljust(sev_width)} | {'ISSUE'.ljust(issue_width)} | {'FIX'.ljust(fix_width)}"
    print(header)
    print("-" * len(header))

    # Print each row
    for severity, issue, fix in rows:
        print(f"{severity.ljust(sev_width)} | {issue.ljust(issue_width)} | {fix.ljust(fix_width)}")
    print()


# Step 4: Go through every .tf file in the folder, one at a time
for file_path in folder.glob("*.tf"):
    print("=" * 70)
    print(f"Reviewing: {file_path.name}")
    print("=" * 70)

    code = file_path.read_text(encoding="utf-8")

    response = client.models.generate_content(
        model="gemini-3.5-flash-lite",
        contents=f"{instructions}\n\nTerraform file:\n{code}"
    )

    # Break Gemini's answer into lines, and parse each one
    raw_lines = response.text.strip().splitlines()
    parsed_rows = [parse_line(line) for line in raw_lines]
    parsed_rows = [row for row in parsed_rows if row]  # drop lines that didn't match

    print_table(parsed_rows)