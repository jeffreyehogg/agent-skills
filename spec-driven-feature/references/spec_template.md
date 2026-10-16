# Feature Specification: [Feature Name]

- **Status:** Draft / Pending Review / Approved / In Progress / Completed
- **Target Completion Date:** YYYY-MM-DD
- **Author/Lead:** [Agent / Architect]

---

## 1. Objective & Success Metrics
- **Problem Statement:** What user problem or technical gap are we solving?
- **Success Criteria:** How do we deterministically verify that this feature works as intended?
- **Explicit Non-Goals:** What is intentionally out of scope for this change?

---

## 2. Data Contracts & Architecture

### Data Models & Schemas
```typescript
// Define key data contracts, Zod schemas, or DB column additions
export interface NewFeaturePayload {
  id: string;
  name: string;
  enabled: boolean;
}
```

### API Endpoints / Function Signatures
| Method / Function | Path / Module | Input | Output | Auth Required |
| :--- | :--- | :--- | :--- | :--- |
| `POST` | `/api/v1/features` | `NewFeaturePayload` | `{ id: string }` | Yes |

---

## 3. File Modification Boundary Matrix

| Action | File Path | Scope of Change |
| :--- | :--- | :--- |
| **Create** | `src/features/new-feature.ts` | Core business logic & helpers |
| **Create** | `tests/unit/new-feature.test.ts` | Unit test suite covering happy & edge cases |
| **Modify** | `src/routes/index.ts` | Mount new router handler |
| **Forbidden** | `src/auth/*` | Do NOT alter authentication middleware |

---

## 4. Implementation Checklist
- [ ] Task 1: Create data schemas and migration (if needed).
- [ ] Task 2: Implement core domain logic.
- [ ] Task 3: Write comprehensive unit tests.
- [ ] Task 4: Expose API route or UI components.
- [ ] Task 5: Execute deterministic test suite and verify 0 regressions.

---

## 5. Verification Protocol
- **Test Command:** `npm test -- new-feature.test.ts`
- **Lint & Typecheck:** `npm run typecheck && npm run lint`
- **Edge Cases Tested:**
  - Empty or malformed inputs.
  - Network failure / timeout handling.
  - Authorization / permission denial.
