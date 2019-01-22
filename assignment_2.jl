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
include("courseLimits.jl")
include("pupils.jl")
include("teachers.jl")
#************************************************************************
#DATA

D = 4
H = 3
C = size(course_bounds,1)
P = size(pupil_courses,1)





#Model
ass2 = Model(solver=GurobiSolver())
@variable(ass2,x[d=1:D,h=1:H,c=1:C,p=1:P], Bin)
@variable(ass2,y[d=1:D,h=1:H,c=1:C] >= 0, Int)
@variable(ass2,z[d=1:D,h=1:H,c=1:C,t=1:T],Bin)

@objective(ass2,Max,sum(x[d,h,c,p]*pupil_courses[p,c] for d=1:D,h=1:H,c=1:C,p=1:P))

@constraint(ass2,maxCoursesPerPupil[p=1:P],sum(x[d,h,c,p] for d=1:D,h=1:H,c=1:C)<=12)
#Lower bound for each class
@constraint(ass2,lowerCourseLimit[d=1:D,h=1:H,c=1:C],sum(x[d,h,c,p] for p=1:P)>= course_bounds[c,1]*y[d,h,c])
#Upper bound for each class
@constraint(ass2,upperCourseLimit[d=1:D,h=1:H,c=1:C],sum(x[d,h,c,p] for p=1:P)<= course_bounds[c,2]*y[d,h,c])
#Every puppil can take  a course only once
@constraint(ass2, onlyOnce[c=1:C,p=1:P],sum(x[d,h,c,p] for d=1:D,h=1:H)<=1)
#Every pupil can take at most one course each timeslot
@constraint(ass2, onlyOnePerSlot[d=1:D,h=1:H,p=1:P],sum(x[d,h,c,p] for c=1:C)<=1 )

#Assignment 2
#
@constraint(ass2, OneperModule[t=1:T], y[d,h,c] == sum(z[d,h,c,t] for d=1:D,h=1:H,c=1:C) )




solution = solve(ass2)
if solution == :Optimal
    println("RESULTS:")
    println("$(getobjectivevalue(ass2))")

end
for d in 1:D
    for h in 1:H
        for c in 1:C

            println("$(getvalue(y[d,h,c]))")
        end
    end
end
for c in 1:C
    a=sum(getvalue(y[d,h,c]) for d in 1:D,h in 1:H )
    println("course $(c)"," will be taught ",a," times!\n")
end
