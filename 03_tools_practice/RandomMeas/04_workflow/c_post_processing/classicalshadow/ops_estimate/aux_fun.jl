using RandomMeas

# change the room orders of site indices 
function permute_siteindices(siteindices::Vector{Index{Int64}}, targetorders::Vector{Int64})
    @assert length(siteindices) == length(targetorders) "length of siteindices and targetorders must be the same."
    sitesnum = length(siteindices)
    newsiteindices = Vector{Index{Int64}}(undef, sitesnum)
    for siteindex in 1:sitesnum
        targetorder = targetorders[siteindex]
        newsiteindices[siteindex] = siteindices[targetorder]
    end
    return newsiteindices
end

if abspath(PROGRAM_FILE) == @__FILE__
    using RandomMeas
    # settings 
    N = 6
    @show site_indices = siteinds("Qubit", N)
    # change the room orders of site indices
    targeted_order = [6, 5, 4, 3, 2, 1]
    @show permute_siteindices(site_indices, targeted_order)
end

