
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
include("H21a.jl")


#MODEL

H21b = Model(solver=GurobiSolver())

@variable(H21b, x[r=1:R,m=1:M], Bin)

@objective(H21b, Max, sum(x[r,m]*ref_pair[r,rr]*x[rr,m] for r=1:R,m=1:M,rr=r:R))
#Exactly two referees per match
@constraint(H21b,twoRefPerMatch[m=1:M],
    sum(x[r,m] for r=1:R) == 2)
#Each referee can officiate at most 1 match per day.
@constraint(H21b, atMostOneMatchPerDay[r=1:R,d=1:D],
    sum(x[r,m]*match_time[m,d] for m=1:M) <= 1)
#Referees cannot officiate the days that they are not availalbe

@constraint(H21b, refAvailability[r=1:R,m=1:M,d=1:D],
    x[r,m]*match_time[m,d]  <= 1-ref_not_available[r,d])
#Find optimal pairs without worsen the distance.
@constraint(H21b,dinstance_const,
    sum(x[r,m]*referfee_arena_distances[r,a]*match_areana[m,a] for r=1:R,m=1:M,a=1:A) <= target_distance)

solve(H21b)

println(getobjectivevalue(H21b))
