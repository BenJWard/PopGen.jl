## Milligan 2002 dyadic relatedness - https://www.ncbi.nlm.nih.gov/pmc/articles/PMC1462494/pdf/12663552.pdf

#= Steps to finish:
    Calculate all loci pr_l_s

    Calcuate Δ coefficients given all of the available alleles
    Calculate Δ using log likelihood rather than likelihood to make it nicer

    Iterate over all pairs of individuals

    Add in ability to turn off inbreeding (set all but the last 3 pr_l_s to 0 before optimizing Δ)
=#

# Outside main function:
# Pass in pop.object
# Pass in sting saying method of relatedness to Calculate

# Inside main function
# Calculate allele frequencies for all loci to be accessed within next ability
# Create for loop through all pairs of individuals and calculate relatedness
#         -One possibility here is to use some type of outer function where the function evaluated in each cell is the relatedness calculation

get_genotype = PopGen.get_genotype
allele_freq_mini = PopGen.allele_freq_mini

data = nancycats()
ind1 = "N100"
ind2 = "N111"

# Inside Relatedness function - DyadML
# loop through all loci and extract the genotype of both individuals
# If neither individual is missing data at that locus then calculate Pr_L_S
# Store as array all of the Pr_L_S values (9 x nloci)
# End Loop
# Calculate Δ coefficients
# Calculate r value from Δ


allele_frequencies = Dict()
for locus in names(data.loci)
    allele_frequencies[String(locus)] = allele_freq_mini(data.loci[:, locus])
end



function dyadic_ML(data, allele_freqs)

    Pr_L_S = []
    for locus in names(data.loci)
        #Extract the pair of interest's genotypes
        gen1 = get_genotype(data, sample = ind1, locus = String(locus))
        gen2 = get_genotype(data, sample = ind2, locus = String(locus))

        tmp = pr_l_s(gen1, gen2, allele_freqs[String(locus)])
        push!(Pr_L_S, tmp)
    end

    return hcat(Pr_L_S...)
end


tmp = dyadic_ML(data, allele_frequencies)



"""
    pr_l_s(x, y, allele_freq)
Calculate the probability of observing the particular allele state given each of the 9 Jacquard Identity States
Creates Table 1 from Milligan 2002
"""
function pr_l_s(x, y, allele_freq)
    #= Example
    cats = nancycats()
    cat1=PopGen.get_genotype(cats, sample = "N100", locus = "fca23")
    cat2=PopGen.get_genotype(cats, sample = "N111", locus = "fca23")
    allele_freq = PopGen.allele_freq_mini(cats.loci.fca23)
    pr_l_s(cat1, cat2, allele_freq)


    =#


    #= Current Bugs

    =#

    #= Calculate Pr(Li | Sj)
    If the allele identity falls into this class (L1-L9), generate the
    probabilities of it belonging to each of the different classes and
    return that array of 9 distinct probabilities
    =#

    ## class L1 -  AᵢAᵢ AᵢAᵢ ##
    if x[1] == x[2] == y[1] == y[2]
        p = allele_freq[x[1]]
        [p, p^2, p^2, p^3, p^2, p^3, p^2, p^3, p^4]

    ## class L2 - AᵢAᵢ AⱼAⱼ ##
    elseif (x[1] == x[2]) & (y[1] == y[2]) & (x[1] != y[1])
        p = (allele_freq[x[1]], allele_freq[y[1]])
        [0, prod(p), 0, prod(p) * p[2], 0, prod(p) * p[1], 0, 0, prod(p.^2)]

    ## class L3 - AᵢAᵢ AᵢAⱼ & AᵢAᵢ AⱼAᵢ ## - has issues because of allele order
    elseif ((x[1] == x[2] == y[1]) & (x[1] != y[2])) | ((x[1] == x[2] == y[2]) & (x[1] != y[1]))
        p = (allele_freq[x[1]], allele_freq[y[2]])
        [0, 0, prod(p), 2 * prod(p) * p[1], 0, 0, 0, prod(p) * p[1], 2 * prod(p) * p[1]^2]

    ## class L4 - AᵢAᵢ AⱼAₖ ##
    elseif (x[1] == x[2]) & (y[1] != y[2]) & (x[1] != y[1]) & (x[1] != y[2])
        p = (allele_freq[x[1]], allele_freq[y[1]], allele_freq[y[2]])
        [0, 0, 0, 2 * prod(p), 0, 0, 0, 0, 2 * prod(p) * p[1]]

    ## L5 - AiAj AiAi & AjAi AiAi ## - has issues because of allele order
    elseif ((x[1] == y[1] == y[2]) & (x[1] != x[2])) | (x[2] == y[1] == y[2] * (x[1] != x[2]))
        p = (allele_freq[x[1]], allele_freq[x[2]])
        [0, 0, 0, 0, prod(p), 2 * prod(p) * p[1], 0, prod(p) *p[1], 2 * prod(p) * p[1]^2]

    ## L6 - AjAk AiAi ##
    elseif (x[1] != x[2]) & (y[1] == y[2]) & (x[1] != y[1]) & (x[2] != y[1])
        p = (allele_freq[y[1]], allele_freq[x[1]], allele_freq[x[2]])
        [0, 0, 0, 0, 0, 2 * prod(p), 0, 0, 2 * prod(p) * p[1]]

    ## L7 - AiAj AiAj ##
    elseif (x[1] == y[1]) & (x[2] == y[2]) & (x[1] != x[2])
        p = (allele_freq[x[1]], allele_freq[x[2]])
        [0, 0, 0, 0, 0, 0, 2 * prod(p), prod(p) * sum(p), 4 * prod(p.^2)]

    ## L8 - AiAj AiAk & AjAi AkAi & AjAi AiAk & AiAj AkAi ##  - has issues because of allele order
    elseif ((x[1] == y[1]) & (x[1] != x[2]) & (y[1] != y[2]) & (x[2] != y[2])) |
            ((x[2] == y[2]) & (x[1] != x[2]) & (y[1] != y[2]) & (x[1] != y[1])) |
            ((x[2] == y[1]) & (x[1] != x[2]) & (y[1] != y[2]) & (x[1] != y[2])) |
            ((x[1] == y[2]) & (x[1] != x[2]) & (y[1] != y[2]) & (x[1] != y[1]))
        p = (allele_freq[x[1]], allele_freq[x[2]], allele_freq[y[2]])
        [0, 0, 0, 0, 0, 0, 0, prod(p), 4 * prod(p) * p[1]]

    ## L9 - AiAj AkAl ##
    elseif (x[1] != x[2]) & (x[1] != y[1]) & (x[1] != y[2]) & (x[2] != y[1]) & (x[2] != y[2]) & (y[1] != x[2])
        p = (allele_freq[x[1]], allele_freq[x[2]], allele_freq[y[1]], allele_freq[y[2]])
        [0, 0, 0, 0, 0, 0, 0, 0, 4 * prod(p)]
    else
        [-9, -9, -9, -9, -9, -9, -9, -9, -9]
    end
end


## Calculate Δ coefficients
using JuMP
using GLPK
#Need to either maximize this sum or use it as the likelihood in a bayesian model and sample from the posterior.
#currently only maximum likelihood optimization
function Δ_optim(Pr_L_S::Vector{Float64})
    #Δ is what needs to be optimized
    #consist of 9 values between 0 and 1 which must also sum to 1
    #is then used to calculate relatedness

    model = Model(with_optimizer(GLPK.Optimizer))
    @variable(model, 0 <= Δ[1:8] <= 1)
    @objective(model, Max, sum(Pr_L_S[1:8] .* Δ) + ((1 - sum(Δ)) * Pr_L_S[9]))
    @constraint(model, con, 0 <= (1 - sum(Δ)) <= 1)
    optimize!(model)

    out = value.(Δ)
    push!(out, 1 - sum(out))
    #Should probably include some output that confirms that it did in fact converge and/or use multiple random starts to confirm not a local maxima
end

Δ = Δ_optim(tmp["fca77"])


#First attempt at optimizing multiple loci
function Δ_optim(Pr_L_S)
    #Δ is what needs to be optimized
    #consist of 9 values between 0 and 1 which must also sum to 1
    #is then used to calculate relatedness

    model = Model(with_optimizer(Ipopt.Optimizer))
    @variable(model, 0 <= Δ[1:8] <= 1)
    @objective(model, Max, log_likelihood_Δ(Pr_L_S, Δ))
    @constraint(model, con, 0 <= (1 - sum(Δ)) <= 1)
    optimize!(model)

    out = value.(Δ)
    push!(out, 1 - sum(out))
    #Should probably include some output that confirms that it did in fact converge and/or use multiple random starts to confirm not a local maxima
end

Δ = Δ_optim(tmp)

keys(tmp)

tmp["fca23"][1:8]

function log_likelihood_Δ(Pr_L_S, Δ)
    out = 0
    for locus in keys(Pr_L_S)
        out = out + log(sum(Pr_L_S[locus][1:8] .* Δ) + ((1 - sum(Δ)) * Pr_L_S[locus][9]))
    end
end





## Calculate theta and r
function relatedness_calc(Δ)
    θ = Δ[1] + 0.5 * (Δ[3] + Δ[5] + Δ[7]) + 0.25 * Δ[8]
    2 * θ
end

relatedness_calc(Δ)
