
import tkinter as tk
from tkinter import messagebox
import subprocess
import os


class WindowsToolkit(tk.Tk):
    def __init__(root):
        super().__init__()

        root.title("Windows Security Toolkit")
        root.configure(background="white")
        root.minsize(600, 600)
        root.geometry("800x800+400+100")

        ## Container for pages
        container = tk.Frame(root)
        container.pack(side="top", fill="both", expand=True)

        ## Configure grid layout
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

        ## Store pages
        root.frames = {}

        ## Add pages to container
        for F in (HomePage, ScriptsPage, ReportsPage, SetupGuidePage, SoftwarePage):
            frame = F(container, root)
            root.frames[F] = frame
            frame.grid(row=0, column=0, rowspan=5, columnspan= 5, sticky="nsew")

        root.show_frame(HomePage)  ## Shows the Home page first

    def show_frame(root, cont):
        """Bring a specific frame to the front."""
        frame = root.frames[cont]
        frame.tkraise()



class HomePage(tk.Frame):
    def __init__(root, parent, controller):
        super().__init__(parent, bg="white")
        label = tk.Label(root, text="Home Page", font=("Arial", 16), bg="white")
        label.pack(pady=20)

        ## Toolkit Logo
        logoImage = tk.PhotoImage(file="C://Users//kenny//Desktop//toolkit//images//logo.png")
        logoImage = logoImage.subsample(2, 2)
        tk.Label(root, image=logoImage).pack(padx=10, pady=5, anchor="n", side="left")

        ## Buttons & Content
        button_scripts = tk.Button(root, text="Go to Scripts", command=lambda: controller.show_frame(ScriptsPage))
        button_scripts.pack(pady=10)

        button_reports = tk.Button(root, text="Go to Reports", command=lambda: controller.show_frame(ReportsPage))
        button_reports.pack(pady=10)

        button_setup = tk.Button(root, text="Go to Setup Guide", command=lambda: controller.show_frame(SetupGuidePage))
        button_setup.pack(pady=10)

        button_software = tk.Button(root, text="Go to Software/Info", command=lambda: controller.show_frame(SoftwarePage))
        button_software.pack(pady=10)

class ScriptsPage(tk.Frame):
    def __init__(root, parent, controller):
        super().__init__(parent, bg="white")
        label = tk.Label(root, text="Scripts Center", font=("Arial", 16), bg="white")
        label.pack(pady=20)

        ## Toolkit Logo
        logoImage = tk.PhotoImage(file="C://Users//kenny//Desktop//toolkit//images//logo.png")
        logoImage = logoImage.subsample(2, 2)
        tk.Label(root, image=logoImage).pack(padx=10, pady=5, anchor="n", side="left")

        ## Buttons & Content
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
        command = ["powershell", "-File", "C://Users//kenny//Desktop//toolkit//scripts//Hardening_Harden-DisableServices.ps1"]
        try:
            result = subprocess.run(command, capture_output=True, text=True)
            output = result.stdout if result.returncode == 0 else result.stderr
        except Exception as e:
            output = f"Error: {e}"

        root.show_popup(output)

    def harden_account(root):
        command = ["powershell", "-File", "C://Users//kenny//Desktop//toolkit//scripts//Hardening_Harden-AccountPolicies.ps1"]
        try:
            result = subprocess.run(command, capture_output=True, text=True)
            output = result.stdout if result.returncode == 0 else result.stderr
        except Exception as e:
            output = f"Error: {e}"

        root.show_popup(output)

    def show_popup(root, message):
        popup = tk.Toplevel(root)
        popup.title("PowerShell Output")
        popup.geometry("425x400+600+160")

        label = tk.Label(popup, text="Command Output:", font=("Helvetica", 12))
        label.pack(pady=10)

        text = tk.Text(popup, wrap="word", height=60, width=50)
        text.insert(tk.END, message)
        text.config(state="disabled")
        text.pack(pady=5)

        close_button = tk.Button(popup, text="Close", command=popup.destroy)
        close_button.pack(pady=10)

class ReportsPage(tk.Frame):
    def __init__(root, parent, controller):
        super().__init__(parent, bg="white")
        label = tk.Label(root, text="Reports Page", font=("Arial", 16), bg="white")
        label.pack(pady=20)

        ## Toolkit Logo
        logoImage = tk.PhotoImage(file="C://Users//kenny//Desktop//toolkit//images//logo.png")
        logoImage = logoImage.subsample(2, 2)
        tk.Label(root, image=logoImage).pack(padx=10, pady=5, anchor="n", side="left")

        ## Buttons & Content
        button_home = tk.Button(root, text="Back to Home", command=lambda: controller.show_frame(HomePage))
        button_home.pack(pady=10)

class SetupGuidePage(tk.Frame):
    def __init__(root, parent, controller):
        super().__init__(parent, bg="white")
        label = tk.Label(root, text="Setup Guide Page", font=("Arial", 16), bg="white")
        label.pack(pady=20)

        ## Toolkit Logo
        logoImage = tk.PhotoImage(file="C://Users//kenny//Desktop//toolkit//images//logo.png")
        logoImage = logoImage.subsample(2, 2)
        tk.Label(root, image=logoImage).pack(padx=10, pady=5, anchor="n", side="left")

        ## Buttons & Content
        button_home = tk.Button(root, text="Back to Home", command=lambda: controller.show_frame(HomePage))
        button_home.pack(pady=10)

class SoftwarePage(tk.Frame):
    def __init__(root, parent, controller):
        super().__init__(parent, bg="white")
        label = tk.Label(root, text="Software Page", font=("Arial", 16), bg="white")
        label.pack(pady=20)

        ## Toolkit Logo
        logoImage = tk.PhotoImage(file="C://Users//kenny//Desktop//toolkit//images//logo.png")
        logoImage = logoImage.subsample(2, 2)
        tk.Label(root, image=logoImage).pack(padx=10, pady=5, anchor="n", side="left")

        ## Buttons & Content
        button_home = tk.Button(root, text="Back to Home", command=lambda: controller.show_frame(HomePage))
        button_home.pack(pady=10)

if __name__ == "__main__":
    app = WindowsToolkit()
    app.mainloop()