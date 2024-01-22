using Images
using FileIO
using ImageInTerminal
using OhMyREPL

struct Node
    id::Int
    label::String
end

struct Edge
    label::String
    source::Node
    target::Node
end

function id_generator()
    id = 0
    return ()->(id+=1)
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


macro plot(ex)
    return ex |> to_graph |> to_graphviz |> plot_graphviz
end

