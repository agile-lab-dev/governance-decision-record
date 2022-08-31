# Governance Policy Specification

A specification model for computational governance policies inspired from [ADR](https://adr.github.io/) (Architectural Decision Record). It's goal is to enable the creation of version-controlled policies that include:

- a **policy lifecycle** state
- the **context**
- the **decision**
- the **consequences** and accepted trade-offs

These are in common with the ADR model. In this specification, that aims to perfectly tailor the Data Mesh context, some more sections are added:

- an **implementation steward**
- where the **policy becomes computational**

Having documented and version controlled policies, is also useful to keep track of the activities of the governance team (federated governance team, in the case of Data Mesh).

Let's deep dive into each section.

## Policy Lifecycle State
This can be as simple as a label that tracks down the state of the polices. Common states are:
- `NEW`, when a new policy is created and the same context/decision has never been addressed in other existing policies;
- `AMENDS xxxx` or `AMENDED by yyyy`, when a policy amends (or is amended by) another existing policy
- `SUPERCEDES xxxx` or `SUPERCEDED by yyyy`, when a policy supercedes (or is superceded by) another existing policy
- `DEPRECATED`, when a policy ceases to be valid/applied and no other one amends or supercedes it.

## Context
This section describes what is the context where the policies applies to (and why).

## Decision
The decision the policies aims to apply.

## Consequences and accepted trade-offs
What we accept to happen while the policy is applied including pros (improvements) and cons (impacts, rework, new accountabilities or requirements). Since there's no "universally optimal decision", the policy should also report the trade-offs the organization is going to accept with this policy, which could mean in some scenario making explicit the accumulated tech debt (a note on tech debt: this is usually hidden and hard to track. When making it explicit, it easier to measure/keep track to the overall tech debt, system quality in terms of architecture and behaviour, etc.).

## Implementation Steward
Who is supposed to take care of the implementation (we talk about implementation since the policy, like in the context of Data Mesh, is supposed to become as more "computational" as possibile, thus leading to automate the data management practice, probably with the help of a backing platform). It can also be the role with the accountability to follow the application of such policy.

## Where the policy becomes computational
Which are the specific points in the architecture, the platform, the system, the context, etc where this policy (and its checks, if any) are implemented so to become an _automation_ (thus becoming _"computational"_). This is split into **LOCAL** and **GLOBAL** policy: while the former assess the context of a policy locally implemented/applied/verified (in the context of Data Mesh, this could be a Data Product Owner wanting to calculate and measure the Data Quality over data at rest in the DP's output ports, is specific to the context and does not affect others, like domains or DP owners), the latter is for policies globally applied (e.g. the S3 bucket provisionable for Data Product's output ports can only be in `eu-central-1` AWS region). Furthermore, the LOCAL application is supposed to be applied/verified at runtime (in the case of a Data Product, when the DP has been already created or is going to), while the GLOBAL one addresses checks at deploy time (an example of application can targets deployments of Data Products modeled as [Data Product Specification](https://github.com/agile-lab-dev/Data-Product-Specification))

-----------

### How to make use of this policy model?

An example of usage includes:
1. setting up a git repo
2. (optional) installing a tool so that every contributor follows the same process (which is a good idea to document in the repo itself), e.g. [adr-tools](https://github.com/npryce/adr-tools)
3. keep track of governance policies to create by leveraging the issue tracking system of the git repo, making use of all the features the issue tracking system provides (like labels, epics, etc ...)
4. work out the policies issues, creating the related mere requests
5. implement the policy, leveraging the template here provided
6. when the policy is ready, merge it and make it executive

An important **note** on points 3, 4, 5, and 6: in the case of Data Mesh, the federated governance team (which include SME, Subject Matter Experts, coming from all the most meaningful units of the company like engineering, security, compliance, as well as domains' representative spokespersons) should collaborate in their own perimeters of expertise. Probably, a Federated Governance Team "core members" group (e.g. the Platform team) could take care of the final merge of the policies as in point 6, thus also acting as a final validation.

The policies can (will) evolve over time during the data platform lifecycle. In order to account and embrace the change, it's suggested to create a folder for every ADR and name the ADR (policy) file with the notation: `xxxx-policy-content-or-decision.md` (in case the Markdown format is used for the policy document, xxxx is a monothonically increasing id that tracks the policy's evolutions/version). Generally speaking of ADRs, multiple different ADRs (addressing different decisions of a same area of application) are supposed to cohexist within the same folder: in the case of governance policies this could lead to misunderstanding of the incremental sequence id, but still grouping into nested folders/subfolders can be used.

When evolving an existing policy, is important to take care of the policy lifecycle state, expecially when amending or superceding existing policies. By using the 1:1 ration for folder:policy, then it's straightforward to identify the most recent (and supposedly currently valid) policy for every context.

