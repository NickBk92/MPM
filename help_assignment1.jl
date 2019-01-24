#how much times a course will be taught over a week

for c in 1:C
    a=sum(getvalue(y[d,h,c]) for d in 1:D,h in 1:H )
    println("course ",c," will be taught ",a," times!\n")
end
#how many modules of each course are taught every day every hour
for d in 1:D
    for h in 1:H
        for c in 1:C
            if getvalue(y[d,h,c])==1
                println(c)
            end
        end
    end
end

#Plan for every PUPIL, this one for p=178

p=12
xres=getvalue(x)
tikanei=zeros(3,4)
for h=1:H
    for d=1:D
        for c=1:C
            if xres[d,h,c,p]==1
                tikanei[h,d]=c

            end
        end
    end
end
        @printf "\n\nPupil: %d\n" p
        for d=1:D
            @printf "\t%d" d
        end
        @printf "\n"
        for h=1:H
            @printf "%d\t" h
            for d=1:D
                        @printf "%d\t" tikanei[h,d]
            end
            @printf "\n"
        end


#PLAN for every teacher

for t=1:T
    zres=getvalue(z)
    tikanei=zeros(3,4)
    for h=1:H
        for d=1:D
            for c=1:C
                if zres[d,h,c,t]==1
                    tikanei[h,d]=c

                end
            end
        end
    end
            @printf "\n\nTeacher: %d\n" t
            for d=1:D
                @printf "\t%d" d
            end
            @printf "\n"
            for h=1:H
                @printf "%d\t" h
                for d=1:D
                            @printf "%d\t" tikanei[h,d]
                end
                @printf "\n"
            end
end



for p=1:P
    if grade[p]==61
        println(p)
    end
end
