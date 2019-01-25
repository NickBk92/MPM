
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
MM = 23

a=zeros(31,MM)
for t=1:T
    counter=1
    for m=1:M
        if team_match[t,m] == 1
            team_match_ind[t,counter] = m
            counter += 1
        end
    end
end
a = round.(Int, team_match_ind)

match_per_team = sum(team_match[:,m] for m=2:M)
#MODEL

H3 = Model(solver=GurobiSolver())

@variable(H3, x[r=1:R,m=1:M], Bin)
#general sum of referee refereeing team t
@variable(H3, y[r=1:R,t=1:T] >= 0, Int)
# sequential
@variable(H3, z[r=1:R,t=1:T] >=0 , Int)

@variable(H3, c[r=1:R,t=1:T] >=0 , Int)


@objective(H3, Min, sum(z[r,t]+c[r,t] for r=1:R,t=1:T))

@constraint(H3,twoRefPerMatch[m=1:M],
    sum(x[r,m] for r=1:R) == 2)

@constraint(H3, atMostOneMatchPerDay[r=1:R,d=1:D],
    sum(x[r,m]*match_time[m,d] for m=1:M) <= 1)


@constraint(H3, refAvailability[r=1:R,m=1:M,d=1:D],
    x[r,m]*match_time[m,d]  <= 1-ref_not_available[r,d])

@constraint(H3, SumRefTeamCon[r=1:R,t=1:T],
    sum(x[r,m]*team_match[t,m] for m in 1:M ) ==  y[r,t])

@constraint(H3, threemorerefs[r=1:R,t=1:T], y[r,t] - z[r,t] <= 3)
#@constraint(H3, sameteamtworounds[r=1:R,t=1:T,d=1:D],
    #sum(x[r,m]*match_time[m,d]*team_match[t,m] for m=1:M) == z[r,t,d])
@constraint(H3,dinstance_const
        ,sum(x[r,m]*referfee_arena_distances[r,a]*match_areana[m,a] for r=1:R,m=1:M,a=1:A) <= target_distance*1.25)

@constraint(H3, pairs_cons, sum(x[r,m]*ref_pair[r,rr]*x[rr,m] for r=1:R,m=1:M,rr=r:R) >= target_pairs*0.75)

@constraint(H3, allo[r=1:R,t=1:T], c[r,t] == sum(x[r,a[t,n]]*x[r,a[t,n+1]] for n=1:match_per_team[t]-1) )
solve(H3)

println(getobjectivevalue(H3))
