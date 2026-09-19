# 🛡️ AI-Powered IaC Reviewer

An AI-powered tool that automatically reviews Terraform (Infrastructure as Code) files for **security risks**, **cost inefficiencies**, and **best-practice violations** — before that code ever gets deployed to the cloud.

Think of it as a spell-checker, but for cloud security and cost — powered by an LLM (Google Gemini).

---

## 📸 Demo

![Dashboard Screenshot](dashboard-screenshot.png)

---

## 🎯 The Problem

Infrastructure as Code (IaC) tools like Terraform let engineers describe cloud resources — servers, storage, databases — as code instead of clicking through a cloud console. A single mistake in this code can:

- Leave data **publicly exposed** on the internet
- Leave **hardcoded passwords or API keys** in the codebase
- Waste **thousands of dollars a month** on oversized or unused cloud resources

This tool automates the first pass of catching these issues, using AI to review code and explain problems in plain language.

---

## ⚙️ How It Works

1. **Sample Terraform files** — includes intentionally broken files (security, secrets, cost issues) and one correctly-written file as a control test
2. **AI review** — each file is sent to Google's Gemini API with a structured prompt asking it to flag issues by severity
3. **Parsing** — the AI's response is parsed into a clean Severity / Issue / Fix format
4. **Dashboard** — a Flask web app displays the results as a color-coded report

Terraform file → Python reads it → Sent to Gemini AI → Issues parsed → Displayed on dashboard


---

## 🧰 Tech Stack

- **Language:** Python
- **AI/LLM:** Google Gemini API (`gemini-3.5-flash-lite`)
- **Web framework:** Flask
- **Frontend:** HTML/CSS (Jinja2 templating)
- **Target:** Terraform (.tf) files

---

## ✅ Validation

To prove the tool isn't just flagging everything by default, it was tested against:
- 3 intentionally broken files → correctly flagged with specific, actionable issues
- 1 correctly-written file → correctly returned "No issues found"

---

## 🚀 Running Locally

```bash
# Install dependencies
pip install flask google-genai

# Set your Gemini API key as an environment variable
setx GEMINI_API_KEY "your-api-key-here"

# Run the app
python app.py
```

Then open `http://127.0.0.1:5001` in your browser.

---

## 🔮 Future Improvements

- GitHub Actions integration to auto-run reviews on every pull request
- Real-time cost estimation using cloud pricing APIs
- Support for additional IaC formats (CloudFormation, Pulumi)

---

## 👩‍💻 Author

Built by Keerthana as a portfolio project to demonstrate applied AI + DevOps skills.

