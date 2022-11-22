# Governance Policy Specification

A specification model for computational data governance policies inspired from [ADR](https://adr.github.io/) (Architectural Decision Record). Its goal is to enable the creation of version-controlled policies that include:

- a **policy lifecycle** state
- a **policy history** state
- the policy **title**
- the **context**
- the **decision**
- the **consequences** and accepted trade-offs

These are basically in common with the ADR model. In this specification, that aims to perfectly tailor the Data Mesh context, some more sections are added:

- an **implementation steward**
- where the **policy becomes computational**

Having documented and version controlled policies, is also useful to keep track of the activities of the governance team (federated governance team, in the case of Data Mesh).

Let's deep dive into each section.

## Policy Lifecycle State
This can be as simple as a label tracking down the **lifecycle** state of a policy. Common states are:

- `DRAFT`, when a policy is being developed and still needs to be formally approved, or has been submitted for approval;
- `APPROVED`, when a policy has been formally approved: this makes it actionable and a reference for the overall governance;
- `REJECTED`, when a policy has been formally rejected (after the approval process).

In the [template](adr_template.md) file, some pre-compiled web-rendered labels are provided.

## Policy History State
This can be as simple as a label tracking down the **history** state of a policy. Common states are:

- `NEW`, when a policy is created for the first time, it doesn't amend or supercede an existing one;
- `AMENDS` or `AMENDED`, when an approved policy amends (or is amended by) another existing policy;
- `SUPERCEDES` or `SUPERCEDED`, when a policy supercedes (or is superceded by) another existing policy;
- `DEPRECATED`, when a policy ceases to be valid/applied and no other one amends or supercedes it.

**NOTE:** in the case of amend* and supercede* the related policy should be linked.

In the [template](adr_template.md) file, some pre-compiled web-rendered labels are provided.

## Context
This section describes what is the context where the policy applies to (and why).

## Decision
The decision the policies aims to apply.

### Lifecycle
Declare what changes to the metadata (or anything else) would be considered BREAKING and what NOT BREAKING. This is important to implement automations at platform level and create a robust change management process based on trust between data producers and consumers.

## Consequences and accepted trade-offs
What we accept to happen while the policy is applied including pros (improvements) and cons (impacts, rework, new accountabilities or requirements). Since there's no "universally optimal decision", the policy should also report the trade-offs the organization is going to accept with this policy, which could mean in some scenario making explicit the accumulated tech debt (a note on tech debt: this is usually hidden and hard to track. When making it explicit, it easier to measure/keep track to the overall tech debt, system quality in terms of architecture and behaviour, etc.).

## Implementation Steward
Who is supposed to take care of the implementation (we talk about implementation since the policy, like in the context of Data Mesh, is supposed to become as more "computational" as possibile, thus leading to automate the data management practice, probably with the help of a backing platform). It can also be the role with the accountability to follow the application of such policy.

## Where the policy becomes computational
Which are the specific points in the architecture, the platform, the system, the context, etc where this policy (and its checks, if any) are implemented so to become an _automation_ (thus becoming _"computational"_). This is split into **LOCAL** and **GLOBAL** policy: while the former assess the context of a policy locally implemented/applied/verified (in the context of Data Mesh, this could be a Data Product Owner wanting to calculate and measure the Data Quality over data at rest in the DP's output ports, is specific to the context and does not affect others, like domains or DP owners), the latter is for policies globally applied (e.g. the S3 bucket provisionable for Data Product's output ports can only be in `eu-central-1` AWS region). Furthermore, the LOCAL application is supposed to be applied/verified at runtime (in the case of a Data Product, when the DP has been already created or is going to), while the GLOBAL one addresses checks at deploy time (an example of application can targets deployments of Data Products modeled as [Data Product Specification](https://github.com/agile-lab-dev/Data-Product-Specification)). If using a descriptive modelling languange, a metadata validation policy-as-code file can be provided (probably it will be integrated in the platform, e.g. using CUE lang for YAML).

-----------

### How to make use of this policy model?

An example of usage includes:
1. setting up a git repo
2. (optional) installing a tool so that every contributor follows the same process (which is a good idea to document in the repo itself), e.g. [adr-tools](https://github.com/npryce/adr-tools)
3. keep track of governance policies to create by leveraging the issue tracking system of the git repo, making use of all the features the issue tracking system provides (like labels, epics, etc ...)
4. work out the policies issues, creating the related mere requests
5. implement the policy, leveraging the [template](adr_template.md) here provided
6. provide a metadata model, example, and validation (policy-as-code) file
7. when the policy is ready, merge it (according to the governance process) and make it executive.

An important **note** on points 3, 4, 5, 6, and 7: in the case of **Data Mesh**, the federated governance team (which include SME, Subject Matter Experts, coming from all the most meaningful units of the company like engineering, security, compliance, as well as domains' representative spokespersons) should collaborate in their own perimeters of expertise. Probably, a Federated Governance Team "core members" group (e.g. the Platform team) could take care of the final merge of the policies as in point 6, thus also acting as a final validation.

The policies can (will) evolve over time during the data platform lifecycle. In order to account and embrace the change, it's suggested to create a folder for every ADR and name the ADR (policy) file with the notation: `xxxx-policy-content-or-decision.md` (in case the Markdown format is used for the policy document, xxxx is a monothonically increasing id that tracks the policy's evolutions/version). Generally speaking of ADRs, multiple different ADRs (addressing different decisions of a same area of application) are supposed to cohexist within the same folder: in the case of governance policies this could lead to misunderstanding of the incremental sequence id, but still grouping into nested folders/subfolders can be used.

When evolving an existing policy, is important to take care of the policy lifecycle state, expecially when amending or superceding existing policies. By using the 1:1 ration for folder:policy, then it's straightforward to identify the most recent (and supposedly currently valid) policy for every context.

### Example

A pretty exhaustive example policy and related metadata + policy-as-code validation files is provided in the [example](example/data-mesh/data-product/output-port/files) folder. In this example, the specific architectural decision (a.k.a. now as ADR or governance policy) is provided to describe how an *Output Port* of type "FILES" should be defined, provisioned, configured, described, validated.
The folder contains 3 files:
- [0001-data-product-output-port-files.md](example/data-mesh/data-product/output-port/files/0001-data-product-output-port-files.md) containing the descriptive ADR (as implementation of the [template](adr_template.md)). In this example, we took inspiration from the Financial Services world (in terms of constraints);
- [0001-data-product-output-port-files.cue](example/data-mesh/data-product/output-port/files/0001-data-product-output-port-files.cue) containing the [CUE lang](https://cuelang.org) policy-as-code validation file, that supposedly will be integrated in the Data Mesh self-service infrastructure-as-a-platform;
- [0001-data-product-output-port-files-example.yaml](example/data-mesh/data-product/output-port/files/0001-data-product-output-port-files-example.yaml) containing an example of metadata specification with real world values.

The ADR versioning assumes this is the first policy created to address this governance topic.

The policy metadata can be validated with the policy-as-code file using the CUE CLI (if installed): 

```bash
cue vet example/data-mesh/data-product/output-port/files/0001-data-product-output-port-files-example.yaml example/data-mesh/data-product/output-port/files/0001-data-product-output-port-files.cue
```

## Coming next 

Future releases could include:
- an organizational process for the governance meetings
- a workflow to manage the policies lifecycle
- more examples

## License

The proposed approach, template, examples and policy-as-code files are shared with the community under the [APACHE 2.0](LICENSE) LICENSE.
