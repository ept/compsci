import javax.swing.*;
import java.awt.*;
import java.awt.print.*;
import java.awt.event.*;

/*
 * The "TickFrame" class defines the structure of the top-level frame
 * for Part IB Java ticked exercise 0.
 */
public class TickFrame extends javax.swing.JFrame {
        
    public TickFrame() {
        super("TickFrame");
        Container cp = getContentPane();

	//............................................................
        //
        // Respond to the user clicking 'close' on the frame

        this.addWindowListener(new WindowAdapter() {
            public void windowClosing(WindowEvent evt) {
                quitApplication();
            }
        });

	//............................................................
	//
	// Create the main panel containing the user's design.
	// Currently this is an instance of the JPanel class which is
	// a blank panel with nothing rendered on it.  In the full
	// application it is necessary to sub-class JPanel and to
	// override its paintComponent method to actually render
	// shapes on it.

        JPanel main_panel = new JPanel();
        main_panel.setBorder(new javax.swing.border.LineBorder(Color.BLACK));
        main_panel.setPreferredSize(new Dimension(400, 300));
        main_panel.addMouseMotionListener(new MouseMotionAdapter() {
            public void mouseDragged(MouseEvent evt) {
                mainPanelMouseDragged(evt);
            }
        });
        main_panel.addMouseListener(new MouseAdapter() {
            public void mouseClicked(MouseEvent evt) {
                mainPanelMouseClicked(evt);
            }
        });
        cp.add(main_panel, BorderLayout.CENTER);

	//............................................................
        //
        // Create the button panel at the side of the main panel.  In
        // this application it has only a single button, labelled "Add
        // Class", but it could in principle be extended to provide
        // other features.  Notice how the layout is controlled by
        // using a series of nested containers: the "Add Class" button
        // is added to the button panel (implicitly going at the top),
        // and then the button panel is added to the main panel
        // (explicitly being placed the the 'west' side of it).

        JPanel button_panel = new JPanel();
        button_panel.setBorder(new javax.swing.border.LineBorder(Color.BLACK));
        JButton add_class_button = new JButton("Add Class");
        add_class_button.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent evt) {
                addClassButtonActionPerformed(evt);
            }
        });
        button_panel.add(add_class_button);
        cp.add(button_panel, BorderLayout.WEST);

	//............................................................
        //
        // Add a further panel across the bottom ('south') edge of the
        // main window.  This currently remains blank but could be
        // used for status messages to the user, for instance by
        // placing an instance of JLabel within the status panel.

        JPanel status_panel = new JPanel();
        status_panel.setBorder(new javax.swing.border.LineBorder(Color.BLACK));
        status_panel.setPreferredSize(new Dimension(10, 50));
        cp.add(status_panel, BorderLayout.SOUTH);

	//............................................................
        //
        // Set up the menu structure.  This skeleton code just defines
        // a "File" menu with "Print" and "Quit" options on it.

        JMenuBar menu_bar = new JMenuBar();
        JMenu file_menu = new JMenu("File");
        JMenuItem print_menu_item = new JMenuItem ("Print");
        JMenuItem exit_menu_item = new JMenuItem ("Exit");
        print_menu_item.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent evt) {
                printDisplay();
            }
        });
        exit_menu_item.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent evt) {
                quitApplication();
            }
        });

        file_menu.add(print_menu_item);
        file_menu.add(exit_menu_item);
        menu_bar.add(file_menu);
        setJMenuBar(menu_bar);

	//............................................................
        //
        // We have added all of the components necessary to define a
        // TickFrame.  The call to 'pack' causes the system to work
        // out how to lay them out.

        pack();
    }

    //............................................................
    //
    // The next three methods are called from the 'listeners'
    // associated with parts of the display.  In this skeleton code
    // they simply report their operations on the standard console
    // output.

    private void addClassButtonActionPerformed(ActionEvent evt) {
        System.out.println("Add a Class");
    }

    private void mainPanelMouseDragged(MouseEvent evt) {
        System.out.println("Mouse drag at " + evt.getX() + " " + evt.getY());
    }

    private void mainPanelMouseClicked(MouseEvent evt) {
        System.out.println("Mouse click at " + evt.getX() + " " + evt.getY());
    }
    
    //............................................................
    //
    // Basic responses to menu items.  The "printDisplay" method
    // prints the current state of the window as a single-page
    // document.
    
    private void printDisplay() {
        PrinterJob printJob = PrinterJob.getPrinterJob();
            printJob.setPrintable(new Printable () {
                public int print(Graphics g, PageFormat pf, int pageIndex) {
                        if (pageIndex > 0) return Printable.NO_SUCH_PAGE;
                        Graphics2D g2d = (Graphics2D)g;
                        g2d.translate(pf.getImageableX(), pf.getImageableY());
                        paint(g2d);
                        return Printable.PAGE_EXISTS;
                    }
            });
            
            if (printJob.printDialog())
              try { 
                printJob.print();
              } catch(PrinterException pe) {
                System.out.println("Error printing: " + pe);
              }
    }
        
    private void quitApplication() {
        System.exit(0);
    }
        
    //............................................................
    //
    // Main program entry point.  Notice that the actual work of
    // putting together the top-level window is done within the
    // class's constructor -- all that is necessary here is to
    // instantiate the class and request that it be displayed.

    public static void main(String args[]) {
        TickFrame tf = new TickFrame();
        tf.show();
    }
}
