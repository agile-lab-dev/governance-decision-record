//
// To validate the YAML run:
//
// cue vet <path-to/policy-file-example>.yaml <path-to/validation-code-file>.cue
//

#OM_DataType:   string & =~"(?i)^(NUMBER|TINYINT|SMALLINT|INT|BIGINT|BYTEINT|BYTES|FLOAT|DOUBLE|DECIMAL|NUMERIC|TIMESTAMP|TIME|DATE|DATETIME|INTERVAL|STRING|MEDIUMTEXT|TEXT|CHAR|VARCHAR|BOOLEAN|BINARY|VARBINARY|ARRAY|BLOB|LONGBLOB|MEDIUMBLOB|MAP|STRUCT|UNION|SET|GEOGRAPHY|ENUM|JSON)$"
#OM_Constraint: string & =~"(?i)^(NULL|NOT_NULL|UNIQUE|PRIMARY_KEY)$"
#Version:       string & =~"^[0-9]+\\.[0-9]+\\..+$"
#Id:            string & =~"^[a-zA-Z0-9:._-]+$"
#DataProductId: #Id
#ComponentId:   #Id
#URL:           string & =~"^https?://[a-zA-Z0-9@:%._~#=&/?]*$"

#OM_TableData: {
	columns: [... string]
	rows: [... [...]]
}

#OM_Tag: {
	tagFQN:       string
	description?: string | null
	source:       string & =~"(?i)^(Tag|Glossary)$"
	labelType:    string & =~"(?i)^(Manual|Propagated|Automated|Derived)$"
	state:        string & =~"(?i)^(Suggested|Confirmed)$"
	href?:        string | null
}

#OM_Column: {
	name:     string
	dataType: #OM_DataType
	if dataType =~ "(?i)^(ARRAY)$" {
		arrayDataType: #OM_DataType
	}
	if dataType =~ "(?i)^(CHAR|VARCHAR|BINARY|VARBINARY)$" {
		dataLength: number
	}
	dataTypeDisplay?:    string | null
	description?:        string | null
	fullyQualifiedName?: string | null
	tags?: [... #OM_Tag]
	constraint?:      #OM_Constraint | null
	ordinalPosition?: number | null
	if dataType =~ "(?i)^(JSON)$" {
		jsonSchema: string
	}
	if dataType =~ "(?i)^(MAP|STRUCT|UNION)$" {
		children: [... #OM_Column]
	}
}

#DataContract: {
	schema: [... #OM_Column]
	serializationFormat: string & =~"(?i)^(parquet|deltalake|iceberg)$"
	compressionCodec:    string & =~"(?i)^(snappy|gzip)$"
	biTempBusinessTs:    string
	biTempWriteTs:       string
	termsAndConditions:  string
	partitionedBy?: [... string]
	endpoint?: string | null
	SLA:       #SLA
}

#SLA: {
	intervalOfChange: string
	timeliness:       string
	upTime:           number
}

#OutputPortSpecificFiles: {
	// Mandatory
	resourceGroup:  =~"^.{2,}$"
	storageAccount: =~"^[a-z0-9]{3,24}$"
	container:      =~"^[a-z0-9-]{3,63}$"
	directory?:      [... string]

	performance:    *"Standard" | "Premium"
	geoReplication: *"GRS" | "LRS"
	accessTier:     *"Hot" | "Cool"

	// Fixed
	region:                            "germanywestcentral"
	accountKind:                       "StorageV2"
	shared_access_key_enabled:         false
	infrastructure_encryption_enabled: true
	versioning_enabled:                true | false
	...
}

#Component: {
	id:                       #ComponentId
	name:                     string & =~"^[a-z0-9-]{3,40}$"
	description:              string & =~"^\\W*(?:\\w+\\b\\W*){10,200}$"
	version:                  #Version
	platform:       string & "Azure"
	technology:     string & "ADLSgen2"
	outputPortType: string & "Files"
	kind:           string & =~"(?i)^(outputport|_)$"
	tags?: [... #OM_Tag]
	dataContract: #DataContract
	sampleData:   #OM_TableData
	specific:     #OutputPortSpecificFiles
}

components: [#Component, ...#Component]
