module PopGen

##   o O       o O       o ############ O       o O       o O
## o | | O   o | | O   o |              | O   o | | O   o | | O
## | | | | O | | | | O | | Dependencies | | O | | | | O | | | | O
## O | | o   O | | o   O |              | o   O | | o   O | | o
##   O o       O o       O ############ o       O o       O o


using DataFrames, PlotlyJS, GeneticVariation, Distributions, MultipleTesting

export PopObj,
    summary,
    nancycats,
    gulfsharks,
    csv,
    genepop,
    vcf,
    sample_names,
    isolate_genotypes,
    locations, locations!,
    population, populations, population!, populations!,
    remove_inds!,
    remove_loci!,
    missing,
    heterozygosity, het, He,
    hwe_test,
    plot_missing,
    plot_locations



##   o O       o O       o ############ O       o O       o O
## o | | O   o | | O   o |              | O   o | | O   o | | O
## | | | | O | | | | O | |  Load files  | | O | | | | O | | | | O
## O | | o   O | | o   O |              | o   O | | o   O | | o
##   O o       O o       O ############ o       O o       O o

include("PopObj.jl")
include("Read.jl")
include("Manipulate.jl")
include("Plotting.jl")
include("Datasets.jl")
include("AlleleFreq.jl")
include("HardyWeinberg.jl")

end # module PopGen
