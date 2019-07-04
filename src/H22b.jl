
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
include("H22a.jl")



#MODEL

H22b = Model(solver=GurobiSolver())

@variable(H22b, x[r=1:R,m=1:M], Bin)

@objective(H22b, Min, sum(x[r,m]*referfee_arena_distances[r,a]*match_areana[m,a] for r=1:R,m=1:M,a=1:A))
#Exactly two referees per match
@constraint(H22b,twoRefPerMatch[m=1:M],
    sum(x[r,m] for r=1:R) == 2)
#Each referee can officiate at most 1 match per day.
@constraint(H22b, atMostOneMatchPerDay[r=1:R,d=1:D],
    sum(x[r,m]*match_time[m,d] for m=1:M) <= 1)


#Referees cannot officiate the days that they are not availalbe
@constraint(H22b, refAvailability[r=1:R,m=1:M,d=1:D],
    x[r,m]*match_time[m,d]  <= 1-ref_not_available[r,d])
#Find min distance without decreasing the pairs.
@constraint(H22b, pairs_cons,
    sum(x[r,m]*ref_pair[r,rr]*x[rr,m] for r=1:R,m=1:M,rr=r:R) >= target_pairs)

solve(H22b)

println(getobjectivevalue(H22b))
