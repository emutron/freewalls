/*
  Part of the AI for Games library 
 
 Copyright (c) 2011 Peter Lager
 
 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2.1 of the License, or (at your option) any later version.
 
 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General
 Public License along with this library; if not, write to the
 Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 Boston, MA  02111-1307  USA
 */


import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Iterator;
import java.util.LinkedList;

/**
 * 
 * Objects of this class represents graphs that can be used in games. <br>
 * 
 * The class maintains collections of nodes (vertices) and directed edges. <br> 
 * 
 * Each node should have a unique ID number, attempting to add a node which the 
 * same ID as a node already added to the graph will replace the existing node. <br>
 * 
 * An edge is specified by the id numbers to the 2 nodes that are to be joined. Each
 * edge is directed i.e. one-way, so to create a bidirectional (two-way) link between
 * the nodes requires two edges to be created. This does have the advantage that each
 * the cost of travelling between 2 nodes does not have to be the same in both 
 * directions. <br>
 * 
 * It is more efficient to add all the nodes first and then the edges but not essential. <br>
 * 
 * Attempting to add an edge where one or both of the connecting nodes do not yet exist
 * in the graph will be 'remembered' - this is called a floating edge. Once both nodes 
 * have been added to the graph then the floating edge will also be added to the graph. <br>
 * Floating edges are segregated from the graph edges to simply the graph searching 
 * algorithms. <br><br>
 * 
 * This arrangement is very flexible and can simplify the code needed to create the graph
 * at the expense of creating large numbers of floating edges that will never be added
 * to the graph. Once you have created the final graph it is recommended that the user
 * calls the compact method which simply deletes any floating edges and requests a 
 * garbage collection to release the memory. <br><br>
 * 
 * The classes
 * @see	    GraphNode
 * @see		GraphEdge
 * are the base classes used to store nodes and edges. These classes support
 * inheritance so you can provide more specialised classes for your graphs. <br>
 * 
 * The following classes can be used to search the graph.
 * 
 * @see	    GraphSearch_DFS
 * @see		GraphSearch_BFS
 * @see		GraphSearch_Dijkstra
 * @see		GraphSearch_Astar
 * 
 * <br>
 * 
 * @author Peter Lager
 */
public class Graph extends Object {
  // Data structures to hold nodes and edges
  protected LinkedHashMap<UUID, Wall> nodes;
  protected LinkedList<Graph> subGraphs;
  protected HashMap<Wall, LinkedList<GraphEdge>> edgeLists;
  // Data structure to hold floating edges.
  protected HashMap<UUID, LinkedList<FloatingEdge>> nodesToBe;

  protected boolean nodesFirst = false;

  /**
   	 * Create a graph with an initial capacity of 16 nodes.
   	 */
  public Graph() {
    this(16);
  }
  public Graph(Graph in) {
    Graph out = new Graph();
    for (Wall w : in.nodes.values ()) {
      out.addNode(w, false);
    }
    for (GraphEdge edge : in.getAllEdgeArray ()) {
      out.addEdge(edge.from.ID, edge.to.ID, 1);
    }
    nodes = out.nodes;
    edgeLists = out.edgeLists;
  }


  /**
   	 * Create a graph with an initial capacity based on an estimate of 
   	 * the number of nodes to be added.
   	 * @param nbrNodes
   	 */
  public Graph(int nbrNodes) {
    nodes = new LinkedHashMap<UUID, Wall>(nbrNodes);
    edgeLists = new HashMap<Wall, LinkedList<GraphEdge>>(nbrNodes);
  }

  /**
   	 * Add a node to the list. The user must ensure that the node id is unique.
   
   	 * @param node
   	 */
  public void addNode(Wall node, boolean addNewEdge) {
    nodes.put(node.ID(), node);
    if (addNewEdge) {
      for (Wall w : nodes.values ()) {
        if (w.ID()!=node.ID()) {
          if (node.isConnected(w)) {
            addEdge(node.ID(), w.ID(), 1);
            addEdge(w.ID(), node.ID(), 1);
          }
        }
      }
    }
    if (nodesToBe != null)
      resolveFloatEdges(node);
  }
  /**
   * resets all edges for this node
   * @param node
   */
  void resetNode(Wall node) {
    //remove edges
    if (getAllNodesConnected (node)!=null) {
      nodes.put(node.ID, node);
      for (Wall w : getAllNodesConnected (node)) {
        removeEdge(w.ID, node.ID);
        removeEdge(node.ID, w.ID);
      }

      //and reset them
      for (Wall w : nodes.values ()) {
        if (w.ID()!=node.ID()) {
          if (node.isConnected(w)) {
            addEdge(node.ID(), w.ID(), 1);
            addEdge(w.ID(), node.ID(), 1);
          }
        }
      }
    }
  }

  /**
   * Draws all Walls in the node list.
   * @param node
   */
  void draw() {
    int c = 0;
    int b = 0;
    Wall a = new Wall();
    for (Wall w : nodes.values ()) {
      if (showWallConn==b) {
        a = w;
        break;
      }
      b++;
    }
    Graph connected = getGroup(a.ID);
    //println("adsasf "+connected.nodes.size());
    for (Wall w : nodes.values ()) {
      pushStyle();
      if (getEdgeArray(w.ID()).length==0) {
        fill(150, 0, 0);
      }
      if (c==showWallConn) {
        fill(0, 150, 0);
      }
      int subCount = subGraphs.size();
      int subGroup = 0;
      for (Graph g : subGraphs) {
        for (Wall v : g.nodes.values ())
          if (v.ID==w.ID) {
            fill(0, 0, 100+ (subGroup/(float)subCount)*155.0);
            break;
          }
        subGroup++;
      }
      w.draw(false);
      popStyle();
      c++;
    }
  }

  /**
   * setNeighbours
   this method should be called after changing a wall position  to get
   all edges for the new position
   * @param node
   */
  /**
   * get all connected to this node
   * @param node
   */

  Graph getGroup(UUID ID) {
    Graph nodesTested = new Graph();
    Graph group = new Graph();
    ArrayList<Wall> neighbours = new ArrayList<Wall>();
    neighbours.add(nodes.get(ID));
    group.addNode(nodes.get(ID), false);
    LinkedList<Wall> connected = new LinkedList<Wall>();
    //getEdge(from, to) should not return null if two are connected
    int groupSize0 = 0;
    int groupSize1 = 1;
    int c = 0;
    while (groupSize0!=groupSize1) {
      ArrayList<Wall> newNeighbours = new ArrayList<Wall>();
      groupSize0 = group.nodes.size();
      if (getAllNodesConnected(nodes.get(ID))==null) {
        group = null;
        break;
      }
      for (Wall test : neighbours) {
        connected = getAllNodesConnected(test);
        newNeighbours.addAll(connected);
        //newNeighbours = nodesToTest.getAllNodesConnected(test);
        nodesTested.addNode(test, false);
      }
      neighbours.clear();
      for (Wall w : newNeighbours) {
        if (nodesTested.nodes.get(w.ID)==null) {
          group.addNode(w, false);
          neighbours.add(w);
        }
        //nodesToTest.removeNode(w.ID);
      }
      //nodesToTest.remove();
      groupSize1 = group.nodes.size();
      c++;
    }
    return group;
  }
  /**
   *sets the field subgraphs
   * @param 
   */
  void setSubGraphs() {
    int c = 0;
    LinkedList<Graph> groupedNodes = new LinkedList<Graph>();
    Graph nodesTested = new Graph();
    Wall startFromWall = new Wall();
    while (nodesTested.nodes.size ()<nodes.size()) {

      //just get throug my nodes and get the first one not yet tested
      for (Wall w : nodes.values ()) {
        if (nodesTested.nodes.get(w.ID)==null) {
          startFromWall = w;
          break;
        }
      }
      Graph group = getGroup(startFromWall.ID);
      for (Wall w : group.nodes.values ()) {
        nodesTested.addNode(w, false);
      }
      groupedNodes.add(group);

      c++;
    }
    subGraphs = groupedNodes;
  }
  /**
   *returns the Graph the Wall is containing
   */
  Graph getMyGraph(UUID ID) {
    Graph myGraph = new Graph();
    boolean found = false;
    for (Graph g : subGraphs) {
      for (Wall w : g.nodes.values ()) {
        found=w.ID==ID;
        if (found) {
          break;
        }
      }
      if (found) {
        myGraph=g;
        break;
      }
    }
    return myGraph;
  }
  /**
   	 * This method is called every time a node is added to the graph. It will 
   	 * update all floating edges and where possible adding the floating edge
   	 * to the graph. 
   	 * @param node a node to be added to the graph (must not be null)
   	 */
  protected void resolveFloatEdges(Wall node) {
    UUID nodeID = node.ID();
    LinkedList<FloatingEdge> elist = nodesToBe.get(nodeID);
    if (elist != null) {
      Iterator<FloatingEdge> iter = elist.iterator();
      while (iter.hasNext ()) {
        FloatingEdge edge = iter.next();
        if (edge.fromID == nodeID)
          edge.from = node;
        else if (edge.toID == nodeID)
          edge.to = node;
        if (edge.from != null && edge.to != null) {
          addValidEdge(new GraphEdge(edge.from, edge.to, edge.cost));
          iter.remove();
        }
      }
      // See if we have emptied the edgelist for this node id
      if (elist.isEmpty()) {
        nodesToBe.remove(nodeID);
        // Edge list has been removed so see if there are
        // any more 'nodes to be' if not dump nodesToBe 
        if (nodesToBe.isEmpty())
          nodesToBe = null;
      }
    }
  }

  /**
   	 * If the node exists remove it and all edges that start
   	 * or end at this node.
   	 * @param nodeID id of the node to remove
   	 * @return true if the node was removed else false
   	 */
  public boolean removeNode(UUID nodeID) {
    Wall node = nodes.get(nodeID);
    if (node == null)
      return false;
    edgeLists.remove(node);	// remove edges from this node
    nodes.remove(nodeID);	// remove node
    // get a list of all edges that go to the node we just removed
    GraphEdge[] edges = getAllEdgeArray();
    ArrayList<GraphEdge> edgesToRemove = new ArrayList<GraphEdge>();
    for (int i = 0; i < edges.length; i++) {
      if (edges[i].to().ID() == nodeID)
        edgesToRemove.add(edges[i]);
    }
    // Now remove these edges.
    for (GraphEdge edge : edgesToRemove)
      edgeLists.get(edge.from).remove(edge);
    return true;
  }

  /**
   	 * Get a node with a given id.
   	 * 
   	 * @param id
   	 * @return the node if it exists else null
   	 */
  public Wall getNode(UUID ID) {
    return nodes.get(ID);
  }
  /**
   * returns an arraylist of walls
   * 
   * @param id
   * @return the node if it exists else null
   */
  ArrayList<Wall> getAllNodes() {
    ArrayList<Wall> allNodes = new ArrayList<Wall>();
    for (Wall w : nodes.values () ) {
      allNodes.add(w);
    }
    return allNodes;
  }
  LinkedHashMap<UUID, Wall> nodes() {
    LinkedHashMap<UUID, Wall> out = new LinkedHashMap<UUID, Wall>(nodes.size());
    for (Wall w : nodes.values ()) {
      out.put(w.ID, w);
    }
    return out;
  }
  //get all Walls connect to a specific wall
  LinkedList<Wall> getAllNodesConnected(Wall node) {
    LinkedList<GraphEdge> edgeList = edgeLists.get(node); 
    LinkedList<Wall> allNodes = new LinkedList<Wall>();
    if (edgeList!=null) {
      for (GraphEdge edge : edgeList) {
        allNodes.add(edge.to);
      }

      return allNodes;
    } else {
      return null;
    }
  }
  /**
   *boolean functions
   */
  /**
   *tells you if this group is grounded, meaning that
   *at least one wall is on ground
   */
  boolean isGrounded() {
    boolean grounded = false;
    for (Wall w : nodes.values ()) {
      grounded = w.isOnGround();
      if (grounded) {
        break;
      }
    }
    return grounded;
  } 



  /**
   	 * Does a node with a given id exist?
   	 * @param id
   	 * @return true if the node exists else false
   	 */
  public boolean hasNode(UUID ID) {
    return nodes.get(ID) != null;
  }

  /**
   	 * Locate and return the first node encountered that is within a
   	 * stated distance of a position at [x,y,z]
   	 * 
   	 * @param x
   	 * @param y
   	 * @param z
   	 * @param maxDistance only consider a node that is with this distance of [x,y,z]
   	 * @return the node if it meets the distance criteria else null
   	 
   	public Wall getNodeAt(double x, double y, double z, double maxDistance){
   		double d2 = maxDistance * maxDistance, dx2, dy2, dz2;
   		Collection<Wall> c = nodes.values();
   		for(Wall node : c){
   			dx2 = (node.x() - x)*(node.x() - x);
   			dy2 = (node.y() - y)*(node.y() - y);
   			dz2 = (node.z() - z)*(node.z() - z);
   			if(dx2+dy2+dz2 < d2)
   				return node;
   		}	
   		return null;
   	}
   */
  /**
   	 * get the number of nodes in the graph
   	 * @return the number of nodes in this graph
   	 */
  public int getNbrNodes() {
    return nodes.size();
  }

  /**
   	 * Add a unidirectional edge to the graph.
   	 * 
   	 * @param fromID the ID number of the from node
   	 * @param toID the ID number of the to node
   	 * @param cost cost from > to
   	 * @return true if the edge was added else false
   	 */
  public boolean addEdge(UUID fromID, UUID toID, double cost) {
    Wall fromNode = nodes.get(fromID); 
    Wall toNode = nodes.get(toID); 
    GraphEdge ge; 
    if (fromNode != null && toNode != null) {
      ge = new GraphEdge(fromNode, toNode, cost); 
      addValidEdge(ge); 
      return true;
    }
    FloatingEdge floatEdge = new FloatingEdge(fromID, toID, fromNode, toNode, cost); 
    if (fromNode == null)
      rememberFloatingEdge(fromID, floatEdge); 
    if (toNode == null)
      rememberFloatingEdge(toID, floatEdge); 
    return false;
  }

  /**
   	 * Add bidirectional link with the costs indicated.
   	 * 
   	 * @param fromID the ID number of the from node
   	 * @param toID the ID number of the to node
   	 * @param costOutward cost from > to
   	 * @param costInward cost to > from
   	 * @return true if the edge was added else false
   	 */
  public boolean addEdge(UUID fromID, UUID toID, double costOutward, double costInward) {
    boolean added = false; 
    added = addEdge(fromID, toID, costOutward); 
    added &= addEdge(toID, fromID, costInward); 
    return added;
  }

  /**
   	 * This method is called to add a validated edge to the graph.
   	 * @param edge the validated edge to add.
   	 */
  protected void addValidEdge(GraphEdge edge) {
    Wall fromNode = edge.from(); 
    LinkedList<GraphEdge> geList = edgeLists.get(fromNode); 
    if (geList == null) {
      geList = new LinkedList<GraphEdge>(); 
      edgeLists.put(fromNode, geList);
    }
    geList.add(edge);
  }

  /**
   	 * This method is used to remember floating edges.
   	 * @param id
   	 * @param floatEdge
   	 */
  protected void rememberFloatingEdge(UUID ID, FloatingEdge floatEdge) {
    if (nodesToBe == null)
      nodesToBe = new HashMap<UUID, LinkedList<FloatingEdge>>(); 
    if (!nodesToBe.containsKey(ID))
      nodesToBe.put(ID, new LinkedList<FloatingEdge>()); 
    nodesToBe.get(ID).add(floatEdge);
  }

  //	public void unusedFloatingEdges(){
  //		System.out.println("Unresolved floating edges");
  //		int count = 0;
  //		if(nodesToBe != null){
  //			Collection<LinkedList<FloatingEdge>> c = nodesToBe.values();
  //			for(LinkedList<FloatingEdge> list : c){
  //				for(FloatingEdge fedge : list){
  //					System.out.println(fedge);
  //					count++;
  //				}
  //			}
  //		}
  //		System.out.println("======  " + count +"  ============================");
  //	}

  /**
   	 * Clear out all remaining floating edges.
   	 */
  public void compact() {
    if (nodesToBe != null) {
      Collection<LinkedList<FloatingEdge>> c = nodesToBe.values(); 
      for (LinkedList<FloatingEdge> list : c)
        list.clear(); 
      nodesToBe.clear(); 
      nodesToBe = null; 
      System.gc(); 	// request garbage collection
    }
  }

  /**
   	 * Get the edge between 2 nodes. <br>
   	 * If either node does not exist or there is no edge
   	 * exists between them then the method returns null.
   	 * @param fromID ID for the from node
   	 * @param toID ID for the to node
   	 * @return the edge or null if it doesn't exist
   	 */
  public GraphEdge getEdge(UUID fromID, UUID toID) {
    Wall fromNode = nodes.get(fromID); 
    Wall toNode = nodes.get(toID); 
    if (fromNode == null || toNode == null)
      return null; 
    LinkedList<GraphEdge> edgeList = edgeLists.get(fromNode); 
    for (GraphEdge ge : edgeList) {
      if (ge.to() == toNode)
        return ge;
    }
    return null;
  }

  //publich GraphEdge getEdgesfromNode(

  /**
   	 * Get the cost of traversing an edge between 2 nodes. <br>
   	 * If either node does not exist or there is no edge
   	 * exists between them then the method returns a value <0.
   	 * @param fromID ID for the from node
   	 * @param toID ID for the to node
   	 * @return the edge or null if it doesn't exist
   	 */
  public double getEdgeCost(UUID fromID, UUID toID) {
    Wall fromNode = nodes.get(fromID); 
    Wall toNode = nodes.get(toID); 
    if (fromNode == null || toNode == null)
      return -1; 
    LinkedList<GraphEdge> edgeList = edgeLists.get(fromNode); 
    for (GraphEdge ge : edgeList) {
      if (ge.to() == toNode)
        return ge.getCost();
    }
    return -1;
  }

  /**
   	 * Remove an edge between 2 nodes. <br>
   	 * This will delete the edge from one node to another
   	 * but does not remove any return edge. <br>
   	 * To remove a 'bidirectional route' between nodes
   	 * 22 and 33 then you must call this method twice e.g.
   	 * <code>
   	 * graph.removeEdge(22, 33);
   	 * graph.removeEdge(33, 22);
   	 * </code>
   	 * @param fromID ID for the from node
   	 * @param toID ID for the to node
   	 * @return true if an edge has been removed
   	 */
  public boolean removeEdge(UUID fromID, UUID toID) {
    GraphEdge ge = getEdge(fromID, toID); 
    if (ge != null) {
      Wall fromNode = nodes.get(fromID); 
      edgeLists.get(fromNode).remove(ge); 
      return true;
    }
    return false;
  }

  /**
   	 * Sees whether the graph has this edge
   	 * @param from node id of from-node
   	 * @param to node if of to-node
   	 * @return true if the graph has this node else false
   	 */
  public boolean hasEdge(UUID from, UUID to) {
    Wall fromNode = nodes.get(from); 
    Wall toNode = nodes.get(to); 
    if (fromNode != null && toNode != null) {
      LinkedList<GraphEdge> geList = edgeLists.get(fromNode); 
      Iterator<GraphEdge> iter = geList.iterator(); 
      while (iter.hasNext ()) {
        if (iter.next().to() == toNode)
          return true;
      }
    }
    return false;
  }

  /**
   	 * Gets a list of GraphEdges from this node. <br>
   	 * Used by graph search classes.
   	 * 
   	 * @param nodeID id of the node where the edges start from
   	 * @return a list of departing edges (the list will be empty if no departing edges)
   	 */
  public LinkedList<GraphEdge> getEdgeList(UUID nodeID) {
    return getEdgeList(nodes.get(nodeID));
  }

  /**
   	 * Gets a list of GraphEdges from this node. <br>
   	 * Used by graph search classes.
   	 * @param node the node where the edges start from
   	 * @return a list of departing edges (the list wil be empty if no departing edges)
   	 */
  public LinkedList<GraphEdge> getEdgeList(Wall node) {
    LinkedList<GraphEdge> edgeList = null; 
    if (node != null)
      edgeList = edgeLists.get(node); 
    // Can't find edge list so return empty list
    if (edgeList == null)
      edgeList = new LinkedList<GraphEdge>(); 
    return edgeList;
  }

  /**
   	 * Will return an array of all the GraphEdges in the graph. <br>
   	 * The type of each element in the array will be of type GraphEdge
   	 */
  public GraphEdge[] getAllEdgeArray() {
    return getAllEdgeArray(new GraphEdge[0]);
  }
  /**
   * Will return the number of all edges
   * 
   */
  int EdgeCount() {
    return getAllEdgeArray().length;
  }

  /**
   	 * Will return an array of all the GraphEdges in the graph. <br>
   	 * The type of each element in the array will be of type Object 
   	 * if the parameter is null otherwise it is T (where T is GraphEdge
   	 * or any class derived from GraphEdge.
   	 * 
   	 * @param <T>
   	 * @param array a zero length array of Wall or any derived class.
   	 */
  @SuppressWarnings("unchecked")
    public <T extends GraphEdge> T[] getAllEdgeArray(T[] array) {
      if (array == null)
        array = (T[]) new Object[0]; 
      LinkedList<GraphEdge> edges = new LinkedList<GraphEdge>(); 
      Collection<LinkedList<GraphEdge>> c = edgeLists.values(); 
      for (LinkedList<GraphEdge> geList : c)
        edges.addAll(geList); 
      return edges.toArray(array);
    }

  /**
   	 * Will return an array of all the GraphEdges that start from the node. <br>
   	 * The type of each element in the array will be of type GraphEdge
   	 * 
   	 * @param from the node where the edges start from
   	 */
  public GraphEdge[] getEdgeArray(UUID from) {
    return getEdgeArray(from, new GraphEdge[0]);
  }

  /**
   	 * Will return an array of all the GraphEdges that start from the node. <br>
   	 * The type of each element in the array will be of type Object
   	 * if the parameter is null otherwise it is T (where T is GrahEdge
   	 * or any class that extends GrahEdge.
   	 * 
   	 * @param <T>
   	 * @param from the node where the edges start from
   	 * @param array a zero length array of Wall or any derived class.
   	 */
  @SuppressWarnings("unchecked")
    public <T extends GraphEdge> T[] getEdgeArray(UUID from, T[] array) {
      if (array == null)
        array = (T[]) new Object[0]; 
      LinkedList<GraphEdge> edges = getEdgeList(from); 
      return edges.toArray(array);
    }

  /**
   	 * Will return an array of all the Walls in the graph. <br>
   	 * The type of each element in the array will be of type Wall
   	 * 
   	 */
  public Wall[] getNodeArray() {
    return getNodeArray(new Wall[0]);
  }

  /**
   	 * Will return an array of all the Walls in the graph. <br>
   	 * The type of each element in the array will be of type Object
   	 * if the parameter is null otherwise it is T (where T is Wall
   	 * or any class that extends Wall.
   	 * 
   	 * @param <T>
   	 * @param array a zero length array of Wall or any derived class.
   	 */
  @SuppressWarnings("unchecked")
    public <T extends Wall> T[] getNodeArray(T[] array) {
      if (array == null)
        array = (T[]) new Object[0]; 
      Collection<Wall> c = nodes.values(); 
      return c.toArray(array);
    }

  /**
   	 * Inner class to represent floating edges.
   	 * 
   	 * @author Peter Lager
   	 *
   	 */
  private class FloatingEdge {

    public UUID fromID; 
    public UUID toID; 
    public Wall from; 
    public Wall to; 

    double cost = 1.0; 
    /**
     		 * @param fromID
     		 * @param toID
     		 * @param from
     		 * @param to
     		 * @param cost
     		 */
    public FloatingEdge(UUID fromID, UUID toID, Wall from, Wall to, 
    double cost) {
      super(); 
      this.fromID = fromID; 
      this.toID = toID; 
      this.from = from; 
      this.to = to; 
      this.cost = cost;
    }

    /**
     		 * Used for debugging only.
     		 */
    public String toString() {
      String s = "FE "; 
      s += fromID + ((from == null) ? " (-)" : " (+)"); 
      s += toID + ((to == null) ? " (-)" : " (+)"); 
      s += "    cost= " + cost; 
      return s;
    }
  }
}

