import java.util.LinkedList;

public class CombinatorReduction {

	/**
	 * One node of the Combinator parse tree. If it's a leaf, it's a combinator,
	 * otherwise it has two children.
	 */	
	private class Node {
		boolean isLeaf, isHead;
		String name;
		Node l, r;
		public static final int UNKNOWN = 0;
		public static final int S = 1;
		public static final int K = 2;
		public static final int I = 3;
		public static final int B = 4;
		public static final int C = 5;
		public static final int S_PRIME = 6;
		public static final int B_PRIME = 7;
		public static final int C_PRIME = 8;
		public static final int Y = 9;

		/**
		 * Creates a new leaf node.
		 * @param c The combinator at this node.
		 */
		public Node(String name) {
			isLeaf = true; this.name = name; isHead = false;
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
		 * Provided this is a leaf node, determines the type of combinator
		 * from the node's name.
		 * @return One of the integer constants defined in this class.
		 */
		public int combinator() {
			boolean prime = (name.length() > 1) && (name.charAt(1) == '\'');
			switch (name.charAt(0)) {
				case 'S': if (prime) return S_PRIME; else return S;
				case 'K': return K;
				case 'I': return I;
				case 'B': if (prime) return B_PRIME; else return B;
				case 'C': if (prime) return C_PRIME; else return C;
				case 'Y': return Y;
			}
			return UNKNOWN;
		}
		
		/**
		 * @return A deep copy of this node and its subtrees.
		 */
		public Node copy() {
			if (isLeaf) return new Node(name); else return new Node(l.copy(), r.copy());
		}
		
		/**
		 * Returns a LaTeX/pstricks string representing this subtree.
		 */
		public String toString() {
			String line = isHead ? "solid" : "none";
			if (isLeaf) return "\\Tcircle[linestyle=" + line + "]{$" + print() + "$}"; else
			if (r == null) return "\\pstree[levelsep=1cm]{\\TR{}}{" + l + "}"; else
				return "\\pstree{\\TR{}}{" + l + r + "}";
		}
		
		/**
		 * Returns a combinator string representing this subtree. 
		 */
		public String print() {
			if (isLeaf) {
				String sup = "", sub = "";
				for (int i=1; i<name.length(); i++)
					if (name.charAt(i) == '\'') sup += "\\prime";
						else sub += name.charAt(i);
				String ret = name.charAt(0) +
					(sup.equals("") ? "" : "^{" + sup + "}") +
					(sub.equals("") ? "" : "_{" + sub + "}");
				if (combinator() != UNKNOWN) ret = "\\mathbf{" + ret + "}";
				return ret;
			} else
			if (r == null) return l.print(); else
				return l.print() + (r.isLeaf ? "" : "(") + r.print() +
					(r.isLeaf ? "" : ")");
		}
		
		/**
		 * Sets the isHead field on this node and all subtrees to false.
		 */
		public void setHead() {
			isHead = false;
			if (l != null) l.setHead();
			if (r != null) r.setHead();
		}
	}

	// The parse tree	
	private Node root = null;
	private LinkedList reduceStack;
	
	/**
	 * Determines the next combinator to reduce, starting from the given
	 * subtree root.
	 * @param root The tree root from which the search starts.
	 * @return true if a reduceable combinator is found in this subtree, false
	 * otherwise.
	 */
	private boolean findCurrent(LinkedList stack) {
		Node current = (Node) stack.getFirst();
		if (current.isLeaf) {
			// Leaf node
			switch (current.combinator()) {
				case Node.I: case Node.Y:
					current.isHead = (stack.size() >= 3); break;
				case Node.K:
					current.isHead = (stack.size() >= 4); break;
				case Node.S: case Node.B: case Node.C:
					current.isHead = (stack.size() >= 5); break;
				case Node.S_PRIME: case Node.B_PRIME: case Node.C_PRIME:
					current.isHead = (stack.size() >= 6); break;
			}
			if (current.isHead) reduceStack = (LinkedList) stack.clone();
			return current.isHead;
		} else {
			// Branch node
			stack.addFirst(current.l);
			boolean found = findCurrent(stack);
			stack.removeFirst();
			if (found) return true; else {
				LinkedList newStack = new LinkedList();
				newStack.addFirst(current);
				newStack.addFirst(current.r);
				return findCurrent(newStack);
			} 
		}
	}
	
	
	/**
	 * Performs a single combinator reduction.
	 */
	private void reduce() {
		Node n = (Node) reduceStack.get(0);
		Node a = (Node) reduceStack.get(1);
		Node b = (reduceStack.size() > 2) ? (Node) reduceStack.get(2) : null;
		Node c = (reduceStack.size() > 3) ? (Node) reduceStack.get(3) : null;
		Node d = (reduceStack.size() > 4) ? (Node) reduceStack.get(4) : null;

		switch (n.combinator()) {
			case Node.S: // S combinator reduction
				Node x = c.r;
				b.l = a.r;
				a.l = b.r;
				c.r = a;
				a.r = x;
				b.r = x.copy();
				break;
			case Node.K: // K combinator reduction
				if (c.l == b) c.l = a.r; else c.r = a.r;
				break;
			case Node.I: // I combinator reduction
				if (b.l == a) b.l = a.r; else b.r = a.r;
				break;
			case Node.B: // B combinator reduction
				c.l = a.r;
				b.l = b.r;
				b.r = c.r;
				c.r = b;
				break;
			case Node.C: // C combinator reduction
				b.l = a.r;
				a = c.r;
				c.r = b.r;
				b.r = a;
				break;
			case Node.S_PRIME: // S' combinator reduction
				c.l = a.r;
				a.l = b.r;
				a.r = d.r;
				b.r = d.r.copy();
				b.l = c.r;
				c.r = a;
				d.l = c;
				d.r = b;
				break;
			case Node.B_PRIME: // B' combinator reduction
				b.l = a.r;
				c.l = c.r;
				c.r = d.r;
				d.l = b;
				d.r = c;
				break;
			case Node.C_PRIME: // C' combinator reduction
				b.l = b.r;
				b.r = d.r;
				c.l = a.r;
				d.r = c.r;
				c.r = b;
				d.l = c;
				break;
			case Node.Y: // Y combinator reduction
				a.l = a.r;
				a.r = new Node(new Node(n.name), a.l.copy());
				break;
		}
	}
	
	/**
	 * Determines if a character belongs to a combinator or variable as a
	 * suffix.
	 * @param c The character to test.
	 * @return True if it is a suffix character, false if not.
	 */
	private boolean isSuffixCharacter(char c) {
		return (c == '\'') || (c == '0') || (c == '1') || (c == '2') ||
			(c == '3') || (c == '4') || (c == '5') || (c == '6') ||
			(c == '7') || (c == '8') || (c == '9');
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
				case ' ':
					break;
				case '(':
					stack.add(root);
					root = null;
					break;
				case ')':
					old = (Node) stack.removeLast();
					if (old != null) root = new Node(old, root);
					break;
				default:
					String name = c + "";
					while ((i+1 < s.length()) && isSuffixCharacter(s.charAt(i+1))) {
						i++; name += s.charAt(i);
					}
					if (root == null) root = new Node(name); else
						root = new Node(root, new Node(name));
					break;
			}
		}
		root = new Node(root, null); // sentinel
		
		System.out.println("\\documentclass[a4paper,landscape]{article}");
		System.out.println("\\usepackage{pstricks,pst-tree,pst-node}");
		System.out.println("\\usepackage[landscape]{geometry}");
		System.out.println("\\begin{document}");
		for (int i=1; i<=steps; i++) {
			root.setHead();
			LinkedList current = new LinkedList();
			current.add(root);
			boolean found = findCurrent(current);
			System.out.println("\\newpage");
			System.out.println("Step " + i + ": $" + root.print() + "$\\par" + root);
			System.out.println("");
			if (!found) {
				System.out.println("Normal form reached.");
				break;
			}
			reduce();
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
