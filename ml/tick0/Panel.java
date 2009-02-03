import java.util.ArrayList;
import java.util.NoSuchElementException;
import java.io.*;
import java.awt.Graphics;
import java.awt.event.*;
import javax.swing.JPanel;
import javax.swing.JOptionPane;

/**
 * A panel which can hold a collection of ClassBox objects.
 * @author Martin Kleppmann
 */
public class Panel extends JPanel implements MouseListener, 
		MouseMotionListener {

	private ArrayList classes;
	private boolean removeClassMode, addMethodMode, removeMethodMode;
	private int lastX, lastY;
	private ClassBox dragBox;
	
	/**
	 * Constructs a new panel.
	 */
	public Panel() {
		classes = new ArrayList();
		removeClassMode = false;
		addMethodMode = false;
		removeMethodMode = false;
		dragBox = null;
	}
	
	/**
	 * Empties the panel.
	 */
	public void clear() {
		classes.clear();
	}
	
	/**
	 * Saves the contents of the panel to an output stream.
	 * @param output The output stream.
	 */
	public void writeStream(ObjectOutputStream output) {
		try {
			output.writeObject(classes);
		} catch (IOException e) {}
	}
	
	/**
	 * Reads the contents of the panel from an input stream.
	 * @param input The input stream.
	 */
	public void readStream(ObjectInputStream input) {
		try {
			classes = (ArrayList) input.readObject();
		} catch (IOException e) {
		} catch (ClassNotFoundException e) {}
		repaint();
	}
	
	/**
	 * Adds a new class box to the panel.
	 * @param c The new box object.
	 */
	public void addClass(ClassBox c) {
		classes.add(c);
		repaint();
	}
	
	/**
	 * Removes a class from the panel.
	 * @param c The box object to be removed.
	 * @throws NoSuchElementException The box does not exist.
	 */
	public void removeClass(ClassBox c) throws NoSuchElementException {
		int i = classes.indexOf(c);
		if (i < 0) throw new NoSuchElementException(); else
		classes.remove(i);
		removeClassMode = false;
		repaint();
	}

	/**
	 * Adds a method to the given class by querying for the new name.
	 * @param c The class to which a method should be added.
	 */	
	public void addMethod(ClassBox c) {
		String meth = (String) JOptionPane.showInputDialog(this, 
			"Please specify the name of the new method.", "Add Method", 
			JOptionPane.QUESTION_MESSAGE, null, null, "");
		if (meth != null) c.methods.add(meth);
		addMethodMode = false;
		repaint();
	}
	
	/**
	 * Removes a method from a given class by letting the user select
	 * one of its existing methods.
	 * @param c The class from which a method should be removed.
	 */
	public void removeMethod(ClassBox c) {
		if (c.methods.size() == 0) return;
		String meth = (String) JOptionPane.showInputDialog(this, 
			"Please select the method to be removed.", "Remove method", 
			JOptionPane.QUESTION_MESSAGE, null, c.methods.toArray(),
			c.methods.get(0));
		if (meth != null) c.methods.remove(meth);
		removeMethodMode = false;
		repaint(); 
	}
	
	/**
	 * Specifies that the next mouse click should remove a class
	 * from the panel.
	 */
	public void setRemoveClassMode() {
		removeClassMode = true;
		addMethodMode = false;
		removeMethodMode = false;
	}

	/**
	 * Specifies that the next mouse click should add a method
	 * to the selected class in the panel.
	 */
	public void setAddMethodMode() {
		removeClassMode = false;
		addMethodMode = true;
		removeMethodMode = false;
	}
	
	/**
	 * Specifies that the next mouse click should remove a method
	 * from the selected class in the panel.
	 */
	public void setRemoveMethodMode() {
		removeClassMode = false;
		addMethodMode = false;
		removeMethodMode = true;
	}

	/**
	 * Determines which box is located at given panel coordinates. 
	 * @param x X coordinate in pixels.
	 * @param y Y coordinate in pixels.
	 * @return The box at the given location, or null if none is there.
	 */	
	public ClassBox getAtPosition(int x, int y) {
		ClassBox c;
		for (int i=0; i < classes.size(); i++) {
			c = (ClassBox) classes.get(i);
			if (c.rect.contains(x, y)) return c;
		}
		return null;
	}
	
	/**
	 * Repaints the component.
	 */
	public void paintComponent(Graphics g) {
		g.clearRect(0, 0, getWidth(), getHeight());
		for (int i=0; i < classes.size(); i++)
			((ClassBox) classes.get(i)).draw(g);
	}
	
	/**
	 * MouseListener event, called on a mouse click.
	 */
	public void mouseClicked(MouseEvent e) {
		ClassBox selection = null;
		if (removeClassMode || addMethodMode || removeMethodMode) {
			selection = getAtPosition(e.getX(), e.getY());
		}
		if (removeClassMode  && (selection != null)) removeClass(selection);
		if (addMethodMode    && (selection != null)) addMethod(selection);
		if (removeMethodMode && (selection != null)) removeMethod(selection);
	}
	
	/**
	 * MouseListener event, called on the mouse button being pressed down.
	 */
	public void mousePressed(MouseEvent e) {
		lastX = e.getX(); lastY = e.getY();
		dragBox = getAtPosition(lastX, lastY);
	}
	
	/**
	 * MouseMotionListener event, called on the mouse being moved while having
	 * a button pressed down.
	 */
	public void mouseDragged(MouseEvent e) {
		if (dragBox != null) {
			dragBox.rect.x += e.getX() - lastX;
			dragBox.rect.y += e.getY() - lastY;
			if (dragBox.rect.x < 0) dragBox.rect.x = 0;
			if (dragBox.rect.y < 0) dragBox.rect.y = 0;
			if (dragBox.rect.x + dragBox.rect.width >= getWidth()) 
				dragBox.rect.x = getWidth() - dragBox.rect.width;
			if (dragBox.rect.y + dragBox.rect.height >= getHeight()) 
				dragBox.rect.y = getHeight() - dragBox.rect.height;
			repaint();
		}
		lastX = e.getX(); lastY = e.getY();
	}

	public void mouseMoved(MouseEvent e) {}
	public void mouseReleased(MouseEvent e) {}
	public void mouseEntered(MouseEvent e) {}
	public void mouseExited(MouseEvent e) {}
}
