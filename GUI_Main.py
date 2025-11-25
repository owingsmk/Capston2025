"""Windows Security Toolkit - GUI Application

A comprehensive graphical user interface for Windows system hardening and security management.
Provides functionality to run security scripts, manage accounts, control services, and monitor system status.

Modules:
    tkinter: GUI framework
    subprocess: Execute PowerShell scripts
    os: File system operations
"""

import tkinter as tk
from tkinter import messagebox
import subprocess
import os


class WindowsToolkit(tk.Tk):
    """Main application window for Windows Security Toolkit.
    
    Inherits from tk.Tk to create the root window. Manages navigation between
    different pages (Home, Scripts, Reports, Setup Guide, Software).
    """
    
    def __init__(root):
        """Initialize the main application window and set up page navigation.
        
        Creates the root window, configures appearance, and initializes
        all pages that users can navigate between.
        """
        super().__init__()

        root.title("Windows Security Toolkit")
        root.configure(background="white")
        root.minsize(600, 600)
        root.geometry("800x800+400+100")

        # Container frame to hold all pages
        container = tk.Frame(root)
        container.pack(side="top", fill="both", expand=True)

        # Configure grid layout to support all pages stacked on top of each other
        container.grid_rowconfigure(0, weight=1)
        container.grid_columnconfigure(0, weight=1)
        container.grid_rowconfigure(1, weight=1)
        container.grid_columnconfigure(1, weight=1)
        container.grid_rowconfigure(2, weight=1)
        container.grid_columnconfigure(2, weight=1)
        container.grid_rowconfigure(3, weight=1)
        container.grid_columnconfigure(3, weight=1)
        container.grid_rowconfigure(4, weight=1)
        container.grid_columnconfigure(4, weight=1)

        # Dictionary to store all page frames for navigation
        root.frames = {}

        # Instantiate all pages and add them to the container
        # All pages are stacked on top of each other; we show one at a time
        for F in (HomePage, ScriptsPage, ReportsPage, SetupGuidePage, SoftwarePage):
            frame = F(container, root)
            root.frames[F] = frame
            frame.grid(row=0, column=0, rowspan=5, columnspan=5, sticky="nsew")

        # Display the home page on startup
        root.show_frame(HomePage)

    def show_frame(root, cont):
        """Display a specific page by raising it above other pages.
        
        Args:
            cont: The frame class to display (e.g., HomePage, ScriptsPage)
        """
        frame = root.frames[cont]
        frame.tkraise()



class HomePage(tk.Frame):
    """Home page displaying main navigation menu.
    
    Provides the starting point for users with buttons to navigate to
    Scripts, Reports, Setup Guide, and Software pages.
    """
    
    def __init__(root, parent, controller):
        """Initialize the home page with navigation buttons.
        
        Args:
            parent: Parent widget (container frame)
            controller: Main application window for page navigation
        """
        super().__init__(parent, bg="white")
        label = tk.Label(root, text="Home Page", font=("Arial", 16), bg="white")
        label.pack(pady=20)

        # Load and display toolkit logo
        logoImage = tk.PhotoImage(file="C://Users//kenny//Desktop//toolkit//images//logo.png")
        logoImage = logoImage.subsample(2, 2)
        tk.Label(root, image=logoImage).pack(padx=10, pady=5, anchor="n", side="left")

        # Navigation buttons to other pages
        button_scripts = tk.Button(root, text="Go to Scripts", command=lambda: controller.show_frame(ScriptsPage))
        button_scripts.pack(pady=10)

        button_reports = tk.Button(root, text="Go to Reports", command=lambda: controller.show_frame(ReportsPage))
        button_reports.pack(pady=10)

        button_setup = tk.Button(root, text="Go to Setup Guide", command=lambda: controller.show_frame(SetupGuidePage))
        button_setup.pack(pady=10)

        button_software = tk.Button(root, text="Go to Software/Info", command=lambda: controller.show_frame(SoftwarePage))
        button_software.pack(pady=10)

class ScriptsPage(tk.Frame):
    """Scripts page for executing security hardening scripts.
    
    Provides buttons to run various PowerShell scripts for system hardening,
    including disabling services and hardening account policies.
    """
    
    def __init__(root, parent, controller):
        """Initialize the scripts page with execution buttons.
        
        Args:
            parent: Parent widget (container frame)
            controller: Main application window for page navigation
        """
        super().__init__(parent, bg="white")
        label = tk.Label(root, text="Scripts Center", font=("Arial", 16), bg="white")
        label.pack(pady=20)

        # Load and display toolkit logo
        logoImage = tk.PhotoImage(file="C://Users//kenny//Desktop//toolkit//images//logo.png")
        logoImage = logoImage.subsample(2, 2)
        tk.Label(root, image=logoImage).pack(padx=10, pady=5, anchor="n", side="left")

        # Navigation and script execution buttons
        button_home = tk.Button(root, text="Back to Home", command=lambda: controller.show_frame(HomePage))
        button_home.pack(pady=10)
    
        script_test_button = tk.Button(root, text="Run PowerShell Command", command=root.run_powershell)
        script_test_button.pack(pady=10)

        script_services_button = tk.Button(root, text="Disable Services", command=root.disable_services)
        script_services_button.pack(pady=10)

        script_account_button = tk.Button(root, text="Harden Account Password Settings", command=root.harden_account)
        script_account_button.pack(pady=10)

    def run_powershell(root):
        command = ["powershell", "-File", os.path.join("scripts", "script.ps1")]
        try:
            result = subprocess.run(command, capture_output=True, text=True)
            output = result.stdout if result.returncode == 0 else result.stderr
        except Exception as e:
            output = f"Error: {e}"

        root.show_popup(output)

    def disable_services(root):
        """Execute script to disable unnecessary Windows services.
        
        Runs the Hardening_Harden-DisableServices.ps1 script to disable
        services that may pose security risks.
        """
        command = ["powershell", "-File", "C://Users//kenny//Desktop//toolkit//scripts//Hardening_Harden-DisableServices.ps1"]
        try:
            result = subprocess.run(command, capture_output=True, text=True)
            output = result.stdout if result.returncode == 0 else result.stderr
        except Exception as e:
            output = f"Error: {e}"

        root.show_popup(output)

    def harden_account(root):
        """Execute script to enforce strong account password policies.
        
        Runs the Hardening_Harden-AccountPolicies.ps1 script to configure
        password requirements and account lockout policies.
        """
        command = ["powershell", "-File", "C://Users//kenny//Desktop//toolkit//scripts//Hardening_Harden-AccountPolicies.ps1"]
        try:
            result = subprocess.run(command, capture_output=True, text=True)
            output = result.stdout if result.returncode == 0 else result.stderr
        except Exception as e:
            output = f"Error: {e}"

        root.show_popup(output)

    def show_popup(root, message):
        """Display script output in a popup window.
        
        Args:
            message (str): The output text to display from PowerShell execution
        """
        popup = tk.Toplevel(root)
        popup.title("PowerShell Output")
        popup.geometry("425x400+600+160")

        label = tk.Label(popup, text="Command Output:", font=("Helvetica", 12))
        label.pack(pady=10)

        # Read-only text widget to display output
        text = tk.Text(popup, wrap="word", height=60, width=50)
        text.insert(tk.END, message)
        text.config(state="disabled")
        text.pack(pady=5)

        close_button = tk.Button(popup, text="Close", command=popup.destroy)
        close_button.pack(pady=10)

class ReportsPage(tk.Frame):
    """Reports page for viewing system security reports.
    
    Intended to display reports on system security status and hardening results.
    Currently a placeholder for future implementation.
    """
    
    def __init__(root, parent, controller):
        """Initialize the reports page.
        
        Args:
            parent: Parent widget (container frame)
            controller: Main application window for page navigation
        """
        super().__init__(parent, bg="white")
        label = tk.Label(root, text="Reports Page", font=("Arial", 16), bg="white")
        label.pack(pady=20)

        # Load and display toolkit logo
        logoImage = tk.PhotoImage(file="C://Users//kenny//Desktop//toolkit//images//logo.png")
        logoImage = logoImage.subsample(2, 2)
        tk.Label(root, image=logoImage).pack(padx=10, pady=5, anchor="n", side="left")

        # Navigation buttons
        button_home = tk.Button(root, text="Back to Home", command=lambda: controller.show_frame(HomePage))
        button_home.pack(pady=10)

class SetupGuidePage(tk.Frame):
    """Setup guide page with installation and configuration instructions.
    
    Provides users with guidance on setting up and configuring the toolkit.
    Currently a placeholder for future implementation.
    """
    
    def __init__(root, parent, controller):
        """Initialize the setup guide page.
        
        Args:
            parent: Parent widget (container frame)
            controller: Main application window for page navigation
        """
        super().__init__(parent, bg="white")
        label = tk.Label(root, text="Setup Guide Page", font=("Arial", 16), bg="white")
        label.pack(pady=20)

        # Load and display toolkit logo
        logoImage = tk.PhotoImage(file="C://Users//kenny//Desktop//toolkit//images//logo.png")
        logoImage = logoImage.subsample(2, 2)
        tk.Label(root, image=logoImage).pack(padx=10, pady=5, anchor="n", side="left")

        # Navigation buttons
        button_home = tk.Button(root, text="Back to Home", command=lambda: controller.show_frame(HomePage))
        button_home.pack(pady=10)

class SoftwarePage(tk.Frame):
    """Software page displaying information and management options.
    
    Provides information about installed software and system tools.
    Currently a placeholder for future implementation.
    """
    
    def __init__(root, parent, controller):
        """Initialize the software page.
        
        Args:
            parent: Parent widget (container frame)
            controller: Main application window for page navigation
        """
        super().__init__(parent, bg="white")
        label = tk.Label(root, text="Software Page", font=("Arial", 16), bg="white")
        label.pack(pady=20)

        # Load and display toolkit logo
        logoImage = tk.PhotoImage(file="C://Users//kenny//Desktop//toolkit//images//logo.png")
        logoImage = logoImage.subsample(2, 2)
        tk.Label(root, image=logoImage).pack(padx=10, pady=5, anchor="n", side="left")

        # Navigation buttons
        button_home = tk.Button(root, text="Back to Home", command=lambda: controller.show_frame(HomePage))
        button_home.pack(pady=10)

if __name__ == "__main__":
    # Create and run the main application
    app = WindowsToolkit()
    app.mainloop()