# Candidate Onboarding — Architecture

Milestone 1 deliverable. No application code exists yet; this document is the contract
for everything that follows.

---

## 1. Guiding decisions

Five decisions shape the rest of this document. Each one trades something away, so each
is stated with its cost.

### 1.1 Conditional logic is data, not code

The PRD's §4 rules ("if dentist → show BIG", "if assistant → hide BIG") are the most
likely part of this system to change. A recruiter will want a new job function long
before they want a new feature.

So the rules live as columns on `job_functions`, not as a `case` statement:

| column | drives |
|---|---|
| `requires_big_registration` | show/hide BIG status + BIG number |
| `revenue_relevant` | show/hide average daily revenue |
| `skill_group_id` | which skill set renders |

Adding "Paro-prevention assistant" becomes a seed row. No Ruby changes, no redeploy of
logic, no new branch in a conditional. The same table feeds the server-rendered form and
— serialised into `data-*` attributes — the Stimulus controller that toggles fields
client-side. **One source of truth, two consumers.** This is the single most important
structural choice in the module.

Cost: a developer reading `_form.html.erb` cannot see the rules; they must read the
seeds. Mitigated by `db/seeds/job_functions.rb` being the canonical, commented table.

### 1.2 Anti-hallucination is enforced by schema, not by prompt wording

The PRD is emphatic that the parser must never invent data. Prompt instructions ("never
guess") are necessary but are not a guarantee — a model asked for a `string` will tend to
produce a plausible string.

The actual enforcement is OpenAI **Structured Outputs with `strict: true`**, where every
extractable field is typed `["string", "null"]`. Null becomes a first-class, valid,
schema-permitted answer. The model is never cornered into inventing a value to satisfy
the type. Prompt wording reinforces this; the schema enforces it.

### 1.3 Provenance is one JSONB column, not forty

Three badges are required: *Extracted from CV*, *Missing*, *Please check*. Encoding that
per-field in the schema would mean a parallel `*_source` column for every attribute.

Instead `candidate_profiles.extraction_metadata` (jsonb) holds:

```json
{
  "first_name":  { "source": "cv" },
  "phone":       { "source": "cv", "needs_review": true },
  "city":        { "source": "cv" }
}
```

Absent key → **Missing**. Present → **Extracted from CV**. `needs_review: true` →
**Please check**. A single PORO, `CandidateProfiles::FieldProvenance`, reads it and a
single view helper renders the badge. Adding a field requires no migration.

`needs_review` is populated from a `low_confidence_fields: []` array the model returns
alongside the data — it self-reports which paths it was unsure of. Cheaper and more
honest than a per-field confidence float, which models calibrate poorly.

### 1.4 Validation contexts over a form-object layer

Your brief suggested `app/forms/` for the profile. I want to argue against it for the
*profile* specifically, and for it in one narrower place.

The difficulty: the review step needs `accepts_nested_attributes_for` on educations and
work experiences (it is what makes `fields_for` + Stimulus add/remove work, and it is the
Rails-native path Turbo expects). Wrapping nested attributes in a form object means
re-implementing attribute assignment, nested error propagation, and `_destroy` handling.
That is a lot of custom machinery to maintain, and it is the kind of cleverness that
reads as AI-generated rather than senior.

Rails already solves conditional, step-scoped validation with **validation contexts**:

```ruby
validates :city, presence: true, on: :onboarding_review
validates :big_number, presence: true, on: :onboarding_review, if: :big_registered?
```

The model keeps invariants; the `:onboarding_review` context carries the step-specific
required-ness. The parser can persist a half-empty draft (default context, no
presence rules) and the candidate's final submit runs `save(context: :onboarding_review)`.

`app/forms/` still earns its place for **`Onboarding::UploadForm`** — step 1 spans a file,
a content-type check, a size check and a consent checkbox, and maps to no single record.
That is a genuine form object.

Cost: `CandidateProfile` carries more validation lines than a pure form-object split
would leave it. Accepted — they are declarative and colocated with the data they guard.

### 1.5 Identity is deferred until we have an email

There is no authentication in the MVP (PRD §9 asks only that CVs not be public). But
`User has_one :candidate_profile` is required.

Creating a `User` at upload time forces a placeholder email — a unique-index landmine and
a source of orphan rows from abandoned uploads. Instead: onboarding creates a
**`CandidateProfile` in `draft`** with `user_id` nullable, tracked by
`session[:candidate_profile_id]`. On final submit, `CandidateProfiles::Complete`
find-or-creates the `User` by the now-known email and links it. Identity is established
exactly when it becomes knowable.

This also satisfies PRD §11 "candidate closes page during parsing" — the draft and its
document survive; the session (or a signed resume link) returns them to the flow.

---

## 2. Text extraction — library evaluation

The three formats are not equally hard, and one of them is genuinely unpleasant. All
three sit behind one interface so the choices are individually reversible:

```
CvParsing::TextExtraction::Resolver  → picks a strategy from content_type
  ├── Pdf
  ├── Docx
  └── Doc
```

Each responds to `#call(file) → String`. Adding RTF is a new class plus a registry entry
(Open/Closed).

### PDF — `pdf-reader`

| candidate | verdict |
|---|---|
| **`pdf-reader`** | **Chosen.** Pure Ruby, no native extension, no system binary. Installs identically on a dev Mac and a Linux CI container — which matters more than raw quality, because a system dependency that silently isn't installed produces empty text, and empty text produces an empty profile that looks like a parsing bug. |
| `pdftotext` (poppler) | Better output. `-layout` preserves the two-column layouts common in designed CVs, where `pdf-reader` can interleave columns. But it is a shell-out to a binary that must be installed everywhere, and shelling out on user-supplied files needs care. |
| Apache Tika (`yomu`) | Best quality, handles all three formats uniformly. Requires a JVM. Disproportionate for an MVP. |

Recommendation: ship `pdf-reader`; keep the `Pdf` strategy small enough that swapping in
poppler is a one-file change if column-interleaving shows up in real CVs. I would not
pre-optimise for it without evidence.

`pdf-reader` extracts embedded text only — a scanned/image PDF yields nothing. That is
**not** a failure to hide: the extractor raises `EmptyExtractionError`, the document goes
`failed`, and the candidate continues manually. Exactly PRD §11's "CV contains little
information" path. OCR is explicitly out of MVP scope.

### DOCX — `docx`

A `.docx` is a zip of XML. The `docx` gem is a thin, dependency-light reader over
`word/document.xml` and is entirely sufficient for plain text. The alternative —
`Zip` + Nokogiri by hand — is ~20 lines and avoids a dependency, but loses correct
handling of paragraph and table-cell boundaries, which matters because CVs are frequently
laid out in invisible tables. Use the gem.

### DOC — LibreOffice headless

The honest assessment: **legacy `.doc` is a binary OLE compound format with no viable
pure-Ruby reader.** No gem does this well. The real options are `antiword` (unmaintained
since 2005, poor on Word 2000+), or converting via **LibreOffice headless**:

```
soffice --headless --convert-to docx --outdir <tmp> <file>
```

…then routing the result through the `Docx` strategy. That reuses the strategy we already
trust and keeps `Doc` a thin adapter.

This is the one place a system dependency is unavoidable, so it is contained:
`Doc` checks for the binary at boot and, if absent, fails the document cleanly into the
manual path rather than crashing the job. **A missing LibreOffice degrades the feature; it
does not break the app.** `.doc` remains accepted at upload either way — PRD §12 requires
that, and rejecting the upload would be worse than accepting it and falling back to
manual entry.

---

## 3. Parsing pipeline

```
POST /onboarding (file + consent)
   │
   ├─ Onboarding::UploadForm         validate type, size, consent
   ├─ CandidateDocument              Active Storage attach, status: pending
   └─ ParseCandidateCvJob            enqueued (Solid Queue)
                                        │
   ┌────────────────────────────────────┘
   │  status: processing  ──── Turbo Stream broadcast → skeleton loader
   │
   ├─ CvParsing::ExtractText         strategy by content type
   ├─ CvParsing::OpenAIParser        Responses API, structured output, temp 0
   ├─ CvParsing::ValidateResult      JSON Schema check on the response
   ├─ CvParsing::MapResult           JSON → attribute hashes (no DB writes)
   │     ├─ Skills::Matcher              fuzzy-match to platform skills
   │     ├─ Educations::Importer
   │     └─ WorkExperiences::Importer
   ├─ CvParsing::SaveResult          single transaction, draft context
   │
   └─ status: completed ──── Turbo Stream broadcast → redirect to review
```

Every arrow is a separate object with one reason to change. Note the deliberate split:
**`MapResult` never touches the database** — it is a pure function from parsed JSON to
attribute hashes, which makes the hardest logic in the system trivially unit-testable
without fixtures. `SaveResult` owns persistence and the transaction boundary.

The AI response is never assigned to a model directly. It crosses two gates —
schema validation, then explicit mapping — before reaching an attribute hash.

### Failure handling

| failure | handling |
|---|---|
| OpenAI timeout / 429 / 5xx | `retry_on`, exponential backoff, 3 attempts |
| Invalid JSON or schema mismatch | one re-ask with the validation error appended; then fail |
| Empty text extraction | `discard_on` → `failed` immediately; retrying cannot help |
| Unparseable / any other | `failed` + `parsing_error` recorded |

`failed` is never a dead end. The review step renders with empty fields and the candidate
completes manually — PRD §11. Raw parser output is stored on the document for recruiter
debugging but is **never rendered to candidates** (PRD §9).

---

## 4. Folder structure

```
app/
├── controllers/
│   ├── onboarding/
│   │   ├── cv_uploads_controller.rb        step 1
│   │   ├── parsing_status_controller.rb    Turbo polling fallback
│   │   └── profiles_controller.rb          step 2
│   └── admin/
│       ├── candidates_controller.rb
│       └── documents_controller.rb         authorized CV download
├── forms/
│   └── onboarding/upload_form.rb
├── jobs/
│   └── parse_candidate_cv_job.rb
├── models/
│   ├── reference_record.rb                 abstract base for the 6 lookup tables
│   └── concerns/
├── policies/
│   └── candidate_document_policy.rb        who may download a CV
├── services/
│   ├── candidate_profiles/{create,update,complete,field_provenance}.rb
│   ├── cv_parsing/{extract_text,openai_parser,validate_result,map_result,save_result}.rb
│   ├── cv_parsing/text_extraction/{resolver,base,pdf,docx,doc}.rb
│   ├── openai/{client,responses_request}.rb    HTTP boundary — the only place it lives
│   ├── skills/matcher.rb
│   ├── educations/importer.rb
│   ├── work_experiences/importer.rb
│   └── notifications/candidate_onboarding_completed.rb
├── javascript/controllers/
│   ├── conditional_fields_controller.js    §4 show/hide, data-driven
│   ├── nested_form_controller.js           add/remove education + experience
│   ├── skill_selector_controller.js
│   └── file_upload_controller.js           drag & drop
└── views/
    ├── onboarding/
    └── admin/
config/
├── cv_parsing.yml                          max size, model, temperature, timeouts
└── schemas/cv_extraction.json              the structured-output contract
```

Service objects share one convention: a class method `.call`, an instance `#call`,
returning a `Result` value object (`success?` / `value` / `error`). No `ApplicationService`
inheritance chain — a shared `Result` struct is all the coupling that is warranted.

---

## 5. Data model

All tables use UUID primary keys (`gen_random_uuid()`, native in PG 14).

### Reference tables

`regions`, `employment_types`, `job_functions`, `transport_types`, `working_days`,
`languages`, `skill_groups`, `skills` — all share `slug` (unique, NOT NULL), `name`,
`position`, `active`. They inherit `ReferenceRecord`, an abstract class carrying the
shared validations and an `ordered` / `active` scope. Six near-identical models, one
place to change them.

`job_functions` additionally carries the §1.1 behaviour columns.
`skills` belongs_to `skill_group`; `job_functions` belongs_to `skill_group`.

### Core

```
users                    email (unique), timestamps
candidate_profiles       belongs_to :user (nullable until completion)
                         belongs_to :job_function (nullable)
                         personal, preference, employment, availability columns
                         status (enum: draft, completed)
                         extraction_metadata (jsonb, default {})
                         consented_at
candidate_documents      belongs_to :candidate_profile
                         has_one_attached :file (private service)
                         document_type, original_filename, content_type, file_size
                         parsing_status (enum), parsed_at, parsing_error
                         raw_parser_output (jsonb) — never shown to candidates
educations               belongs_to :candidate_profile, level (enum)
work_experiences         belongs_to :candidate_profile, current_job (bool)
candidate_skills         join + free_text_suggestion for unmatched CV skills
candidate_languages      join + proficiency (enum)
```

Plus join tables for the multi-selects: `candidate_profile_regions`,
`candidate_profile_employment_types`, `candidate_profile_transport_types`,
`candidate_profile_working_days`.

Every FK is a real database foreign key. Every join table carries a composite unique
index. Money and percentage columns are `decimal`, never `float`. Enums are Rails enums
over integer columns with a matching NOT NULL + default.

`candidate_skills.free_text_suggestion` is how PRD §3.6's "unknown skills stored for
recruiter review" works without polluting the canonical `skills` table with unvetted
strings.

---

## 6. Deviations from the brief

Four, each argued above:

1. **Validation contexts instead of a profile form object** (§1.4) — avoids
   re-implementing nested-attribute machinery.
2. **`app/policies/` is one class, not a full authorization gem** — the MVP has no auth
   (PRD §13), so a Pundit-style suite would be scaffolding for a system that doesn't
   exist. One policy object guards CV download, which is the one real requirement (§9).
3. **No `ProfileCompletion` service** — your example folder list included it, but PRD §13
   puts "profile completeness score" explicitly out of MVP scope. Building it would be
   the premature optimisation the brief warns against. The folder is omitted; say the
   word and it comes back.
4. **`.doc` depends on LibreOffice** (§2) — no pure-Ruby path exists; degrades gracefully.

---

## 7. Environment gap

Ruby 3.4.5 is installed via rbenv but the shell default is 3.2.2, and Rails 8 is not yet
installed under 3.4.5. Milestone 2 begins with:

```
rbenv local 3.4.5
gem install rails -v '~> 8.0'
rails new . --database=postgresql --css=tailwind --skip-test
```

Postgres 14.19 is running and is sufficient (Solid Queue/Cache/Cable all require only PG).
