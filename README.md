# Human Chromosome Ontology

The Human Chromosome Ontology (HCO) provides simple and stable URIs for human reference genome versions to semantically identify human chromosomes.

Basic class `hco:HumanChromosome` is inherited by each chromosome class such as `hco:21` and `hco:GenomeBuild` is inherited by each build version such as `hco:GRCh38`. Then, for example, the human chromosome 21 of the GRCh38 version is represented as `hco:21\/GRCh38` (<http://biohackathon.org/resource/hco/21/GRCh38>) which is defined as an instance of `hco:21` with build version `hco:GRCh38`. Each instance of a chromosome has links to external resources such as INSDC, RefSeq, UCSC etc. so that users can be navigated to the chromosome sequence and its annotations.

```
hco:21
        rdfs:label      "Human chromosome 21" ;
        rdfs:subClassOf hco:HumanChromosome .

hco:21\/GRCh38
        rdf:type        hco:21 ;
        hco:build       hco:GRCh38 ;
        hco:length      46709983 ;
        skos:altLabel   "GPC_000001313" ;
        hco:insdc       <http://identifiers.org/insdc/CM000683.2> ;
        hco:refseq      <http://identifiers.org/refseq/NC_000021.9> ;
        hco:ucsc        <http://genome.ucsc.edu/cgi-bin/hgTracks?db=hg38&position=chr21> ;
        hco:ensembl     <http://rdf.ebi.ac.uk/resource/ensembl/homo_sapiens/GRCh38/21> ,
                        <http://www.ensembl.org/Homo_sapiens/Location/Chromosome?r=21> .
```

Also, `hco:Cytoband` is inherited by each cytoband class such as `hco:21q11.2` and an instance of it such as `hco:21q11.2\/GRCh38` has the [FALDO](http://biohackathon.org/resource/faldo) location on a chromosome and `hco:bandtype` such as `hco:Gneg` which stands for a nonstaining G-negative light band.

```
hco:21q11.2
        rdfs:label      "21q11.2" ;
        rdfs:subClassOf hco:Cytoband .

hco:21q11.2\/GRCh38
        rdf:type        hco:21q11.2 ;
        hco:build       hco:GRCh38 ;
        hco:bandtype    hco:Gneg ;
        faldo:location  [
                rdf:type         faldo:Region ;
                faldo:begin      [
                        rdf:type         faldo:BothStrandsPosition ;
                        faldo:position   13000000 ;
                        faldo:reference  hco:21\/GRCh38
                ] ;
                faldo:end        [
                        rdf:type         faldo:BothStrandsPosition ;
                        faldo:position   15000000 ;
                        faldo:reference  hco:21\/GRCh38
                ]
        ] .
```

## Update procedure

To create the latest version of the ontology, first obtain the cytoBand data from UCSC and convert the data into RDF/Turtle.

```
$ curl http://hgdownload.cse.ucsc.edu/goldenPath/hg19/database/cytoBand.txt.gz | gzip -dc - > cytoBand-GRCh37.txt
$ curl http://hgdownload.cse.ucsc.edu/goldenPath/hg38/database/cytoBand.txt.gz | gzip -dc - > cytoBand-GRCh38.txt
$ ruby cytoBand2ttl.rb > cytoBand.ttl
```

Then, concatenate the header part of the ontology with the cytoBand data.

```
$ cat hco_head.ttl cytoBand.ttl > hco.tmp
```

Finallly, expand `hco:X\/GRChXX` into `<http://biohackathon.org/resource/hco/X/GRChXX>` for avoiding a triple store to treat it as `<http://biohackathon.org/resource/hco/X\/GRChXX>` (some triple store such as Virtuoso has an option to relax syntax rules for loading invalid data that sometimes causes further problem even for valid data).

```
$ rapper -i turtle -o turtle hco.tmp > hco.ttl
```

### Contributors

* Toshiaki Katayama (Database Center for Life Science)
* The Med2RDF project <http://med2rdf.org/>
* The 3rd RDF summit <https://github.com/dbcls/rdfsummit3>
