# Data Product Output Port Files

![NEW](https://img.shields.io/badge/HISTORY-NEW-brightgreen?style=flat&logo=CodeReview)
![APPROVED](https://img.shields.io/badge/LIFECYCLE-APPROVED-brightgreen?style=flat&logo=StackShare)

## Context

One of the accepted output port types for Data Products is "FILES", that usually includes:

- the storage technology and related configurations
- the serialization format
- the compression codec
- lifecycle information (cost management, ownership, ...)
- security and compliance constraints
- data contract

From an architectural perspective, we're talking about files on a storage system/container (HDFS, Ozone, MinIO, S3,
ADLSgen2, etc ..).

## Decision

Our company must comply to the Financial Services regulations for EMEA, thus here follow what Data Products developers
can/should/must require via the platform:

- **STORAGE SPEC**:
    - technology: Storage account with Azure Data Lake storage gen2 (`StorageV2`)
    - region: due to regulatory constraints, the only allowed region is Germany West Central (`germanywestcentral`)
    - encryption: `true` or `false`, depending if a _PII_ tag is assigned
    - public access: `none`
    - performance: `Standard` or `Premium`
    - access tier: `Hot` or `Cool`
    - redundancy: `GRS` or `ZRS`
    - tags: `<domain>`, `<subdomain>` (if any), `dp`, `<environment>`
    - shared access key enabled: `false`, always mandatory
- **STORAGE STRUCTURE**:
    - different storage accounts for different _company_, _domains_, _subdomains_, _environments_, _usage_ (`op` as for
      Output Port). Storage Account name should be `acmedp<domainsubdomain><environment>op`, no
      spaces/hyphens/underscore. The storage account must be part of a resource group (1 per domain).
        - different containers for different data products. Container name should
          be `<domainsubdomain>-<data-product-name>`.
            - different directories for different **major** versions (assuming Semantic Versioning is leveraged) and
              different output ports of the data product
                - different subdirectories for different output ports
                    - different subdirectories for different partitions/buckets depending on the partitioning/bucketing
                      strategy
- **FORMAT**:
    - serialization: `parquet`, `iceberg`, or `deltalake`
    - compression codec: `snappy`, `gzip`, or `none`
    - partitionedBy: [list of partition keys]
- **DATA CONTRACT** should include:
    - schema (according to
      the [OpenMetadata](https://docs.open-metadata.org/metadata-standard/schemas/entities/table#column) specification)
    - serialization format
    - compression codec
    - bi-temporality business time reference
    - bi-temporality technical time reference
    - SLA/SLO

Not all of these properties must specified in the specification, since the mandatory ones will be applied as default
behaviours by the related specific provisioner.

Here follow the specific metadata:

```yaml
# [ inside an output port component object ]

id: <a unique id> # according to platform's standards
name: <dp name> # minimum 3, max 30 chars with hyphens
platform: Azure # mandatory
technology: ADLSgen2 #mandatory
outputPortType: Files # mandatory
kind: outputport # mandatory
description: <a long and detailed description> #minimum 10, maximum 200 words
version: <value> # major.minor.patch
dataContract:
  serializationFormat: parquet # or "deltalake", or "iceberg"
    compressionCodec: snappy # or "none" or "gzip"
    partitionedBy: [ <key1>, <key2> ] # array of partition keys
    schema: { ... } # according to OpenMetadata spec, including fields tagging for PII
    SLA:
      intervalOfChange: <value> # descriptive, e.g. "1 hour"
      timeliness: <value> # descriptive, e.g. "10 minutes"
      upTime: <value> # like 99.9
    termsAndConditions: <a descriptive condition, like for confidential use>
    endpoint: <URL>
    biTempBusinessTs: businessTs # according to the schema
    biTempWriteTs: writeTs # according to the schema
    tags: [] # array of Tags as per the OpenMetadata spec
specific:
  subscription: "1234567-1234-1234-1234-12345567788"  # azure subscription id
  resourceGroup: cards.data_products # azure resource group into that subscription in the form of domain.datapproduct_name
  storageAccount: acmecardsdpsvilop # azure storage account id
  container: cards-ccfrauds # container into that storage account in the form of domain-dataproduct_name
  shared_access_key_enabled: false # true | false
  infrastructure_encryption_enabled: true # true if PII | false otherwise
  versioning_enabled: true # mandatory
  accountKind: StorageV2 # mandatory
  directory: /1 # optional
  geoReplication: GRS # or ZRS
  accessTier: Hot # or Cool
  performance: Premium # or Standard
  region: germanywestcentral # mandatory
```

The resulting specification (NOTE: here we reference
the [Data Product Specification](https://github.com/agile-lab-dev/Data-Product-Specification/blob/main/example.yaml), in
particular focused on the Output Port component), are reported in the form of example
in [0001-data-product-output-port-files-example.yaml](0001-data-product-output-port-files-example.yaml).

### LIFECYCLE

The following changes are considered _BREAKING_:

- schema change in case no out-of-the-box backward compatibility is guaranteed
- bi-temporality fields changes and in general data contract
- serialization format
- compression codec

In the case of a breaking change, the **major** version of the Data Product should change (e.g. 1.x.y -> 2.0.0)

All the other changes are considered _NOT BREAKING_ and should lead to minor or patch Data Product's version change.

## Consequences and accepted trade-offs

Domains must comply to this serialization format and compression codec. In case of major version change, data product
owners should inform all the consumers, documenting the changelog and migration plan (including the time period during
which both old and new versions are kept in parallel so to avoid breaking changes at the consumers side). Obviously,
this implies higher maintenance costs for the DP owner.

Due to regulatory reasons, there's only one Azure region admitted.

Premium tier is more expensive, but the massive layout of the data product requires for analytical use cases this level
of performance.

## Implementation Steward

The Data Product Owner for requesting the proper provisioning.
The Platform Team for implementing the governance policy-as-code on the platform.

## Where the policy becomes computational

- **LOCAL POLICY**: the Data Product Owner should clone and reuse the template for the FILES output port on ADLSgen2
- **GLOBAL POLICY**: the Platform Team should implement an automated validation of the data product specification in the
  section specific to the output port's metadata at deploy-time (while requesting the infrastructure provisioning in
  self-service fashion), so to detect non-compliant requirements along with breaking changes.
    - policy code: [0001-data-product-output-port-files.cue](0001-data-product-output-port-files.cue)
