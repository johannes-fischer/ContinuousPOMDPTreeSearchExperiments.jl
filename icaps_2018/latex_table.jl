using DataFrames
using DataFramesMeta
using CSV

d = Pkg.dir("ContinuousPOMDPTreeSearchExperiments", "icaps_2018","data")

solver_order = ["pomcpow" => "POMCPOW",
                "qmdp" => "QMDP",
                "pomcpdpw" => "POMCP-DPW", 
                "despot" => "DESPOT",
                "pft" => "PFT",
                "d_pomcp" => "POMCP\\textsuperscript{D}",
                "d_despot" => "DESPOT\\textsuperscript{D}"]

cardinality = Dict("lasertag" => "(D, D, D)",
                   "lightdark" => "(D, D, C)",
                   "subhunt" => "(D, D, C)",
                   "vdpbarrier" => "(C, C, C)",
                   "vdptag" => "(C, C, C)")


problem_order = ["lasertag", "lightdark", "subhunt", "vdpbarrier"]

filenames = Dict("lasertag" => "$(Pkg.dir("ContinuousPOMDPTreeSearchExperiments"))/icaps_2018/data/lasertag_Monday_26_Feb_18_46.csv",
                 "lightdark" => "$(Pkg.dir("ContinuousPOMDPTreeSearchExperiments"))/icaps_2018/data/simpleld_Monday_26_Feb_20_13.csv",
                 "subhunt" => "$(Pkg.dir("ContinuousPOMDPTreeSearchExperiments"))/icaps_2018/data/subhunt_Monday_26_Feb_20_44.csv",
                 "vdpbarrier" => "$(Pkg.dir("ContinuousPOMDPTreeSearchExperiments"))/icaps_2018/data/bdpbarrier_Monday_26_Feb_21_42.csv")

data = Dict(
    "lightdark" => Dict(
        "limits" => (-20.0, 80.0),
        "name" => "Light Dark"
    ), 

    "subhunt" => Dict(
        "limits" => (0.0, 80.0),
        "name" => "Sub Hunt"
    ),

    "lasertag" => Dict(
        "limits" => (-20.0, -8.0),
        "name" => "Laser Tag"
    ),

    "vdptag" => Dict(
        "limits" => (-20.0, 40.0),
        "name" => "VDP Tag"
    ),

    "vdpbarrier" => Dict(
        "limits" => (0.0, 31.0),
        "name" => "VDP Tag"
    ),

)

for p in problem_order
    df = CSV.read(filenames[p])
    d = data[p]
    for s in unique(df[:solver])
        rs = @where(df, :solver.==s)[:reward]
        m = mean(rs)
        sem = std(rs)/sqrt(length(rs))
        if s == "ar_despot"
            s = "despot"
        elseif s == "despot_01"
            s = "despot"
        elseif p == "lasertag" && s == "pomcp"
            s = "d_pomcp"
        end
        d[s] = (m, sem)
    end
end

hbuf = IOBuffer()

for k in problem_order
    print(hbuf, "& $(data[k]["name"]) \\makebox[0pt][l]{$(cardinality[k])} & ")
end
print(hbuf, "\\\\")

tbuf = IOBuffer()
for (k, n) in solver_order
    print(tbuf, n*" ")
    for p in problem_order
        d = data[p]
        if haskey(d, k)
            m, sem = d[k]
            lo, hi = d["limits"]
            frac = (m-lo)/(hi-lo)
            @printf(tbuf, "& \\result{%.1f}{%.1f}{%d}{%.2f} ",
                    m, sem, round(Int, 100*frac), frac
                   )
        else
            print(tbuf,  "& \\noresult{} ")
        end
    end
    print(tbuf, "\\\\\n")
end

columns = "l"*"rl"^length(data)

tabletex = """
    \\begin{tabular}{$columns}
        \\toprule
            $(String(hbuf))        
        \\midrule
            $(String(tbuf))
        \\bottomrule
    \\end{tabular}
"""

println(tabletex)

# """
#     \begin{tabular}{lrrrrrrrr}
#         \toprule
#                   & POMCPOW               & QMDP                & POMCP-DPW     & DESPOT
#                   & PFT                   & POMCP\textsuperscript{D} & DESPOT\textsuperscript{D} \\
#         \midrule
#         Laser Tag\textsuperscript{D}
#                   & $-10.4\pm0.2$         & $-10.5\pm0.2$       & $-10.4\pm0.2$    & $\mathbf{-8.9\pm0.2}$
#                   & $-11.6\pm0.2$         &                     & \\
# 
#         Light Dark& $62.2\pm0.5$          & $5.3\pm1.2$         & $5.3\pm1.3$   & $6.7\pm1.3$
#                   & $57.1\pm0.4$          & $\mathbf{64.5\pm0.4}$    & $52.2\pm1.3$ \\
# 
#         Sub Hunt  & $45.5\pm1.5$          & $27.9\pm1.3$        & $27.8\pm1.3$  & $26.7\pm1.3$
#                   & $\mathbf{79.0\pm1.1}$ & $28.2\pm1.3$           & $27.1\pm1.3$ \\
# 
#         VDP Tag   & $\mathbf{38.1\pm0.8}$ &                     & $-18.9\pm0.2$ &
#                   & $32.9\pm0.9$          & $-18.5\pm0.2$            & $-16.2\pm0.4$ \\
#         \bottomrule
#     \vspace{1mm}
#     \end{tabular}
# """

#=
data = Dict(
    "lightdark" => Dict(
        "heuristic_01" => (24.876, 0.861),
        "qmdp" => (-6.369, 1.029),
        "pomcpdpw" => (-7.269, 0.997),
        "pomcpow" => (57.624, 0.475),
        "d_pomcp" => (61.182, 0.435),
        "heuristic_1" => (27.612, 0.917),
        "despot" => (-6.819, 1.020),
        "pomcp" => (-7.813, 0.991),
        "side" => (42.417, 0.432),
        "pft" => (49.366, 0.690),
        "d_despot" => (55.540, 0.974),
        "limits" => (-20.0, 80.0),
        "name" => "Light Dark"
    ), 

    "subhunt" => Dict(
        "qmdp" => (27.991,  1.344),
        "ping_first" => (79.014,  1.081),
        "despot" => (27.092,  1.329),
        "pomcpow" => (61.809,  1.367),
        "pomcpdpw" => (27.801,  1.341),
        "pft" => (72.675,  1.205),
        "d_despot" => (27.185,  1.331),
        "d_pomcp" => (27.786,  1.340),
        "pomcp" => (27.980,  1.343),
        "limits" => (0.0, 80.0),
        "name" => "Sub Hunt"
    ),

    "lasertag" => Dict(
        "qmdp" => (-10.545, 0.195),
        "despot" => (-8.745, 0.180),
        "d_despot" => (-8.745, 0.180),
        "pomcpow" => (-9.951, 0.176),
        "pomcpdpw" => (-10.746, 0.189),
        "pft" => (-11.910, 0.161),
        "d_pomcp" => (-14.276, 0.211),
        "limits" => (-20.0, -8.0),
        "name" => "Laser Tag"
    ),

    "vdptag" => Dict(
        "manage_uncertainty" => (14.228, 1.621),
        "pomcpow" => (38.650, 0.848),
        "to_next" => (-15.811, 0.438),
        "pft" => (34.617, 0.870),
        "pomcpdpw" => (-11.674, 0.516),
        "d_despot" => (-13.107, 0.549),
        "d_pomcp" => (-18.505, 0.265),
        # "pomcpow" => (38.1, 0.8),
        # "pomcpdpw" => (-18.9, 0.2),
        # "pft" => (32.9, 0.9),
        # "d_pomcp" => (-18.5, 0.2),
        # "d_despot" => (-16.2, 0.4),
        "limits" => (-20.0, 40.0),
        "name" => "VDP Tag"
    )

)
=#