# AI Job Search Automation — Complete Change Log / Handoff

## 1. Purpose

This file is the handoff document for continuing the **AI Job Search Automation** project in a new ChatGPT instance.

Read this entire file before continuing. Preserve working components and decisions unless a test proves a change is necessary.

The system should find **genuinely relevant, fresh, India-eligible jobs** for the user, while filtering stale, duplicate/reposted, suspicious, irrelevant, and experience-heavy jobs.

The user must review and press the final Apply action manually. Do not automate mass final submissions.

---

## 2. User's Target

Primary roles:
- Data Analyst
- Data Analyst Intern
- Junior Data Analyst
- Data Analytics Intern
- Data Science Intern

Secondary roles:
- BI Analyst
- Reporting Analyst
- MIS Analyst
- Analytics Associate

Preferred locations:
- Delhi
- Noida
- Gurgaon
- Remote

Experience target:
- Fresher
- Entry Level
- Internship
- 0–1 years
- 0–2 years
- Maximum target experience: 2 years

Preferred work modes:
- On-site
- Hybrid
- Remote

Freshness requirement:
- Strong preference for jobs posted today or 1–2 days ago.
- Jobs up to 7 days old can be considered Recent.
- Jobs older than 7 days must be rejected as OLD.
- Never include stale jobs just to reach a target count.

The user wants as many genuine fresh jobs as the sources actually provide. Earlier they mentioned wanting roughly 100–110 raw jobs scanned and potentially around 50 good jobs/day, but this is a target rather than a guarantee. Quality must not be sacrificed to hit a number.

Preferred final output:
- Freshness
- Match score
- Salary/stipend
- Skills
- Job link
- Simple Hinglish explanation

Code style:
- Clean
- Minimal comments
- Minimal unnecessary spacing
- Should not look obviously AI-generated
- When fixing a file, user prefers the complete corrected file rather than a small patch.

---

## 3. Project Path

Windows project path:

C:\Users\HP\Desktop\AI-Job-Search-Automation

Current important structure:

src/
  collectors/
    adzuna.py
    the_muse.py
    multi_source.py
  processing/
    transform.py
    transform_muse.py
    job_parser.py
    freshness.py
    work_mode.py
    location_eligibility.py
    scam_detector.py
    deduplication.py
    batch_processor.py
    quality.py
  matching/
    score.py
    match_result.py
    decision.py

config/
  profile.yaml
  search_config.yaml

---

## 4. Sources

### Adzuna
- Primary source.
- API App ID / App Key configured and working.
- Real API calls work.
- Major problem: many search results can be stale.
- Example:
  - 20 unique raw jobs
  - only 1 fresh <=7 days
  - 19 old
- Therefore freshness filtering must stay strict.

### The Muse
- Secondary/backup source.
- API key configured and working.
- India coverage is low.
- Entry Level test:
  - New Delhi => 1
  - Gurgaon => 1
  - Noida => 1
  - Hyderabad => 2
- Internship test:
  - New Delhi => 1
  - Gurgaon => 1
  - Noida => 1
  - Hyderabad => 1
- Keep it as a backup source.

### Source #3 decision
- Jobvetta was investigated but dropped because the user could not obtain an API key despite trying.
- Himalayas was rejected because it is remote-job focused, while the user explicitly wants balanced On-site/Hybrid/Remote coverage.
- Current decision: **do not add Source #3**.
- Continue with Adzuna + The Muse.
- Do not waste time hunting additional sources unless a future test proves the current architecture genuinely needs one and a balanced official source is found.
- Do not use unofficial scraping of LinkedIn/Naukri/Indeed as a shortcut.

---

## 5. Search Config

Current `config/search_config.yaml`:

```yaml
search:
  locations:
    - "Delhi"
    - "Noida"
    - "Gurgaon"
    - "Remote"

  primary_roles:
    - "Data Analyst"
    - "Data Analyst Intern"
    - "Junior Data Analyst"
    - "Data Analytics Intern"
    - "Data Science Intern"

  secondary_roles:
    - "BI Analyst"
    - "Reporting Analyst"
    - "MIS Analyst"
    - "Analytics Associate"

  experience:
    - "Fresher"
    - "Entry Level"
    - "Internship"
    - "0-1 years"
    - "0-2 years"

filters:
  minimum_match_score: 70
  preferred_match_score: 80
  max_experience_years: 2

work_modes:
  - "On-site"
  - "Hybrid"
  - "Remote"

search_settings:
  max_jobs_per_query: 50
  remove_duplicates: true
  scam_check: true
  ai_matching: true
```

Validation passed:

```text
SEARCH CONFIG OK
Locations: 4
Primary roles: 5
Secondary roles: 4
Max age: 7
Pages: 3
Max jobs/query: 50
```

---

## 6. Freshness

Freshness V2 passed:

```text
12 hours => {'fresh': True, 'age_hours': 12.0, 'age_days': 0.5, 'status': 'TODAY / VERY FRESH'}
36 hours => {'fresh': True, 'age_hours': 36.0, 'age_days': 1.5, 'status': 'FRESH'}
60 hours => {'fresh': True, 'age_hours': 60.0, 'age_days': 2.5, 'status': 'RECENT'}
8 days   => {'fresh': False, 'age_hours': 192.0, 'age_days': 8.0, 'status': 'OLD'}
```

A 2021 real job correctly returned OLD.

Rule:
- <=7 days => can continue
- >7 days => OLD/rejected

Do not weaken this merely to increase volume.

---

## 7. Deduplication / Repost Detection

Repost test passed:

```text
Identical:
is_repost=True
reason='IDENTICAL JOB CONTENT'

Same company-role-location:
is_repost=True
reason='SAME COMPANY + ROLE + LOCATION'
```

Deduplication test:
- Unique: 3
- Duplicates: 1
- Possible reposts: 1
- Duplicate reason: SAME SOURCE + JOB ID
- Repost reason: SAME COMPANY + ROLE + LOCATION

Preserve this behavior.

---

## 8. Job Parser

Parser V2 passed.

Realistic parser result:

```python
{
    'skills': ['SQL', 'Microsoft Excel', 'Power BI', 'Python', 'Pandas'],
    'experience': '0-1 years',
    'eligibility': 'Education requirement mentioned'
}
```

Real Adzuna parser examples:
- One fresh Data Analyst:
  - skills: ['SQL', 'Python']
  - experience: '5-7 years'
  - eligibility: 'Education requirement mentioned'
- Another:
  - skills: ['SQL', 'Microsoft Excel', 'Power BI', 'Data Visualization']
  - experience: 'Unknown'
  - eligibility: 'Verify required'

The parser itself works. A separate bug existed in `transform.py` where parsed values were discarded.

---

## 9. Work Mode

File:
`src/processing/work_mode.py`

Test passed:

```text
Remote    => Remote
Hybrid    => Hybrid
On-site   => On-site
No signal => Unknown
```

Priority:
- Hybrid
- Remote
- On-site
- Unknown

Never guess Unknown as a work mode.

Adzuna integration example:
- Data Analyst
- Delhi, India
- Work mode: Unknown
This is correct because the JD had no reliable work-mode evidence.

---

## 10. Location Eligibility

File:
`src/processing/location_eligibility.py`

5/5 test passed:

```text
Delhi, India
=> eligible=True
=> INDIA ELIGIBLE

Noida, India
=> eligible=True
=> INDIA ELIGIBLE

Remote - US
=> eligible=False
=> NOT INDIA ELIGIBLE
=> US LOCATION RESTRICTION

Flexible / Remote
=> eligible=False
=> UNKNOWN REMOTE ELIGIBILITY
=> INDIA ELIGIBILITY NOT CONFIRMED

Unknown
=> eligible=False
=> UNKNOWN LOCATION
=> INDIA LOCATION NOT CONFIRMED
```

Important:
- Remote does NOT automatically mean India eligible.
- US-only remote jobs must be rejected.
- Generic remote with no India eligibility evidence is not accepted.

---

## 11. The Muse Transformer

File:
`src/processing/transform_muse.py`

Common schema:

```text
job_id
source
company
role
location
work_mode
salary
skills
description
job_url
posted_date
experience
eligibility
```

Transformer test passed using an Anthology job:

```text
job_id: muse_14903177
source: The Muse
company: Anthology
role: Overnight Customer Care and Technical Support Advisor
location: Flexible / Remote
work_mode: Remote
salary: Not disclosed
skills: ['Microsoft Excel']
job_url: valid The Muse landing page
posted_date: 2024-05-09T23:42:42+00:00
experience: Unknown
eligibility: Education requirement mentioned
```

HTML cleanup was fixed. Description is now plain text instead of raw `<p>`, `<b>`, `<br>`, etc.

The example is Remote - US and old, so it should be rejected by location/freshness in final processing.

---

## 12. Adzuna Transformer

File:
`src/processing/transform.py`

Original bug:
```python
"skills": "",
"experience": "",
"eligibility": ""
```

These values were hard-coded blank, even though `job_parser.py` had extracted them.

This was fixed.

Current transformer now:
- imports `parse_job_description`
- parses the description
- assigns parsed skills
- assigns parsed experience
- assigns parsed eligibility
- detects work mode
- formats salary with proper ₹
- preserves company/location/post date/job URL

Transform V2 passed.

Real examples:

```text
2026-08-27 Data Analyst
skills: ['SQL', 'Python']
experience: 5-7 years
location: Delhi, India
work_mode: Unknown
```

```text
2026-05-14 Data Analyst
skills: ['SQL', 'Microsoft Excel', 'Power BI', 'Data Visualization']
experience: Unknown
location: Delhi, India
work_mode: Unknown
```

---

## 13. Scam Detector

File:
`src/processing/scam_detector.py`

Original issue:
Substring matching marked:
`No registration fee`
as HIGH risk because it contained `registration fee`.

V2 is negation-aware.

Suspicious terms:
- registration fee
- processing fee
- security deposit
- training fee
- pay to apply
- pay before joining
- upi payment
- guaranteed job
- guaranteed placement

V2 test passed:

```text
No registration fee
=> LOW

Pay registration fee of Rs 999
=> HIGH
flag: registration fee

Guaranteed placement
=> HIGH
flag: guaranteed placement

Normal Data Analyst job
=> LOW

No security deposit required
=> LOW
```

Do not regress this false-positive fix.

---

## 14. Matching Score

File:
`src/matching/score.py`

Current exact logic:

```python
CORE_SKILL_WEIGHTS = {
    "sql": 10,
    "microsoft excel": 8,
    "power bi": 8,
    "python": 7,
    "pandas": 5,
    "exploratory data analysis": 4,
    "statistical analysis": 4,
    "data cleaning": 4,
    "numpy": 2,
    "data visualization": 2,
    "feature engineering": 1,
    "mysql": 1
}

ROLE_WEIGHTS = {
    "data analyst": 25,
    "data analyst intern": 25,
    "junior data analyst": 25,
    "data analytics intern": 25,
    "data science intern": 20,
    "bi analyst": 18,
    "reporting analyst": 16,
    "mis analyst": 15,
    "analytics associate": 15
}
```

Scoring behavior:
- Role: up to 25
- Core skills: up to 35
- Additional skills: up to 10
- Fresher/entry/intern experience signal: +15
- Preferred location: +10
- Maximum 100

Important:
- Do not artificially inflate scores.
- A real fresh Data Analyst job previously scored 52 because transform.py was passing blank skills.
- Transform.py has now been fixed, so the score must be re-tested.
- A fresh Data Analyst requiring 5–7 years should NOT get a high score merely because the title matches.

Potential future issue to evaluate only if tests prove it:
- Exact skill matching may miss variants like "Excel" vs "Microsoft Excel".

---

## 15. Decision Engine

File:
`src/matching/decision.py`

Current exact code:

```python
def make_final_decision(match_result, quality_result):
    score = match_result.get("score", 0)
    risk = match_result.get("risk", "UNKNOWN")
    quality = quality_result.get("quality", "LOW")

    if risk == "HIGH":
        decision = "DO NOT APPLY"
    elif score >= 90 and quality == "HIGH":
        decision = "APPLY"
    elif score >= 80 and quality in ["HIGH", "MEDIUM"]:
        decision = "STRONG MATCH"
    elif score >= 70 and quality != "LOW":
        decision = "REVIEW"
    else:
        decision = "SKIP"

    return {
        "decision": decision,
        "match_score": score,
        "risk": risk,
        "quality": quality
    }
```

Decision hierarchy:

```text
APPLY
STRONG MATCH
REVIEW
SKIP
DO NOT APPLY
```

`DO NOT APPLY` overrides score when risk is HIGH.

Important:
- A score of 85 does NOT automatically mean APPLY.
- APPLY is intentionally conservative: score >=90 AND quality HIGH.
- Earlier narration expected APPLY at 85, but that was an incorrect assumption. The actual decision code correctly returned STRONG MATCH.

Do not change this without a demonstrated requirement.

---

## 16. Profile Config

Current `config/profile.yaml`:

```yaml
candidate:
  name: "Alin Kumar"
  education: "B.Sc. (Hons.) Computer Science"
  status: "Pursuing"
  location: "Delhi, India"

target_roles:
  primary:
    - "Data Analyst"
    - "Data Analyst Intern"
    - "Junior Data Analyst"
    - "Data Analytics Intern"
    - "Data Science Intern"
  secondary:
    - "BI Analyst"
    - "Reporting Analyst"
    - "MIS Analyst"
    - "Analytics Associate"

preferred_locations:
  - "Delhi"
  - "Noida"
  - "Gurgaon"
  - "Remote"

experience_level:
  - "Internship"
  - "Fresher"
  - "Entry Level"

core_skills:
  - "SQL"
  - "Microsoft Excel"
  - "Power BI"
  - "Python"
  - "Pandas"
  - "NumPy"
  - "Data Cleaning"
  - "Exploratory Data Analysis"
  - "Feature Engineering"
  - "Statistical Analysis"
  - "Data Visualization"
  - "MySQL"

additional_skills:
  - "Machine Learning"
  - "Deep Learning"
  - "Scikit-learn"
  - "XGBoost"
  - "Git"
  - "GitHub"
  - "Matplotlib"
  - "Seaborn"
  - "Plotly"
```

---

## 17. Source Collector

File:
`src/collectors/multi_source.py`

Current design:
- `collect_adzuna(...)`
- `collect_muse(...)`
- `collect_all()`

Raw jobs are source-tagged:

```python
{
    "_source": "Adzuna",
    "job": raw_adzuna_job
}
```

or:

```python
{
    "_source": "The Muse",
    "job": raw_muse_job
}
```

Controlled collection test passed:

```text
Adzuna: 10
The Muse: 1
Total raw: 11
```

Source tags were correct.

Important:
- Do not immediately run a huge `collect_all()` blindly.
- Earlier full theoretical query count could become large.
- First use controlled tests, then optimize query volume.

---

## 18. Batch Processor

File:
`src/processing/batch_processor.py`

It is source-aware:
- Adzuna -> `transform_adzuna_job`
- The Muse -> `transform_muse_job`

Pipeline:

```text
Raw jobs
  ↓
Transform
  ↓
Location Eligibility
  ↓
Freshness
  ↓
Dedup/Repost
  ↓
Scam
  ↓
Match
  ↓
Quality
  ↓
Decision
```

Input format uses `_source` and `job`.

---

## 19. Synthetic Full Decision Test

After scam V2:

```text
FULL DECISION INTEGRATION V2 TEST
Input: 5
Results: 3
Location rejected: 1
Old: 1
Duplicates: 0
Reposts: 0

Safe Analytics Pvt Ltd | Data Analyst Intern | Score: 85 | Risk: LOW | Decision: STRONG MATCH
Analytics Company | Junior Data Analyst | Score: 53 | Risk: LOW | Decision: SKIP
Suspicious Careers | Data Analyst Intern | Score: 68 | Risk: HIGH | Decision: DO NOT APPLY
```

Expected interpretation:
- Safe Analytics: good fresh India job, low risk, strong match.
- Analytics Company: not strong enough.
- Suspicious Careers: correctly blocked.
- Old job: rejected.
- US remote job: rejected by location.

This test is considered PASS.

---

## 20. Real Multi-Source Pipeline Test

Previous real test:

```text
REAL MULTI-SOURCE PIPELINE TEST
Raw: 11
Final results: 1
Location rejected: 1
Old: 9
Duplicates: 0
Possible reposts: 0

Adzuna | Vikash Technologies | Data Analyst | Delhi, India | Unknown | 2026-08-27T16:06:25+00:00 | 52 | LOW | SKIP
```

Interpretation:
- Freshness works.
- Location filtering works.
- Scam works.
- Old filtering works.
- Dedup/repost works.
- Only one job survived this particular 11-job real sample.
- The score 52 was investigated.
- Root cause: `transform.py` was discarding parser skills.
- That bug has now been fixed.
- Therefore the real score should be re-tested after the transform V2 fix.

---

## 21. Most Recent Test That Needs To Be Run

After fixing `transform.py`, the next exact test is:

```powershell
python -c "from src.collectors.adzuna import search_jobs; from src.processing.transform import transform_adzuna_job; from src.matching.score import calculate_match_score; import yaml; profile=yaml.safe_load(open('config/profile.yaml',encoding='utf-8')); data=search_jobs('Data Analyst','Delhi',page=1,results_per_page=5); print('REAL SCORE V2 TEST'); [print('\nROLE:',(job:=transform_adzuna_job(raw))['role'],'| DATE:',job['posted_date'],'| SKILLS:',job['skills'],'| EXPERIENCE:',job['experience'],'| SCORE:',calculate_match_score(job,profile)) for raw in data.get('results',[])]"
```

Purpose:
- Verify parsed skills now reach the scoring engine.
- Check whether the fresh 2026-08-27 Data Analyst requiring 5–7 years gets an appropriately low score.
- Do not inflate score merely because the title matches.

---

## 22. What Is Completed

Completed and tested:
- Adzuna API
- The Muse API
- Search config
- Multi-query collection
- Robust collection
- Freshness V2
- Deduplication
- Repost detection
- Job parser V2
- Adzuna transform V2
- The Muse transform
- Work mode detection
- Location eligibility
- Scam detector V2
- Source-aware batch processor
- Synthetic full decision integration
- Real multi-source collection
- Real multi-source pipeline test

---

## 23. Immediate Roadmap

1. Run REAL SCORE V2 TEST after transform.py fix.
2. If scoring is sensible, do not modify score.py unnecessarily.
3. Run a controlled real multi-source collection through the complete processor again.
4. Optimize search strategy for freshness and coverage.
5. Keep only genuinely fresh/relevant/eligible jobs.
6. Rank final results.
7. Later build output layer such as Google Sheets/Streamlit.
8. Later add scheduled daily execution.
9. Final Apply action remains manual.

---

## 24. Non-Negotiable Engineering Decisions

Do NOT:
- weaken freshness <=7 days just to increase quantity
- classify old jobs as fresh
- treat all Remote jobs as India eligible
- guess Unknown work mode
- flag "No registration fee" as a scam
- mass-submit job applications automatically
- add a remote-only Source #3
- randomly inflate match scores
- replace working files without checking current behavior
- waste time on unnecessary API/source hunting
- sacrifice genuine-job quality for raw job count

Do:
- prefer fresh, genuine, relevant jobs
- preserve evidence-based filtering
- test each major change
- use complete replacement files when making file corrections because the user prefers that
- explain progress in Hinglish
- keep instructions direct and step-by-step

---

## 25. Core Philosophy

Final priority order:

1. Genuine
2. Fresh
3. India eligible
4. Relevant role
5. Experience compatible
6. Low scam risk
7. Not duplicate/repost
8. Strong skill match
9. Good quality
10. Clear decision

The system is intended to be a reliable job-search automation engine, not a system that simply outputs a large number of listings.

