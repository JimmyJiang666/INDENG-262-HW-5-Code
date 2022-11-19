using Pkg #In-built package manager of Julia
Pkg.add("JuMP")     #Add mathematical optimization package
Pkg.add("GLPK")     #Add solver

using JuMP, GLPK 


println("\n--------- Problem B ----------")
model = Model()
set_optimizer(model, GLPK.Optimizer);
d = [150,160,225,180];

#Define variables
@variable(model, x[1:4] >= 0);
@variable(model, y[1:4] >= 0);
@variable(model, z[1:5] >= 0);
#Define Constraints
@constraint(model, JanCon, x[1] + y[1] + z[1] - z[2] == d[1]);
@constraint(model, FebCon, x[2] + y[2] + z[2] - z[3] == d[2]);
@constraint(model, MarCon, x[3] + y[3] + z[3] - z[4] == d[3]);
@constraint(model, AprCon, x[4] + y[4] + z[4] - z[5] == d[4]);
for i = 1:4
    @constraint(model, x[i] <= 160);
end
@constraint(model, z[1] == 0);
#Define Objective
@objective(model, Min, 35*sum(x) +50*sum(y) + 5*sum(z));
#Run the opimization
optimize!(model)

global w = objective_value(model)
println("Original Cost: ", w)

for i=1:4   
    println("x$i: ", value(x[i]) )
end
for i=1:4   
    println("y$i: ", value(y[i]) )
end
for i=1:5
    println("z$i: ", value(z[i]))
end

# -------------- G ---------------- #
println("\n\n--------- Problem G ----------")
report = lp_sensitivity_report(model)

# Copied from: https://jump.dev/JuMP.jl/stable/tutorials/linear/lp_sensitivity/
function constraint_report(c::ConstraintRef)
    return (
        name = name(c),
        value = value(c),
        rhs = normalized_rhs(c),
        slack = normalized_rhs(c) - value(c),
        shadow_price = shadow_price(c),
        allowed_decrease = report[c][1],
        allowed_increase = report[c][2],
    )
end

jan_report = constraint_report(JanCon)

print(jan_report)

# -------------- C ---------------- #
println("\n\n--------- Problem C ----------")
function Optimize(x1,x2,x3,x4)
    modelC = Model()
    set_optimizer(modelC, GLPK.Optimizer);
    d = [150,160,225,180];
    #Define variables
    @variable(modelC, x[1:4] >= 0);
    @variable(modelC, y[1:4] >= 0);
    @variable(modelC, z[1:5] >= 0);
    #Define Constraints
    @constraint(modelC, x[1] <= x1);
    @constraint(modelC, x[2] <= x2);
    @constraint(modelC, x[3] <= x3);
    @constraint(modelC, x[4] <= x4);
    for i = 1:4
        @constraint(modelC, x[i] + y[i] + z[i] - z[i+1] == d[i]);
    end
    @constraint(modelC, z[1] == 0);
    #Define Objective
    @objective(modelC, Min, 35*sum(x) +50*sum(y) + 5*sum(z));
    #Run the opimization
    optimize!(modelC)
    println("\nCost with four months constraints = ", [x1,x2,x3,x4])
    print(objective_value(modelC))
    print("\nWith extra cost: ", objective_value(modelC) - w)
    println()
end

Optimize(151,160,160,160)
Optimize(160,153,160,160)
Optimize(160,160,155,160)


# -------------- D ---------------- #
println("\n--------- Problem D ----------")
modelD = Model()
set_optimizer(modelD, GLPK.Optimizer);
d = [150,160,225,180];

#Define variables
@variable(modelD, x[1:4] >= 0);
@variable(modelD, y[1:4] >= 0);
@variable(modelD, z[1:5] >= 0);
@variable(modelD, D[1:4] >= 0); #new vaeriable added to denote if we need to purchase from D
#Define Constraints
for i = 1:4
    @constraint(modelD, x[i] + y[i] + z[i] + D[i] - z[i+1] == d[i]);
    @constraint(modelD, x[i] <= 160);
end
@constraint(modelD, z[1] == 0);
@constraint(modelD, sum(D) <= 50);
#Define Objective
@objective(modelD, Min, 35*sum(x) +50*sum(y) + 5*sum(z) + 45*sum(D));
#Run the opimization
optimize!(modelD)

println("Here's how many we purchase from D each month")

for i=1:4   
    println("d$i: ", value(D[i]) )
end

println("\nWith savings: ", w - objective_value(modelD))



# -------------- E ---------------- #
println("\n--------- Problem E ----------")
model = Model()
set_optimizer(model, GLPK.Optimizer);
d = [150,160,225,180];

#Define variables
@variable(model, x[1:4] >= 0);
@variable(model, y[1:4] >= 0);
@variable(model, z[1:5] >= 0);
#Define Constraints
for i = 1:4
    @constraint(model, x[i] + y[i] + z[i] - z[i+1] == d[i]);
    @constraint(model, x[i] <= 160);
end
@constraint(model, z[1] == 0);
#Define Objective
@objective(model, Min, 35*sum(x) +50*sum(y) + 5*sum(z));
#Run the opimization
optimize!(model)


print("Show the reduced cost of y_2 for problem (e):\n")
print(reduced_cost(y[2]))


# -------------- F ---------------- #
println("\n\n--------- Problem F ----------")
model = Model()
set_optimizer(model, GLPK.Optimizer);
d = [150,160,225,180];

#Define variables
@variable(model, x[1:4] >= 0);
@variable(model, y[1:4] >= 0);
@variable(model, z[1:5] >= 0);
#Define Constraints

for i = 1:4
    @constraint(model, x[i] + y[i] + z[i] - z[i+1] == d[i]);
    @constraint(model, x[i] <= 160);
end
@constraint(model, z[1] == 0);
#Define Objective
@objective(model, Min, 35*sum(x) +50*sum(y) + 5*(z[1]+z[3]+z[4]) + 8*z[2]);
#Run the opimization
optimize!(model)

for i=1:4   
    println("x$i: ", value(x[i]) )
end
for i=1:4   
    println("y$i: ", value(y[i]) )
end
for i=1:5
    println("z$i: ", value(z[i]))
end

println("It can be seen that the basis remains optimal.")
println("The cost increase is ", objective_value(model) - w)

