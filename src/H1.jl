
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




#MODEL

H1 = Model(solver=GurobiSolver())

@variable(H1, x[r=1:R,d=1:D,a=1:A], Bin)

@objective(H1, Min, sum(x[r,d,a]*referfee_arena_distances[r,a] for r=1:R,d=1:D,a=1:A))
#Exactly two referees per match
@constraint(H1,twoRefPerMatch[d=1:D,a=1:A],
    sum(x[r,d,a] for r=1:R) == 2*arenaOccupied[a,d])
#Each referee can officiate at most 1 match per day.
@constraint(H1, atMostOneMatchPerDay[r=1:R,d=1:D],
    sum(x[r,d,a] for a=1:A) <= 1)

#Referees cannot officiate the days that they are not availalbe
@constraint(H1, refAvailability[r=1:R,d=1:D],
    sum(x[r,d,a] for a=1:A) <= 1-ref_not_available[r,d])

solve(H1)

println(getobjectivevalue(H1))
