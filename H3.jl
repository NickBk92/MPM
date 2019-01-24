
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

H3 = Model(solver=GurobiSolver())

@variable(H3, x[r=1:R,m=1:M], Bin)
#general sum of referee refereeing team t
@variable(H3, y[r=1:R,t=1:T], Int)
# sequential
@variable(H3, z[r=1:R,t=1:T], Int)

@objective(H3, Min, sum(x[r,m]*referfee_arena_distances[r,a]*match_areana[m,a] for r=1:R,m=1:M,a=1:A))

@constraint(H3,twoRefPerMatch[m=1:M],
    sum(x[r,m] for r=1:R) == 2)

@constraint(H3, atMostOneMatchPerDay[r=1:R,d=1:D],
    sum(x[r,m]*match_time[m,d] for m=1:M) <= 1)


    @constraint(H3, refAvailability[r=1:R,m=1:M,d=1:D],
        x[r,m]*match_time[m,d]  <= 1-ref_not_available[r,d])

@constraint(H3, Sumrefteamcon[r=1:R,t=1:T], sum(x[r,m]*team_match[t,m] for m in 1:M) == y[r,t])

@constraint(H3, sameteamtworounds[])

solve(H3)

println(getobjectivevalue(H3))

target_distance=getobjectivevalue(H3)

println(getvalue(y[:,:]))
