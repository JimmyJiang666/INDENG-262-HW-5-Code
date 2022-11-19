using Pkg #In-built package manager of Julia
Pkg.add("JuMP")     #Add mathematical optimization package
Pkg.add("GLPK")     #Add solver
Pkg.add("DataFrames")
using JuMP, GLPK 
import DataFrames

model = Model()
set_optimizer(model, GLPK.Optimizer);
@variable(model, E >= 0);
@variable(model, C >= 0);
@variable(model, P1 >= 0);
@variable(model, P2 >= 0);
@variable(model, B >= 0);

@constraint(model, Clay, 10*E + 15*C + 10*P1 + 10*P2 + 20*B <= 130);
@constraint(model, Enamel, 1*E + 2*C + 2*P1 + 1*P2 + 1*B <= 13);
@constraint(model, DryRm, 3*E + 1*C + 6*P1 + 6*P2 + 3*B <= 45);
@constraint(model, Kiln, 2*E + 4*C + 2*P1 + 5*P2 + 3*B <= 23);
@constraint(model, Prim, P1 - P2 == 0);

@objective(model, Max, 51*E + 102*C + 66*P1 + 66*P2 + 89*B);


optimize!(model)
report = lp_sensitivity_report(model)


# function borrowed from https://jump.dev/JuMP.jl/stable/tutorials/linear/lp_sensitivity/
function variable_report(xi)
    return (
        name = name(xi),
        # lower_bound = has_lower_bound(xi) ? lower_bound(xi) : -Inf,
        optimal_value = value(xi),
        # upper_bound = has_upper_bound(xi) ? upper_bound(xi) : Inf,
        reduced_cost = reduced_cost(xi),
        obj_coefficient = coefficient(objective_function(model), xi),
        allowed_increase = report[xi][2],
        allowed_decrease = report[xi][1],
    )
end

function constraint_report(c::ConstraintRef)
    return (
        name = name(c),
        slack_value = value(c),
        dual_variable = shadow_price(c),
        rhs = normalized_rhs(c),
        allowed_decrease = report[c][1],
        allowed_increase = report[c][2],
    )
end


variable_df =
    DataFrames.DataFrame(variable_report(xi) for xi in all_variables(model));

println(variable_df)

constraint_df = DataFrames.DataFrame(
    constraint_report(ci) for (F, S) in list_of_constraint_types(model) for
    ci in all_constraints(model, F, S) if F == AffExpr
)

println(constraint_df)