# ie-gen-mets

#### NYU DLTS Intellectual Entity METS XML generator

## Current Status

### *UNDER DEVELOPMENT*
#### WARNING: this code may be converted to a gem at some point in the future


## Usage

#### preconditions:
     
- intellectual entity in directory must adhere to DLTS naming conventions
- exactly one of each of the files must be present
  - mods : [MODS](http://www.loc.gov/standards/mods/) descriptive metadata in a file with suffix ```_mods.xml```
  - marcxml : [MARCXML](http://www.loc.gov/standards/marcxml/) descriptive metadata in a file with suffix ```_marcxml.xml```
  - metsrights : [METSRIGHTS](http://www.loc.gov/standards/rights/METSRights.xsd) rights metadata file with suffix ```metsrights.xml```

#### input:
- object identifier
- "part" strings, in sequential order.
  - a "part" string consists of two components delimited by a ':',
    - the first part is either a [METS](http://www.loc.gov/standards/mets/) mptr string that points to the correct portion of a source entity structMap,
	  or the string 'UNAVAIL', which indicates that this portion of the intellectual entity is not available.
	- the second part of the part string is the "ORDERLABEL" attribute, e.g., 'V1', 'V2'
	  the order label attribute is OPTIONAL
  - for an explanation of Source Entities and Intellectual Entities as used above, please see (https://github.com/NYULibraries/aco-mets)
    

#### output:
- METS XML for the specified DLTS Intellectual Entity object
- output is directed to ```$stdout```


#### Invocation Template
```
ruby ie-gen-mets.rb <objid> <part 1> [<part 2> ... <part n>]
```


#### Example structMap generated when script invoked with "UNAVAIL" parameter
```
$ ruby ie-gen-mets.rb '2d1daa7a-4a1f-44c3-a771-fc21b83bd06e'  'nyu_aco000177_mets.xml#s-ie-00000001:V1' 'UNAVAIL:V2' 'nyu_aco000179_mets.xml#s-ie-00000001:V3'
```

```
...
    <structMap ID="smd-00000001" TYPE="INTELLECTUAL_ENTITY">
        <div>
            <div TYPE="INTELLECTUAL_ENTITY" ID="s-ie-00000001" DMDID="dmd-00000001 dmd-00000002" ADMID="rmd-00000001" ORDER="1" ORDERLABEL="V1">
                <mptr LOCTYPE="URL" xlink:type="simple" xlink:href="nyu_aco000177_mets.xml#s-ie-00000001"/>
            </div>
            <div TYPE="INTELLECTUAL_ENTITY" ID="s-ie-00000002" DMDID="dmd-00000001 dmd-00000002" ADMID="rmd-00000001" ORDER="2" ORDERLABEL="V2">
            </div>
            <div TYPE="INTELLECTUAL_ENTITY" ID="s-ie-00000003" DMDID="dmd-00000001 dmd-00000002" ADMID="rmd-00000001" ORDER="3" ORDERLABEL="V3">
                <mptr LOCTYPE="URL" xlink:type="simple" xlink:href="nyu_aco000179_mets.xml#s-ie-00000001"/>
            </div>
        </div>
    </structMap>
...
```
