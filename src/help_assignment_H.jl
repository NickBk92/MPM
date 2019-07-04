team_day=team_match*match_time
println(team_day)
for m in 1:M
    if team_match[1,m] == 1
        println(m)
    end
end

for t in 1:T
    for d in 1:D
        if team_day[t,d] == 2
            print("team ",t," plays twice on day ", d,"\n")
        end
    end
end

for m=1:M
    if team_match[25,m] == 1
        print(m,"\t")
    end
end

 println(match_time[181,48])
  println(match_time[186,48])

  println(team_match[25,181])
  println(team_match[25,186])
