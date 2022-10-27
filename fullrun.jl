using Pkg
Pkg.activate(".")
using jDMFT
using FastGaussQuadrature, DelimitedFiles
include("test/helper_functions.jl")

t_fac = 1.0 #2*sqrt(6)
U = 2.0 #0.20412414523193154 #1.1
μ = 1.0 #0.10206207261596577 #0.55
β  = 14.0 #0.20412414523193154 #10.0
Nν = 100
Nτ = 100
νnGrid = jDMFT.iν_array(β, -Nν:Nν-1)
τGrid_red, τWeights = gaussradau(Nτ);
τGrid = τGrid_red .* β ./ 2 .+ β ./ 2;
GW_in = init_weissgf_from_ed((@__DIR__)*"/test/test_data/U2.0_b14.0_hubb.andpar", Nν) #tt_hubb
GW = MatsubaraFunction(jDMFT.PH_transform(GW_in, U), β, νnGrid, [1.0], [-0.5])
G_τ = ω_to_τ(GW, τWeights, τGrid)

cf, me, M, GImp_test_L, GImp_νtest_L = jDMFT.sample(G_τ, U, 2000, N_warmup=300, sample_τGrid=τGrid)


gwt = GW.data[1:200]
GImp_νTest_t = (GImp_νtest_L[1] .+ GImp_νtest_L[2]) ./ 2
GImp_νTest = gwt - (1/β) .* gwt .* gwt .* GImp_νTest_t
GImp_νTest_τ = ω_to_τ(GImp_νTest, jDMFT.iν_array(β,-100:99), τGrid, [1.0],[-0.5], β)

# cf2, me2, M2, GImp_test2 = jDMFT.sample(G_τ, U, 1000, N_warmup=1000, sample_τGrid=τGrid, with_τshift=false)
GImp_do = jDMFT.measure_GImp_τ(me[1], G_τ);
GImp_up = jDMFT.measure_GImp_τ(me[2], G_τ);
GImp = (GImp_do .+ GImp_up) ./ 2


Σ_IPT = impSolve_IPT(U, 1.0, G_τ, G_τ, νnGrid)
