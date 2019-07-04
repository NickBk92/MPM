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
T = length(teacher_capacity)





#Model
ass2 = Model(solver=GurobiSolver(MIPGap=0.1))
@variable(ass2,x[d=1:D,h=1:H,c=1:C,p=1:P], Bin)
@variable(ass2,y[d=1:D,h=1:H,c=1:C] >= 0, Int)
@variable(ass2,z[d=1:D,h=1:H,c=1:C,t=1:T],Bin)
@variable(ass2,s[d=1:D,h=1:H,t=1:T],Bin)

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
# Each teacher can teach only one class per module
@constraint(ass2, max_teach_days[d=1:D, h=1:H, c=1:C], y[d,h,c] ==
            sum(z[d,h,c,t] for t=1:T ))

@constraint(ass2, max_teachperday[t=1:T,d=1:D], sum(z[d,h,c,t] for h=1:H,c=1:C)<=teacher_days[t,d]*3)
#Each teacher has a capacity, of classes he can teach
@constraint(ass2, teacher_cap_con[t=1:T], sum(z[d,h,c,t] for d=1:D,h=1:H,c=1:C) <=
                                                            teacher_capacity[t])

@constraint(ass2, courses_constraint[d=1:D, h=1:H, c=1:C, t=1:T], z[d,h,c,t] <= teacher_courses[t,c])




@constraint(ass2, onestart[d=1:D,t=1:T], sum(s[d,h,t] for h=1:H)<=1)

# require connected work plans
@constraint(ass2, conn[d=1:D, h=1:H, t=1:T],
sum((h>1 ? z[d,h-1,c,t] : 0) for c=1:C)  +  s[d,h,t] >= sum(z[d,h,c,t] for c=1:C ))







solution = solve(ass2)
if solution == :Optimal
    println("RESULTS:")
    println("$(getobjectivevalue(ass2))")

end
