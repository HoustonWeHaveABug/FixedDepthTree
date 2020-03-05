# FixedDepthTree
Create and browse a tree of given depth and number of nodes.
 
The FixedDepthTree class allows to build a balanced tree given two arguments: depth (D) and number of nodes (N>.

The parent nodes have either \<BranchingMin\> children or \<BranchingMax\> children, with \<BranchingMax\> - \<BranchingMin\> = 1. The leaf nodes are all created at the lowest level of the tree.

The constructor does not build the tree node by node but creates a canonical representation of the tree, level by level. This allows to create trees with a huge number of nodes as the runtime complexity is O(D).

Example for D = 4 and N = 20

> LevelsN 3 NodesN 20 BranchingMin 2 BranchingMax 3\
> StartMin 1 GroupsMin 1 StartMax 3 GroupsMax 0\
> StartMin 3 GroupsMin 1 StartMax 5 GroupsMax 1\
> StartMin 8 GroupsMin 3 StartMax 14 GroupsMax 2

That is the canonical form of the below tree:

>         ---- 0 ----\
>       /             \\\
>      1           --- 2 -----\
>    /   \\       /     |       \\\
>   3     4     5      6        7\
> /  \  /  \  /  \  /  |  \  /  |  \\\
> 8  9 10 11 12 13 14 15 16 17 18 19
