import java.awt.*;
import java.util.ArrayList;
import java.io.*;

/**
 * A single drawable box, representing a class in UML notation.
 * @author Martin Kleppmann
 */
public class ClassBox implements Serializable {
	public String className;
	public Rectangle rect;
	public Font headingFont;
	public Font methodFont;
	public ArrayList methods; 
	public static final int HEADING_FONT_SIZE = 12;
	public static final int METHOD_FONT_SIZE = 10;
	public static final int MIN_WIDTH  = 30;
	public static final int MIN_HEIGHT = 20;
	public static final int MARGIN_VERTICAL = 4;
	public static final int MARGIN_HORIZONTAL = 10;
	
	public ClassBox(String className, int x, int y) {
		this.className = className;
		rect = new Rectangle(x, y, MIN_WIDTH, MIN_HEIGHT);
		headingFont = new Font("SansSerif", Font.BOLD, HEADING_FONT_SIZE);
		methodFont = new Font("SansSerif", Font.PLAIN, METHOD_FONT_SIZE);
		methods = new ArrayList();
	}
	
	public void draw(Graphics g) {
		// Determine minimum rectangle size based on font
		FontMetrics hm = g.getFontMetrics(headingFont);
		FontMetrics mm = g.getFontMetrics(methodFont);
		int hw = hm.stringWidth(className);
		rect.width = Math.max(MIN_WIDTH, hw + 2*MARGIN_HORIZONTAL);
		// Width of method names
		for (int i=0; i < methods.size(); i++) {
			int w = mm.stringWidth((String) methods.get(i)) + 2*MARGIN_HORIZONTAL;
			if (w > rect.width) rect.width = w;
		}
		// Height
		int hh = Math.max(MIN_HEIGHT, hm.getHeight() + 2*MARGIN_VERTICAL);
		rect.height = hh;
		if (methods.size() > 0)
			rect.height += mm.getHeight()*methods.size() + 2*MARGIN_VERTICAL;
		// Draw the box and heading
		g.drawRect(rect.x, rect.y, rect.width, rect.height);
		g.drawLine(rect.x, rect.y + hh, rect.x + rect.width, rect.y + hh);
		g.setFont(headingFont);
		g.drawString(className, rect.x + rect.width/2 - hw / 2, 
			rect.y + hm.getHeight() + MARGIN_VERTICAL);
		// Draw the methods
		g.setFont(methodFont);
		int y = rect.y + hh + MARGIN_VERTICAL + mm.getHeight();
		for (int i=0; i < methods.size(); i++) {
			g.drawString((String) methods.get(i), rect.x + MARGIN_HORIZONTAL, y);
			y += mm.getHeight();
		}
	}
}
