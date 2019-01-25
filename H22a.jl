
#************************************************************************
# Assignment 1, "Mathematical Programming Modelling" (42112)
#************************************************************************
# Intro definitions
using JuMP
using Gurobi
using Printf
#************************************************************************
#************************************************************************
# PARAMETERS
include("handball_data.jl")

(R,A) = size(referfee_arena_distances)
(M,D) = size(match_time)
T = size(team_match,1)

arenaOccupied = zeros(A,D)

for a=1:A
    for d=1:D
        arenaOccupied[a,d] = sum(match_areana[m,a]*match_time[m,d] for m=1:M)
    end
end

ref_match_distance = referfee_arena_distances * match_areana'
ref_na_match=ref_not_available * match_time'


#MODEL

H22a = Model(solver=GurobiSolver())

@variable(H22a, x[r=1:R,m=1:M], Bin)

@objective(H22a, Max, sum(x[r,m]*ref_pair[r,rr]*x[rr,m] for r=1:R,m=1:M,rr=r:R))

@constraint(H22a,twoRefPerMatch[m=1:M],
    sum(x[r,m] for r=1:R) == 2)

@constraint(H22a, atMostOneMatchPerDay[r=1:R,d=1:D],
    sum(x[r,m]*match_time[m,d] for m=1:M) <= 1)



@constraint(H22a, refAvailability[r=1:R,m=1:M,d=1:D],
    x[r,m]*match_time[m,d]  <= 1-ref_not_available[r,d])

solve(H22a)

println(getobjectivevalue(H22a))

target_pairs = getobjectivevalue(H22a)
println(sum(getvalue(x[r,m])*referfee_arena_distances[r,a]*match_areana[m,a] for r=1:R,m=1:M,a=1:A))
