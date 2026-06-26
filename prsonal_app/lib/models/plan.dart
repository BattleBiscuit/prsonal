// Plan model — pure Dart, no Flutter/Drift imports.

enum PlanStatus { active, archived }

/// The status assigned to a newly created plan.
const PlanStatus defaultPlanStatus = PlanStatus.active;

/// Returns true when [name] is non-empty after trimming whitespace.
bool validatePlanName(String name) => name.trim().isNotEmpty;
