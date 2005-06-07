import java.io.*;
import javax.swing.*;
import java.awt.*;
import java.awt.print.*;
import java.awt.event.*;

/**
 * The "TickFrame" class defines the structure of the top-level frame
 * for Part IB Java ticked exercise 0.
 */
public class TickFrame extends javax.swing.JFrame {
	
	private Panel main_panel;
	private int classCount;
	private String filename = null;

	public TickFrame() {
		super("TickFrame");
		classCount = 0;
		Container cp = getContentPane();

		// Respond to the user clicking 'close' on the frame
		this.addWindowListener(new WindowAdapter() {
			public void windowClosing(WindowEvent evt) {
				System.exit(0);
			}
		});

		// Create the main panel.
		main_panel = new Panel();
		main_panel.setBorder(new javax.swing.border.LineBorder(Color.BLACK));
		main_panel.setPreferredSize(new Dimension(400, 300));
		main_panel.addMouseMotionListener(main_panel);
		main_panel.addMouseListener(main_panel);
		cp.add(main_panel, BorderLayout.CENTER);

		// Create the button panel.
		JPanel button_panel = new JPanel();
		button_panel.setBorder(new javax.swing.border.LineBorder(Color.BLACK));
		JButton add_class_button = new JButton("Add Class");
		add_class_button.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent evt) {
				classCount++;
				String str = "Class" + classCount;
				str = (String) JOptionPane.showInputDialog(main_panel, 
					"Please enter the new class' name.", "Add Class", 
					JOptionPane.QUESTION_MESSAGE, null, null, str);
				if (str != null) {
					main_panel.addClass(new ClassBox(str, 0, 0));
				}
			}
		});
		button_panel.add(add_class_button);
		JButton remove_class_button = new JButton("Remove Class");
		remove_class_button.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent evt) {
				main_panel.setRemoveClassMode();
			}
		});
		button_panel.add(remove_class_button);
		JButton add_method_button = new JButton("Add Method");
		add_method_button.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent evt) {
				main_panel.setAddMethodMode();
			}
		});
		button_panel.add(add_method_button);
		JButton remove_method_button = new JButton("Remove Method");
		remove_method_button.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent evt) {
				main_panel.setRemoveMethodMode();
			}
		});
		button_panel.add(remove_method_button);
		cp.add(button_panel, BorderLayout.NORTH);

		// Add a further panel across the bottom ('south') edge of the
		// main window.  This currently remains blank but could be
		// used for status messages to the user, for instance by
		// placing an instance of JLabel within the status panel.
		JPanel status_panel = new JPanel();
		status_panel.setBorder(new javax.swing.border.LineBorder(Color.BLACK));
		status_panel.setPreferredSize(new Dimension(10, 50));
		cp.add(status_panel, BorderLayout.SOUTH);

		// Set up the menu structure.
		JMenuBar menu_bar = new JMenuBar();
		JMenu file_menu = new JMenu("File");
		JMenuItem new_menu_item = new JMenuItem("New");
		JMenuItem open_menu_item = new JMenuItem("Open...");
		JMenuItem save_menu_item = new JMenuItem("Save");
		JMenuItem saveas_menu_item = new JMenuItem("Save as...");
		JMenuItem print_menu_item = new JMenuItem("Print");
		JMenuItem exit_menu_item = new JMenuItem("Exit");
		new_menu_item.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent evt) {
				main_panel.clear();
				main_panel.repaint();
				filename = null;
			}
		});
		open_menu_item.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent evt) {
				openFile();
			}
		});
		save_menu_item.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent evt) {
				saveFile(filename == null);
			}
		});
		saveas_menu_item.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent evt) {
				saveFile(true);
			}
		});
		print_menu_item.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent evt) {
				printDisplay();
			}
		});
		exit_menu_item.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent evt) {
				System.exit(0);
			}
		});

		file_menu.add(new_menu_item);
		file_menu.add(open_menu_item);
		file_menu.add(save_menu_item);
		file_menu.add(saveas_menu_item);
		file_menu.add(print_menu_item);
		file_menu.add(exit_menu_item);
		menu_bar.add(file_menu);
		setJMenuBar(menu_bar);

		// We have added all of the components necessary to define a
		// TickFrame. The call to 'pack' causes the system to work
		// out how to lay them out.
		pack();
	}

	private void openFile() {
		JFileChooser chooser = new JFileChooser();
		int returnVal = chooser.showOpenDialog(main_panel);
		if (returnVal == JFileChooser.APPROVE_OPTION)
			filename = chooser.getSelectedFile().getName();
			else return;
		try {
			FileInputStream in = new FileInputStream(filename);
			ObjectInputStream s = new ObjectInputStream(in);
			main_panel.readStream(s);
		} catch (FileNotFoundException e) {
		} catch (IOException e) {
		}
	}
	
	private void saveFile(boolean newFile) {
		if (newFile) {
			JFileChooser chooser = new JFileChooser();
			int returnVal = chooser.showSaveDialog(main_panel);
			if (returnVal == JFileChooser.APPROVE_OPTION)
				filename = chooser.getSelectedFile().getName();
				else return;
		}
		try {
			FileOutputStream out = new FileOutputStream(filename);
			ObjectOutputStream s = new ObjectOutputStream(out);
			main_panel.writeStream(s);
			s.flush();
		} catch (FileNotFoundException e) {
		} catch (IOException e) {
		}
	}

	// Basic responses to menu items.  The "printDisplay" method
	// prints the current state of the window as a single-page
	// document.
	private void printDisplay() {
		PrinterJob printJob = PrinterJob.getPrinterJob();
		printJob.setPrintable(new Printable() {
			public int print(Graphics g, PageFormat pf, int pageIndex) {
				if (pageIndex > 0)
					return Printable.NO_SUCH_PAGE;
				Graphics2D g2d = (Graphics2D) g;
				g2d.translate(pf.getImageableX(), pf.getImageableY());
				paint(g2d);
				return Printable.PAGE_EXISTS;
			}
		});

		if (printJob.printDialog())
			try {
				printJob.print();
			} catch (PrinterException pe) {
				System.out.println("Error printing: " + pe);
			}
	}


	/**
	 * Main program entry point.
	 */
	public static void main(String args[]) {
		TickFrame tf = new TickFrame();
		tf.show();
	}
}
