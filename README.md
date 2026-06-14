# SYSMOD Library for SysML v2

A SysML v2 library implementing the [SYSMOD methodology](https://oose.de) for Model-Based Systems Engineering (MBSE).

## What's in the Library

The library provides ready-to-use SysML v2 definitions for the core SYSMOD concepts:

- **Project** — root container linking all engineering artifacts (brownfield context, stakeholders, problem statement, system idea, requirements, solution, functional/logical/product architecture)
- **System Context** — actors, system of interest (black box + white box), actor–system interfaces, and use cases
- **Stakeholders** — `ExtendedStakeholder` with risk/effort/priority attributes and stakeholder categories
- **Requirements** — `ExtendedRequirement` with obligation, stability, and motivation attributes
- **Semantic metadata** — shorthand keywords (`#project`, `#systemContext`, `#extendedStakeholder`, …) for cleaner model notation
- **AI metadata** — built-in prompts and questions for AI-assisted model creation (compatible with MCP-based agent workflows)

## Quick Sheets

> Note: This is work in progress and incomplete!

Six visual reference cards covering the SYSMOD workflow steps are included in the [`SYSMOD Quick Sheets`](SYSMOD%20Quick%20Sheets/) folder:

1. The Problem Statement
2. The Brownfield Architecture
3. The Stakeholders and their Needs
4. The System Idea
5. The Use Cases
6. The System Requirements

## Getting Started

Import the library into your SysML v2 model:

```sysml
package MyProject {
    public import SYSMOD::*;

    occurrence def <project> MyProject :> Project {
        // redefine inherited parts to specialize for your project
    }
}
```

See [`examples/DeliveryDrone-Model.sysml`](examples/DeliveryDrone-Model.sysml) for a complete worked example covering project definition, brownfield context, stakeholders, and problem statement.

## Repository Structure

```
SYSMOD.sysml                  # The SYSMOD library
examples/
  DeliveryDrone-Model.sysml   # Example model
  DeliveryDrone-StakeholderPriorityMap.svg
SYSMOD Quick Sheets/          # Visual reference cards (SVG)
models/
  Cameo-SYSMOD.mdszip         # Reference model for Cameo Systems Modeler
```

## Contributing

Contributions are welcome — please submit issues or pull requests.

## License

Apache License 2.0 — see [LICENSE](LICENSE) for details.

## Contact

For feedback or questions: [tim@mbse4u.com](mailto:tim@mbse4u.com)