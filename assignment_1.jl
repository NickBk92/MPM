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

#************************************************************************
#DATA

D = 4
H = 3
C = size(course_bounds,1)
P = size(pupil_courses,1)





#Model
ass1 = Model(solver=GurobiSolver())
@variable(ass1,x[d=1:D,h=1:H,c=1:C,p=1:P], Bin)

@objective(ass1,Max,sum(sum(x[d,h,c,p] for d=1:D,h=1:H)*pupil_courses[p,c] for c=1:C,p=1:P))

@constraint(ass1,maxCoursesPerPupil[p=1:P],sum(x[d,h,c,p] for d=1:D,h=1:H,c=1:C)<=12)
#Lower bound for each class
@constraint(ass1,lowerCourseLimit[d=1:D,h=1:H,c=1:C],sum(x[d,h,c,p] for p=1:P)>= course_bounds[c,1])
#Upper bound for each class
@constraint(ass1,upperCourseLimit[d=1:D,h=1:H,c=1:C],sum(x[d,h,c,p] for p=1:P)<= course_bounds[c,2])
#Every puppil can take  a course only once
@constraint(ass1, onlyOnce[c=1:C,p=1:P],sum(x[d,h,c,p] for d=1:D,h=1:H)<=1)
#Every pupil can take at most one course each timeslot
@constraint(ass1, onlyOnePerSlot[d=1:D,h=1:H,p=1:P],sum(x[d,h,c,p] for c=1:C)<=1 )



solve(ass1)
println(getobjectivevalue(ass1))
