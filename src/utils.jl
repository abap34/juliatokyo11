using Images
using FileIO
using ImageInTerminal
using OhMyREPL


function id_generator(; init=100000)
    id = init
    return () -> (id += 1)
end

struct Node
    id::Int
    label::String
end

struct Edge
    label::String
    source::Node
    target::Node
end

struct Graph
    nodes::Vector{Node}
    edges::Vector{Edge}
    gen_id::Function
    function Graph()
        nodes = Node[]
        edges = Edge[]
        gen_id = id_generator()
        new(nodes, edges, gen_id)
    end
end


function add_node!(graph::Graph, label::String)
    node = Node(graph.gen_id(), label)
    push!(graph.nodes, node)
    return node
end

function add_edge!(graph::Graph, label::String, source::Node, target::Node)
    edge = Edge(label, source, target)
    push!(graph.edges, edge)
    return edge
end

function to_graph(f::Expr)::Graph
    graph = Graph()
    root = add_node!(graph, string(f.args[1]))
    for arg in f.args[2:end]
        dfs!(arg, root, graph)
    end
    return graph
end

function dfs!(f::Expr, parent::Node, graph::Graph)
    @assert f.head == :call
    op = f.args[1]
    node = add_node!(graph, string(op))
    add_edge!(graph, "", parent, node)
    for arg in f.args[2:end]
        dfs!(arg, node, graph)
    end
end

function dfs!(f::Symbol, parent::Node, graph::Graph)
    node = add_node!(graph, string(f))
    add_edge!(graph, "", parent, node)
end

function dfs!(f::Int64, parent::Node, graph::Graph)
    node = add_node!(graph, string(f))
    add_edge!(graph, "", parent, node)
end



function to_graphviz(g::Graph)::String
    s = """digraph G {
        node [shape=plaintext, fontname=\"Courier New\", fontsize=30, shape=none];
        edge [fontname=\"Courier New\", fontsize=12, penwidth=0.5, arrowsize=0.5];
    """
    for node in g.nodes
        s *= "    $(node.id) [label=\"$(node.label)\"];\n"
    end
    for edge in g.edges
        s *= "    $(edge.source.id) -> $(edge.target.id) [label=\"$(edge.label)\"];\n"
    end
    s *= "}\n"
    return s
end


function plot_graphviz(src::String)
    f = open("tmp.dot", "w")
    write(f, src)
    close(f)
    run(`dot -Tpng tmp.dot -o tmp.png`)
    run(`rm tmp.dot`)
    img = load("tmp.png")
    run(`rm tmp.png`)
    return img
end


function to_latex(ex::Expr)::String
    @assert ex.head == :call
    op = ex.args[1]
    if op == :+
        return "\\left(" * to_latex(ex.args[2]) * " + " * to_latex(ex.args[3]) * "\\right)"
    elseif op == :-
        return "\\left(" * to_latex(ex.args[2]) * " - " * to_latex(ex.args[3]) * "\\right)"
    elseif op == :*
        return to_latex(ex.args[2]) * " \\cdot " * to_latex(ex.args[3])
    elseif op == :/
        return "\\dfrac{" * to_latex(ex.args[2]) * "}{" * to_latex(ex.args[3]) * "}"
    elseif op == :^
        inner = to_latex(ex.args[2])
        if length(inner) > 1
            inner = "\\left(" * inner * "\\right)"
        end
        return inner * "^{" * to_latex(ex.args[3]) * "}"
    else
        throw("Unknown operator $op")
    end
end


function to_latex(ex::Symbol)::String
    return string(ex)
end

function to_latex(ex::Int64)::String
    return string(ex)
end

macro plot(ex)
    return ex |> to_graph |> to_graphviz |> plot_graphviz
end

macro latexify(ex)
    return ex |> to_latex
end


function add(args)
    args = filter(x -> x != 0, args)
    if length(args) == 0
        return 0
    elseif length(args) == 1
        return args[1]
    else
        return Expr(:call, :+, args...)
    end
end

function sub(args)
    @assert length(args) == 2
    if args[2] == 0
        return args[1]
    else
        return Expr(:call, :-, args...)
    end
end

function mul(args)
    if 0 in args
        return 0
    end

    args = filter(x -> x != 1, args)
    # 全部 1 だった場合
    if length(args) == 0
        return 1
        # 一個だけ残った場合
    elseif length(args) == 1
        return args[1]
    else
        return Expr(:call, :*, args...)
    end
end

function div(args)
    @assert length(args) == 2
    if args[2] == 1
        return args[1]
    else
        return Expr(:call, :/, args...)
    end
end

function pow(args)
    @assert length(args) == 2
    if args[2] == 0
        return 1
    elseif args[2] == 1
        return args[1]
    else
        return Expr(:call, :^, args...)
    end
end



function derivative(ex::Expr)
    op = ex.args[1]
    if op == :+
        return add(derivative.(ex.args[2:end]))
    elseif op == :-
        return sub([
            derivative(ex.args[2]),
            derivative(ex.args[3])
        ])
    elseif op == :*
        if length(ex.args) == 3
            return add([
                mul([ex.args[2], derivative(ex.args[3])]),
                mul([derivative(ex.args[2]), ex.args[3]])
            ])
        else
            t = mul(ex.args[3:end])

            return add([
                mul([ex.args[2], derivative(t)]),
                mul([derivative(ex.args[2]), t])
            ])
        end
    elseif op == :/
        return div([
            sub([
                mul([derivative(ex.args[2]), ex.args[3]]),
                mul([ex.args[2], derivative(ex.args[3])])
            ]),
            pow([ex.args[3], 2])
        ])

    elseif op == :^
        @assert ex.args[3] isa Int64
        return mul([
            ex.args[3],
            pow([ex.args[2], ex.args[3] - 1]),
            derivative(ex.args[2])
        ])
    elseif op == :sin
        return mul([
            :cos,
            ex.args[2],
            derivative(ex.args[2])
        ])
    elseif op == :cos
        return mul([
            :sin,
            ex.args[2],
            derivative(ex.args[2])
        ])
    else
        error("not implemented")
    end
end

derivative(ex::Symbol) = 1

derivative(ex::Int64) = 0


macro derivative(ex)
    return derivative(ex)
end



# 参考にした実装: https://github.com/MikeInnes/diff-zoo/blob/master/src/utils.jl
# 元実装と違い、共通部分式を共有するようにしています (代入ありだと小さくなることを示すデモ用なので)
function to_wengert(ex::Int64, cashe, n, wlist, top)
    return ex
end

function to_wengert(ex::Symbol, cashe, n, wlist, top)
    return ex
end

function to_wengert(ex::Expr, cashe=Dict{Expr, Symbol}(), n=Ref(0), wlist=[], top=true)
    if haskey(cashe, ex) 
        return cashe[ex]    
    end
    args = map(x -> to_wengert(x, cashe, n, wlist, false), ex.args)
    sym = Symbol(:y, "_{", n[] += 1, "}")
    push!(wlist, (sym => Expr(ex.head, args...)))
    cashe[ex] = sym
    if top
        return wlist
    else
        return sym
    end
end