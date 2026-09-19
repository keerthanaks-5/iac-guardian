import re
from pathlib import Path
from flask import Flask, render_template, request
from google import genai

app = Flask(__name__)
client = genai.Client()

folder = Path("sample-terraform")

instructions = """You are a cloud security and cost expert reviewing a Terraform file.
Look for:
1. Security issues (public access, open ports, hardcoded secrets, missing encryption)
2. Cost inefficiencies (oversized resources, unused resources, unnecessary redundancy)
3. Best-practice violations (missing tags, missing versioning, etc.)

For each issue found, respond in this exact format, one per line:
[SEVERITY: High/Medium/Low] Issue: <short description> | Fix: <short suggested fix>

If the file has no issues, just respond with: No issues found."""


def parse_line(line):
    match = re.match(r"\[SEVERITY:\s*(\w+)\]\s*Issue:\s*(.+?)\s*\|\s*Fix:\s*(.+)", line)
    if match:
        severity, issue, fix = match.groups()
        return severity.strip(), issue.strip(), fix.strip()
    return None


def review_all_files():
    """Runs the Gemini review on every .tf file and returns a dictionary
    like { "filename.tf": [(severity, issue, fix), ...] }"""
    results = {}
    for file_path in folder.glob("*.tf"):
        code = file_path.read_text(encoding="utf-8")

        response = client.models.generate_content(
            model="gemini-3.5-flash-lite",
            contents=f"{instructions}\n\nTerraform file:\n{code}"
        )

        raw_lines = response.text.strip().splitlines()
        parsed_rows = [parse_line(line) for line in raw_lines]
        parsed_rows = [row for row in parsed_rows if row]

        results[file_path.name] = parsed_rows

    return results


@app.route("/", methods=["GET", "POST"])
def home():
    results = None
    if request.method == "POST":
        results = review_all_files()
    return render_template("index.html", results=results)


if __name__ == "__main__":
    app.run(debug=True, port=5001)