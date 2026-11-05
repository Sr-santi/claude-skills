# Reference library

Sources already checked and used on a page. Each entry: what it supports and the number or idea to quote. Add new ones at the end of their group after checking them (link opens, number matches the source).

## Retrieval and search

- **Reciprocal Rank Fusion.** Cormack, Clarke & Büttcher, SIGIR 2009. https://plg.uwaterloo.ca/~gvcormac/cormacksigir09-rrf.pdf
  Score = Σ 1/(k + rank), k = 60. A document in both lists always beats one in a single list at the same ranks, whatever k is.
- **Azure AI Search hybrid ranking.** https://learn.microsoft.com/azure/search/hybrid-search-ranking
  RRF with k = 60 as the default; "a small value like 60" performed best.
- **Contextual Retrieval.** Anthropic, 2024. https://www.anthropic.com/engineering/contextual-retrieval
  Add context to each chunk before embedding and BM25. Top-20 retrieval failures 5.7% → 2.9% (−49%); −67% with a reranker. Counter-approach to filtering chunks out.
  Critique (measures only the "golden chunk" in top-k): https://medium.com/almond-ai/responding-to-anthropics-contextual-retrieval-for-rag-apps-why-context-is-not-all-you-need-af503985aa55
- **pgvector.** https://github.com/pgvector/pgvector
  Exact scan is the default and correct; HNSW/IVFFlat trade recall for speed when rows grow.

## Evaluating LLM agents

- **LLM-as-a-judge.** Zheng et al. 2023, "Judging LLM-as-a-Judge with MT-Bench and Chatbot Arena". https://arxiv.org/abs/2306.05685
  Strong judges agree with humans about 80% of the time, the same level as human–human; position, verbosity and self-enhancement biases.
- **τ-bench.** Yao, Shinn, Razavi, Narasimhan 2024. https://arxiv.org/abs/2406.12045
  Simulated user + tools + policy; pass^k = success on all k trials. GPT-4o retail pass^1 ≈ 60%, pass^8 < 25%. One run per case overstates reliability.
- **Error analysis before evals.** Hamel Husain, "Your AI product needs evals". https://hamel.dev/blog/posts/evals/
  Look at real traces, sort failures into causes, then fix and test.
- **Experiment comparison on one dataset and scorer.** promptfoo (https://www.promptfoo.dev/docs/intro/), LangSmith (https://docs.smith.langchain.com/), Braintrust (https://www.braintrust.dev/docs).
  Compare versions only on the same cases and the same scorer.

## Data over time

- **Bitemporal history.** Martin Fowler. https://martinfowler.com/articles/bitemporal-history.html
  Keep "when it was true" (valid/actual time) apart from "when we recorded it" (record time); mixing them gives wrong "as of" answers.

## Statistics for small samples

- **Wilson score interval.** https://en.wikipedia.org/wiki/Binomial_proportion_confidence_interval#Wilson_score_interval
  Use for pass rates from small n; 16/20 passing → 58%–92%. Script: `scripts/power.py`.
