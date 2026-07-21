# Candidate Onboarding with AI CV Parsing

A two-step candidate onboarding module for a dental recruitment platform. A candidate
uploads a CV, an AI parser extracts what it can into a draft profile, and the candidate
reviews, corrects and completes the profile before saving. Built as a maintainable
Rails module intended to grow into a larger ATS.

- **Step 1 — Upload:** drag-and-drop a PDF, DOC or DOCX. The file is stored privately and
  parsed in the background.
- **Step 2 — Review:** the profile form is prefilled from the CV, with each field marked
  *Extracted from CV*, *Please check* or *Missing*. The candidate edits everything, adds
  education and work experience, selects skills, and submits.

If parsing fails for any reason, the candidate can always complete the form by hand.

---

## Tech stack

Ruby 3.4 · Rails 8.1 · PostgreSQL · Hotwire (Turbo + Stimulus) · Tailwind · Propshaft ·
importmaps · Solid Queue / Cache / Cable · Active Storage · OpenAI Responses API ·
RSpec · FactoryBot · Shoulda Matchers · Rubocop · Brakeman.

No Redis, no Sidekiq, no Node build step.

---

## Setup

### Prerequisites

- Ruby 3.4.5 (`.ruby-version` is set; use rbenv, asdf or mise)
- PostgreSQL 14+ running locally
- Google Chrome (only for the system specs)
- LibreOffice (optional — only needed to parse legacy `.doc` files; see below)

### Install

```bash
git clone <repo> dental-ats-onboarding
cd dental-ats-onboarding
bundle install
bin/rails db:prepare   # creates the database, loads the schema and seeds reference data
```

`db:prepare` seeds the platform vocabularies (job functions, skills, regions, employment
types, languages, working days, transport types). Re-running the seeds is idempotent.

### OpenAI API key

The parser needs an API key. Provide it either as an environment variable:

```bash
export OPENAI_API_KEY=sk-...
```

or through Rails encrypted credentials (`bin/rails credentials:edit`):

```yaml
openai:
  api_key: sk-...
```

Without a key the app still runs: uploads succeed, parsing fails cleanly, and the
candidate completes the form manually.

### Run locally

```bash
bin/dev
```

This starts Puma, the Tailwind watcher and a Solid Queue worker (via `Procfile.dev`).
Visit <http://localhost:3000> for onboarding and <http://localhost:3000/admin> for the
recruiter view.

### Configuration

`config/cv_parsing.yml` holds the tunable settings:

| Setting | Default | Meaning |
|---|---|---|
| `max_file_size_megabytes` | 25 | Upload size limit (5 in test) |
| `accepted_content_types` | PDF/DOC/DOCX | Allowed uploads |
| `openai.model` | `gpt-4.1-mini` | Extraction model |
| `openai.temperature` | 0 | Deterministic extraction |
| `openai.request_timeout_seconds` | 60 | Per-request timeout |
| `openai.max_attempts` | 3 | Job retry budget for transient API errors |

The recruitment notification inbox is set with `RECRUITMENT_INBOX` (see
`config/initializers/recruitment.rb`).

---

## Testing

```bash
bundle exec rspec                                        # everything (needs Chrome)
bundle exec rspec --exclude-pattern "spec/system/**/*"   # fast: no browser
bundle exec rubocop
bin/brakeman
```

No test makes a real OpenAI request; the HTTP boundary is stubbed via WebMock and net
connections are disabled. The two system specs drive a real headless Chrome.

---

## Architecture

The full design rationale lives in [ARCHITECTURE.md](ARCHITECTURE.md). The essentials:

### Conditional form logic is data, not code

The PRD's show/hide rules (dentist → BIG registration and revenue; employed → salary;
freelance → percentage) are the part most likely to change, so they live as columns on
`job_functions` and `employment_types` rather than as branching Ruby. The same record
drives both the server-rendered form and the Stimulus controller that toggles fields, so
the two can never disagree. **Adding a job function is a seed row, not a code change.**

### The AI only returns JSON, and never invents data

The parser calls the OpenAI **Responses API with Structured Outputs (`strict: true`)** and
a schema in which every extractable field is typed `["string", "null"]`. Null is always a
valid answer, so the model is never cornered into fabricating a value. The system prompt
reinforces this ("never guess, return null"). The response crosses two gates — JSON schema
validation, then explicit mapping — before it ever reaches a model attribute. The AI output
is **never** assigned directly to a record.

### The parsing pipeline

```
Upload → store file → ParseCandidateCvJob
  → ExtractText (PDF/DOCX/DOC strategy)
  → OpenAIParser (structured output, one re-ask on bad JSON)
  → ValidateResult (JSON schema)
  → MapResult (pure JSON → attribute hashes, no DB writes)
  → SaveResult (one transaction: profile, education, work experience, skills, languages)
  → status: completed  (Turbo Stream swaps the skeleton for the review form)
```

`MapResult` is a pure function, which makes the hardest logic testable without fixtures;
`SaveResult` owns persistence. Transient API errors propagate so the job retries with
backoff; empty extraction and invalid JSON are terminal and drop to manual entry.

### Field provenance

The *Extracted / Please check / Missing* badges are driven by one `jsonb` column,
`candidate_profiles.extraction_metadata`, read by a small PORO — no per-field source
column. "Please check" comes from a `low_confidence_fields` list the model self-reports.

### Layout

```
app/
├── forms/onboarding/              upload form object
├── services/
│   ├── candidate_profiles/        create, complete, field provenance
│   ├── cv_parsing/                extraction, parser, schema, mapping, save, pipeline
│   ├── openai/                    the only object that touches the API
│   ├── skills/ educations/ work_experiences/   matcher and importers
│   └── notifications/             onboarding-completed event
├── jobs/parse_candidate_cv_job.rb
├── policies/candidate_document_policy.rb
├── javascript/controllers/        file upload, parsing poll, nested form, conditional fields
└── views/onboarding/ + views/admin/
```

Service objects share a `.call` / `#call` convention returning a `ServiceResult`.

### Data model

All tables use UUID primary keys. Integrity is enforced in the database, not only in
models: foreign keys throughout, composite unique indexes on every join table, and check
constraints for the numeric rules (percentage 0–100, non-negative salary/revenue/travel/
experience), date ordering, the current-job rule, the candidate-skill XOR, and the rule
that a completed profile must have recorded consent.

### CV text extraction

| Format | Library | Notes |
|---|---|---|
| PDF | `pdf-reader` | Pure Ruby, no system binary. Scanned/image PDFs yield no text and fall through to manual entry. |
| DOCX | `docx` | Pure Ruby; reads paragraphs and table cells. |
| DOC | LibreOffice headless | Legacy OLE format has no viable pure-Ruby reader. Converts to DOCX, then reuses the DOCX path. If LibreOffice is absent, the document fails cleanly into manual entry rather than crashing. |

---

## Security and privacy

- CVs are stored on a **private** Active Storage service and served only through signed,
  expiring routes — never a public URL.
- Upload content type is verified from the file's **magic bytes** (Marcel), not the
  browser header or filename, so a renamed file cannot slip through.
- A consent checkbox is required, and a database constraint guarantees a completed profile
  has recorded consent.
- Raw parser output is retained for recruiter debugging but is **never** shown to
  candidates.
- Strong parameters throughout; Brakeman runs clean.

---

## Notifications

On completion the module logs a `candidate_onboarding_completed` event and emails the
recruitment inbox (`AdminMailer`). A webhook for downstream automation is a natural
extension point in `Notifications::CandidateOnboardingCompleted` but is not part of the MVP.

---

## Tradeoffs and deviations from the brief

- **Validation contexts instead of a profile form object.** Rails' `:onboarding_review`
  context already expresses "required at this step", and wrapping
  `accepts_nested_attributes_for` in a form object would mean reimplementing nested
  assignment, error propagation and `_destroy` handling. A form object is still used for
  the upload step, which maps to no single record.
- **One policy object, not an authorization gem.** The MVP has no authentication, so a
  full Pundit suite would be scaffolding for a system that doesn't exist. The single rule
  that matters — who may download a CV — lives in `CandidateDocumentPolicy`.
- **No profile completeness score.** Explicitly out of MVP scope in the PRD.
- **`.doc` depends on LibreOffice**, because no pure-Ruby reader for the format exists. It
  degrades gracefully when the binary is missing.

---

## Future improvements

- Real recruiter authentication, at which point `CandidateDocumentPolicy` and the admin
  namespace gain actual actors.
- A webhook emitter alongside the completion notification.
- OCR for scanned/image PDFs.
- Resume/abandon via a signed link so a candidate can return to a draft on another device.
- Duplicate candidate detection and job matching.
