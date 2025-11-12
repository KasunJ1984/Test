# M Query Optimization Patterns

Reference guide for common optimization patterns, anti-patterns, and query folding techniques in Power BI Gen1 dataflows.

## Query Folding Fundamentals

**Query Folding** = Pushing transformation steps to the database side, generating optimized SQL queries instead of loading data into Power BI memory for transformation.

**Benefits**: 10-100x performance improvements by leveraging database query engines.

**Check Query Folding**: Right-click a step in Power Query Editor → "View Native Query". If available, that step folds.

## Common Anti-Patterns & Fixes

### 1. Type Conversion After Operations
**Anti-Pattern**:
```m
// Breaking query folding by changing types mid-stream
= Table.AddColumn(Source, "Total", each [Quantity] * [Price])
= Table.TransformColumnTypes(#"Added Custom", {{"Total", type number}})
```

**Optimized**:
```m
// Type column immediately after source
= Table.TransformColumnTypes(Source, {{"Quantity", Int64.Type}, {"Price", Currency.Type}})
= Table.AddColumn(#"Changed Type", "Total", each [Quantity] * [Price], Currency.Type)
```

### 2. Text.Contains Instead of Native Filters
**Anti-Pattern**:
```m
// Using M functions that don't fold
= Table.SelectRows(Source, each Text.Contains([Category], "Electronics"))
```

**Optimized**:
```m
// Use native filtering that folds to SQL WHERE clause
= Table.SelectRows(Source, each [Category] = "Electronics")
// Or for partial matches:
= Table.SelectRows(Source, each Text.StartsWith([Category], "Elec"))
```

### 3. Custom Column Logic That Doesn't Fold
**Anti-Pattern**:
```m
// Complex logic preventing folding
= Table.AddColumn(Source, "Status", each 
    if [Amount] > 1000 and Text.Length([Code]) > 5 
    then "Large" 
    else "Small")
```

**Optimized**:
```m
// Break into foldable steps
= Table.AddColumn(Source, "IsLarge", each [Amount] > 1000, type logical)
= Table.AddColumn(#"Added IsLarge", "CodeLength", each Text.Length([Code]), Int64.Type)
= Table.AddColumn(#"Added CodeLength", "Status", each 
    if [IsLarge] and [CodeLength] > 5 
    then "Large" 
    else "Small", type text)
```

### 4. Filtering After Merging
**Anti-Pattern**:
```m
= Table.NestedJoin(Table1, {"ID"}, Table2, {"ID"}, "Table2", JoinKind.LeftOuter)
= Table.ExpandTableColumn(#"Merged Queries", "Table2", {"Status"})
= Table.SelectRows(#"Expanded Table2", each [Status] = "Active")
```

**Optimized**:
```m
// Filter BEFORE merging
#"Filtered Table2" = Table.SelectRows(Table2, each [Status] = "Active")
= Table.NestedJoin(Table1, {"ID"}, #"Filtered Table2", {"ID"}, "Table2", JoinKind.LeftOuter)
= Table.ExpandTableColumn(#"Merged Queries", "Table2", {"Status"})
```

### 5. List.Sum/List.Average in Grouped Aggregations
**Anti-Pattern**:
```m
// Using List functions that don't fold
= Table.Group(Source, {"Category"}, {
    {"Total", each List.Sum([Amount]), type number}
})
```

**Optimized**:
```m
// Use native aggregation functions
= Table.Group(Source, {"Category"}, {
    {"Total", each List.Sum([Amount]), Currency.Type}
})
// For Gen1, sometimes need to explicitly specify type after grouping
```

### 6. Sorting Before Filtering
**Anti-Pattern**:
```m
// Expensive sort operation before filtering
= Table.Sort(Source, {{"Date", Order.Descending}})
= Table.SelectRows(#"Sorted Rows", each [Amount] > 1000)
```

**Optimized**:
```m
// Filter first to reduce dataset size
= Table.SelectRows(Source, each [Amount] > 1000)
= Table.Sort(#"Filtered Rows", {{"Date", Order.Descending}})
```

### 7. Multiple Column Removals
**Anti-Pattern**:
```m
// Removing columns one at a time
= Table.RemoveColumns(Source, {"Column1"})
= Table.RemoveColumns(#"Removed Columns", {"Column2"})
= Table.RemoveColumns(#"Removed Columns1", {"Column3"})
```

**Optimized**:
```m
// Remove all at once
= Table.RemoveColumns(Source, {"Column1", "Column2", "Column3"})
// Even better - select only needed columns
= Table.SelectColumns(Source, {"ID", "Name", "Amount", "Date"})
```

## Query Folding Preservation Techniques

### Maintain Folding Through Transformations

**Column Selection**:
```m
// Both fold, but SelectColumns is more explicit
Table.SelectColumns(Source, {"Col1", "Col2"})  // Preferred
Table.RemoveColumns(Source, {"Col3", "Col4"})  // Also folds
```

**Native Filtering**:
```m
// All fold to SQL WHERE
Table.SelectRows(Source, each [Amount] > 100)
Table.SelectRows(Source, each [Date] >= #date(2024,1,1))
Table.SelectRows(Source, each [Status] = "Active" and [Type] = "Premium")
```

**Date Operations That Fold**:
```m
// These operations fold
Date.Year([DateColumn])
Date.Month([DateColumn])
Date.Day([DateColumn])
Date.StartOfMonth([DateColumn])
Date.AddDays([DateColumn], 7)
```

**Math Operations That Fold**:
```m
// Simple arithmetic folds
[Quantity] * [Price]
[Revenue] - [Cost]
[Amount] / 100
Number.Round([Value], 2)
```

## Gen1-Specific Optimizations

### Use Proper Data Types Early
```m
// Define types immediately after source
#"Changed Type" = Table.TransformColumnTypes(Source,{
    {"ID", Int64.Type},
    {"Name", type text},
    {"Amount", Currency.Type},
    {"Date", type date},
    {"IsActive", type logical}
})
```

### Leverage Table.Buffer Strategically
```m
// Use Table.Buffer for small lookup tables referenced multiple times
#"Buffered Categories" = Table.Buffer(CategoryTable)
// Don't buffer large fact tables - prevents folding
```

### Avoid DateTime → Date Conversions Mid-Stream
```m
// Convert at source
= Table.TransformColumnTypes(Source, {{"DateTimeColumn", type date}})
// Instead of later:
// = Table.TransformColumns(Source, {{"DateTimeColumn", Date.From}})
```

### Combine Filter Conditions
```m
// Single filter with multiple conditions (folds better)
= Table.SelectRows(Source, each 
    [Status] = "Active" and 
    [Amount] > 1000 and 
    [Date] >= #date(2024,1,1)
)
```

## Performance Measurement

To validate optimization impact:

1. **Query Folding Check**: Right-click each step → "View Native Query"
2. **Execution Time**: Note refresh duration before/after
3. **Row Counts**: Verify identical output with `Table.RowCount()`
4. **Data Profiling**: Use column statistics to verify data integrity

Expected improvements:
- **Simple filtering**: 20-50% reduction
- **Complex transformations**: 50-80% reduction  
- **Large datasets with aggregations**: 70-95% reduction
- **Already-optimal code**: 0-10% reduction

## Tools for Validation

```m
// Add as final step to verify row count matches
= Table.RowCount(FinalTable)

// Check data types preserved
= Table.Schema(FinalTable)

// Validate specific columns
= Table.ColumnNames(FinalTable)
```
