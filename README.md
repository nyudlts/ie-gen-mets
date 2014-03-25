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
- [METS](http://www.loc.gov/standards/mets/) mptr strings, in sequential order, that point to the correct intellectual entity in the source entity structMap OR the string "MISSING" to indicate 
  - for an explanation of Source Entities and Intellectual Entities as used above, please see (https://github.com/NYULibraries/aco-mets)

#### output:
- METS XML for the specified DLTS Intellectual Entity object
- output is directed to ```$stdout```


#### Invocation Template
```
ruby ie-gen-mets.rb <objid> <mptr 1> [<mptr 2> ... <mptr n>]
```


#### Example structMap generated when script invoked with "MISSING" parameter
```
$ ruby ie-gen-mets.rb '2d1daa7a-4a1f-44c3-a771-fc21b83bd06e'  'nyu_aco000177_mets.xml#s-ie-00000001' 'MISSING' 'nyu_aco000179_mets.xml#s-ie-00000001'
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
