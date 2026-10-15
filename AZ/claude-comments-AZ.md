# Review: Azerbaijani (AZ) translation — PR #265

* PR: https://github.com/arc42/arc42-template/pull/265 ("Add Azerbaijani (AZ) translation", by @nihadio)
* Reviewed commit: `b3cf97b` (identical to PR head)
* Reference: `EN/` (9.0-EN, July 2025)
* Reviewer: Claude (automated review, line-by-line comparison against EN). I am not a native Azerbaijani speaker. Please have a native speaker confirm the terminology remarks below.

## Verdict

**Ready to merge.** (The one technical fix, T1, has been pushed to this branch as cacba4f.) The translation is complete, it matches the EN text closely, and the technical side is clean. I found no omissions, no meaning-changing mistranslations and no broken markup. Every remark below is minor or a suggestion.

---

## 1. Structural / technical checks

| Check | Result |
|---|---|
| All EN files present (12 chapters, `about-arc42.adoc`, `config.adoc`, main doc, `version.properties`, 5 images) | ✅ |
| Line counts per file vs EN | ✅ identical, except `09_architecture_decisions.adoc` (36 vs 37: one 3-line sentence was rewrapped into 2 lines; nothing missing) |
| Anchors `[[section-…]]`, `ifdef::arc42help[]`/`endif`, `[role="arc42help"]`, `****` blocks, tables, `include::` | ✅ identical to EN |
| External links (docs.arc42.org, quality.arc42.org, ISO 25010, cognitect ADR) | ✅ all URLs identical to EN |
| Image file names and references | ✅ (EN images reused; only alt texts translated, which is fine) |
| Encoding | ✅ UTF-8, no CRLF, no BOM, no tabs, no trailing whitespace, no zero-width/NBSP characters |
| `asciidoctor -v AZ/arc42-template.adoc` (with-help variant) | ✅ 0 warnings, 0 errors |
| `asciidoctor -v -a arc42help! …` (plain variant) | ✅ 0 warnings, 0 errors |
| HTML `<title>` | ✅ "arc42 Şablonu" |
| `config.adoc` | ✅ same layout as `TR/adoc/config.adoc` (`:lang: az`, admonition and caption labels, `chapter-signifier: Bölmə`, html5-only `:title:`) |
| `version.properties` | ✅ all four keys present (`revnumber=9.0-AZ`, `revdate=oktyabr 2026`, `revdate-iso=2026-10`, `revremark`). Lower-case month is correct in Azerbaijani. |
| README: language table + revisions entry | ✅ alphabetical position (before Czech) is fine |

### Issue T1: `first-commits-per-language.sh` not updated — ✅ fixed in cacba4f

The Turkish PR (#264) added `"TR"` to the `languages=(…)` array in `first-commits-per-language.sh`. This PR does not add `"AZ"`. Suggested change:

```bash
languages=("DE" "EN" "ES" "PT" "NL" "CZ" "HU" "IT" "RU" "TR" "UKR" "FR" "ZH" "AZ")
```

(`ZH-TW` is also missing from that list. That is unrelated to this PR.)

### Note T2: arc42-generator `languageNames`

The PR description already says this: `AZ` must be added to `languageNames` in arc42-generator (`AZ: 'Azərbaycanca'`), or the download page shows the code instead of a name. This is a follow-up in the other repo, not a blocker here.

---

## 2. Content review (EN ↔ AZ, chapter by chapter)

Overall, the meaning is preserved throughout. The translator often adds the English term in parentheses on first use, e.g. "(driving forces)", "(stakeholders)", "(runtime view)", "(deployment view)", "(traceability)", "(nice-to-have)". That is helpful for readers who also use English literature.

### Main document `arc42-template.adoc`
* ✅ Intro text (help version vs. _plain_ version) is correct.
* ℹ️ Chapter-11 include comment: AZ says `// 11. Risklər və texniki borclar`, EN says `// 11. Technical Risks`. The AZ comment actually matches the real chapter title "Risks and Technical Debts" better. It is only a comment. No action needed.

### 01 Introduction and Goals
* ✅ Complete and accurate, including the stakeholder example table (all 8 rows, all 3 columns).
* ✅ "buzzwords" → "dəbdə olan boş ifadələr" is a good, idiomatic choice.
* ℹ️ "End Users … *drive* quality goals" → "…keyfiyyət məqsədlərini *müəyyənləşdirirlər*" ("determine"). That is a small shift in nuance, and acceptable.
* ⚠️ Terminology: "development team" → "**tərtibat** komandası". Elsewhere "development (process)" is translated as "**işlənib hazırlanma**" (7×). See terminology section below.

### 02 Architecture Constraints
* ✅ Complete and accurate. "they may be negotiable, though" → "danışıqlar predmeti ola bilər" is good.

### 03 Context and Scope
* ✅ Complete and accurate (business context, technical context, mapping I/O to channels).

### 04 Solution Strategy
* ✅ Complete and accurate. "Motivate what was decided…" → "…əsaslandırın" (justify) is the correct reading of "motivate" here.

### 05 Building Block View
* ✅ Complete, including all black-box and white-box template placeholders and level 1/2/3 headings.
* ✅ "floor plan" → "mərtəbə planı" works well.
* ℹ️ The list of building-block kinds uses "laylar" for *layers*. "qatlar" may be the more standard/formal word (native speaker to decide). "bölmələr (partitions)" is fine, but "bölmə" is also the word used for document *section* everywhere. The parenthesised English term removes the ambiguity, so this is OK.
* ✅ The heading `Motivation::` inside the white-box template is translated as "Əsaslandırma::" (rationale) rather than "Motivasiya". That is semantically correct for that spot.
* ✅ Asciidoc italics like `..._tikinti bloku 1_ elementinin…` render correctly (verified in the HTML build).

### 06 Runtime View
* ✅ Complete and accurate.
* ℹ️ "(instances of) building blocks" → "tikinti bloklarının (daha doğrusu, onların nüsxələrinin)" adds "more precisely". That is a slight elaboration, and acceptable.

### 07 Deployment View
* ✅ Complete and accurate, including infrastructure levels 1/2.
* ⚠️ "production environment" → "**istehsal** (production) mühiti". "İstehsal" mainly means *manufacturing/industrial production*. In Azerbaijani IT usage, "istismar mühiti" or simply "prod mühiti" may sound more natural. Suggestion only; the parenthesised "(production)" keeps the meaning clear.
* ⚠️ "development environment" → "**tərtibat** mühiti". See terminology note.

### 08 Cross-cutting Concepts
* ✅ Complete and accurate. "DO NOT ATTEMPT" → "ÇALIŞMAYIN" keeps the emphasis (upper case), which is good.

### 09 Architecture Decisions
* ✅ Complete and accurate. The ADR link text "Documenting Architecture Decisions" is left in English on purpose; it is the title of the cited blog post. That is fine.

### 10 Quality Requirements
* ✅ Complete and accurate, including short form (Q42) and long form (SEI) scenario fields.
* ✅ The book title "Software Architecture in Practice" is kept in English and "4th Edition" is translated as "4-cü nəşr". Good.
* ✅ "Quality Attribute Utility Tree" is kept in English as a term. Good.

### 11 Risks and Technical Debts
* ✅ Complete and accurate.
* 👍 EN says "…overall risk analysis and **measurement planning**". That is a known Germanism (from *Maßnahmenplanung*, i.e. planning of *measures/countermeasures*). The AZ text correctly says "tədbirlərin planlaşdırılması" (planning of measures). Good catch by the translator.

### 12 Glossary
* ✅ Complete and accurate. "Terminlər lüğəti" is a good title.

### about-arc42.adoc
* ✅ Correct. The rendered line reads "Şablon versiyası 9.0-AZ. (AsciiDoc versiyası əsasında), oktyabr 2026".

---

## 3. Terminology (for a native-speaker check)

These are consistency and wording remarks, not errors.

| EN term | AZ used | Remark |
|---|---|---|
| architecture | memarlıq (22×) | Used consistently. Native Azerbaijani term; "arxitektura" is also common in IT texts. Either is fine. **Keep as is**, since it is consistent. |
| building block | tikinti bloku (47×) | Literal ("construction block"), like the German "Baustein", and used consistently. OK. |
| development (team / environment) | **tərtibat** (3×) | ⚠️ Inconsistent with "development (process)" = **işlənib hazırlanma** (7×). Both are valid Azerbaijani IT terms, but a reader may wonder whether they mean different things. Suggest picking one, e.g. "işlənib hazırlanma komandası/mühiti", or keeping "tərtibat" everywhere. |
| production environment | istehsal mühiti | See ch. 07 remark. |
| layers | laylar | Possibly "qatlar". See ch. 05 remark. |
| design (decisions) / design pattern | layihələndirmə / dizayn patterni | OK. "dizayn patterni" is the established loan term. |
| implementation | reallaşdırma | Used consistently. OK. |
| stakeholders | maraqlı tərəflər | Used consistently. OK. |
| cross-cutting concepts | kəsişən konsepsiyalar | Used consistently. OK. |

---

## 4. Summary of requested changes

| # | Severity | Item |
|---|---|---|
| T1 | ✅ fixed (cacba4f) | Added `"AZ"` to `first-commits-per-language.sh` (as done for TR) |
| L1 | optional | Unify "tərtibat" vs. "işlənib hazırlanma" for *development* (ch. 01 line 9, ch. 07 line 18) |
| L2 | optional | Consider "istismar/prod mühiti" instead of "istehsal mühiti" (ch. 07 line 18) |
| L3 | optional | Consider "qatlar" instead of "laylar" (ch. 05 line 12) |
| T2 | follow-up (other repo) | Add `AZ: 'Azərbaycanca'` to `languageNames` in arc42-generator |

No blocking issues found. This is a careful, complete translation.
