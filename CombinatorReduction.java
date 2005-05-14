import java.util.LinkedList;

public class CombinatorReduction {

	/**
	 * One node of the Combinator parse tree. If it's a leaf, it's a combinator,
	 * otherwise it has two children.
	 */	
	private class Node {
		boolean isLeaf, isHead;
		char c;
		Node l, r;

		/**
		 * Creates a new leaf node.
		 * @param c The combinator at this node.
		 */
		public Node(char c) {
			isLeaf = true; this.c = c; isHead = false;
		}
		
		/**
		 * Creates a new non-leaf node.
		 * @param l The left subtree.
		 * @param r The right subtree.
		 */
		public Node(Node l, Node r) {
			isLeaf = false; this.l = l; this.r = r; isHead = false;
		}
		
		/**
		 * @return A deep copy of this node and its subtrees.
		 */
		public Node copy() {
			if (isLeaf) return new Node(c); else return new Node(l.copy(), r.copy());
		}
		
		/**
		 * Returns a LaTeX/pstricks string representing this subtree.
		 */
		public String toString() {
			String line = isHead ? "solid" : "none";
			if (isLeaf) return "\\Tcircle[linestyle=" + line + "]{" + c + "}"; else
				return "\\pstree{\\TR{}}{" + l + r + "}";
		}
		
		/**
		 * Returns a combinator string representing this subtree. 
		 */
		public String print() {
			if (isLeaf) return c + ""; else
				return l.print() + (r.isLeaf ? "" : "(") + r.print() +
					(r.isLeaf ? "" : ")");
		}
		
		/**
		 * Sets the isHead field on this node and all subtrees such that
		 * there is exactly one node (the head node) for which it is true.
		 * @param isLeftSubtree True if this is the left subtree of all parents.
		 */
		public void setHead(boolean isLeftSubtree) {
			isHead = isLeftSubtree && isLeaf;
			if (l != null) l.setHead(isLeftSubtree);
			if (r != null) r.setHead(false);
		}
	}

	// The parse tree	
	Node current = null;
	
	
	/**
	 * Performs a single combinator head reduction.
	 * @return True if head normal form is reached, false otherwise.
	 */
	public boolean reduce() {
		Node n = current, par1 = null, par2 = null, par3 = null;
		while (!n.isLeaf) {
			par3 = par2; par2 = par1; par1 = n; n = n.l;
		}
		switch (n.c) {
			case 'S':
				if (par3 == null) return true;
				// S combinator reduction
				Node x = par3.r;
				par2.l = par1.r;
				par1.l = par2.r;
				par3.r = par1;
				par1.r = x;
				par2.r = x.copy();
				break;

			case 'K':
				if (par2 == null) return true;
				if (par3 == null) current = par1.r; // K combinator reduction at root
					else par3.l = par1.r; // K combinator reduction in subtree
				break;
		}
		return false;
	}

	
	/**
	 * Creates a new CombinatorReduction object. Parses a combinator string,
	 * performs up to the given number of reduction steps, and prints LaTeX
	 * code for the whole reduction process to standard output.
	 * @param s The combinator string to parse.
	 * @param steps Maximum number of reduction steps to perform.
	 */
	public CombinatorReduction(String s, int steps) {
		Node old;
		LinkedList stack = new LinkedList();
		
		for (int i=0; i<s.length(); i++) {
			char c = s.charAt(i);
			switch (c) {
				case 'S':
				case 'K':
					if (current == null) current = new Node(c); else
						current = new Node(current, new Node(c));
					break;
				case '(':
					stack.add(current);
					current = null;
					break;
				case ')':
					old = (Node) stack.removeLast();
					if (old != null) current = new Node(old, current);
					break;
			}
		}
		
		System.out.println("\\documentclass[a4paper,landscape]{article}");
		System.out.println("\\usepackage{pstricks,pst-tree,pst-node}");
		System.out.println("\\usepackage[landscape]{geometry}");
		System.out.println("\\begin{document}");
		for (int i=1; i<=steps; i++) {
			current.setHead(true);
			System.out.println("\\newpage");
			System.out.println("Step " + i + ": " + current.print() + "\\par");
			System.out.println("\\pstree[levelsep=1cm]{\\TR{}}{" + current + "}");
			System.out.println("");
			if (reduce()) {
				System.out.println("Head normal form reached.");
				break;
			}
		}
		System.out.println("\\end{document}");
	}

	/**
	 * Main program.
	 */
	public static void main(String[] args) {
		if (args.length < 2) {
			System.out.println("Usage: java CombinatorReduction combinator-string number-of-steps");
			return;
		}
		int steps = Integer.parseInt(args[1]);
		new CombinatorReduction(args[0], steps);
	}
}
