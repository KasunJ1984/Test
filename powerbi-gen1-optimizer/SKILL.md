---
name: powerbi-gen1-optimizer
description: Expert Power BI Gen1 M Query optimization for maximum query folding performance. Use when users need to optimize Gen1 dataflows, improve query performance, analyze transformation steps, handle enterprise-scale dataflows with hundreds of steps, or need business-friendly dataflow documentation. Supports single dataflows and multiple connected dataflows (merged, appended, referenced).
---

# Power BI Gen1 M Query Optimizer

Optimize Power BI Gen1 dataflow M Query code for maximum query folding performance while maintaining 100% output integrity.

## Core Process

### 1. Analyze
- Examine each transformation step in sequence
- Identify query folding opportunities for database-side processing
- Assess current optimization state
- Warn users about processing time for enterprise-scale dataflows (100+ steps)

### 2. Optimize
- Apply strict code optimization prioritizing performance over readability
- Push maximum transformation steps to database side via query folding
- Maintain Gen1 compatibility (no Gen2-specific features)
- Preserve all column extractions, formats, and transformations
- Work within existing dataflow structure (no architectural changes)

### 3. Validate
- Verify 100% output match between original and optimized dataflows
- Confirm column structure preservation (names, types, formats)

## Optimization Philosophy

**Performance First**: Optimize for query folding and speed, not code readability.

**Gen1 Strict**: Maximum backward compatibility. No Gen2 features.

**Zero Output Deviation**: Optimized dataflow must produce identical results.

**Work Within Structure**: Code optimization only—no dataflow splitting or architectural changes.

## Advanced Scenarios

### Already-Optimal Code
If code is already optimal:
- Provide detailed analysis explaining why
- Flag optimal sections
- Identify edge case opportunities if any exist

### Custom Connectors
When custom connectors limit query folding:
- Provide achievable optimizations for standard connectors
- Document theoretical improvements for reference
- Work within connector limitations

### Enterprise-Scale Dataflows
For dataflows with 100+ transformation steps:
- Warn about processing time upfront
- Maintain optimization quality regardless of size
- Use adaptive complexity detection

## Output Requirements

Provide three deliverables:

### 1. Optimized M Query Code
Complete, runnable Gen1-compatible dataflow with maximum query folding.

### 2. Performance Analysis
Quantitative metrics:
- Estimated processing time reduction percentage
- Query folding improvement metrics
- Performance impact quantification

### 3. Business-Friendly Description
For accountant/business users (suitable for Power BI dataflow documentation):
- Simple point-form transformation summary
- Data extraction → transformation → final output flow
- Human-readable description in plain language
- High-level business impact explanation

## Reference Materials

For detailed M Query optimization patterns and Gen1 limitations, see:
- **[references/optimization-patterns.md](references/optimization-patterns.md)**: Common anti-patterns and query folding techniques
- **[references/gen1-limitations.md](references/gen1-limitations.md)**: Known Gen1 connector limitations and workarounds

## Success Criteria

1. Optimized dataflow produces identical output to original
2. Maximum query folding achieved where technically possible
3. Quantifiable performance improvements documented
4. Business-readable documentation provided
5. Gen1 compatibility maintained throughout
