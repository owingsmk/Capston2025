
import tkinter as tk
import subprocess
import os

## Removes Windows Preset Icon
try:
    from ctypes import windll  # Only exists on Windows.

    myappid = "UC.windowssectoolkit.0"
    windll.shell32.SetCurrentProcessExplicitAppUserModelID(myappid)
except ImportError:
    pass

## Collects directory name for relative file paths
basedir = os.path.dirname(__file__)
scriptdir = basedir + "\\scripts"
reportdir = basedir + "\\reports"
imagedir = basedir + "\\images"
logopath = imagedir + "\\logo.png"

class WindowsToolkit(tk.Tk):
    def __init__(root):
        super().__init__()

        root.title("Windows Security Toolkit")
        root.configure(background="#99afcc")
        root.minsize(600, 600)
        root.geometry("800x750+400+100")

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
        ##Bring a specific frame to the front.
        frame = root.frames[cont]
        frame.tkraise()


##Pages for the GUI
class HomePage(tk.Frame):
    def __init__(root, parent, controller):
        super().__init__(parent, bg="#99afcc")
        label = tk.Label(root, text="Windows Security Toolkit", font=("Arial", 16), fg= "white", bg="#436492", width=200, height=2)
        label.pack()

        ## Toolkit Logo
        logoImage = tk.PhotoImage(file=logopath)
        logoImage = logoImage.subsample(2, 2)

        actualLogo = tk.Label(root, image=logoImage)
        actualLogo.image = logoImage
        actualLogo.pack(padx=10, pady=5, anchor="n", side="left")

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
        super().__init__(parent, bg="#99afcc")
        label = tk.Label(root, text="Scripts Center", font=("Arial", 16), fg= "white", bg="#436492", width=200, height=2)
        label.pack()

        ## Toolkit Logo
        logoImage = tk.PhotoImage(file=logopath)
        logoImage = logoImage.subsample(2, 2)
        
        actualLogo = tk.Label(root, image=logoImage)
        actualLogo.image = logoImage
        actualLogo.pack(padx=10, pady=5, anchor="n", side="left")

        ## Buttons on Scripts Page
        button_home = tk.Button(root, text="Back to Home", command=lambda: controller.show_frame(HomePage))
        button_home.pack(pady=10)

        script_services_button = tk.Button(root, text="Audit Services", command=root.audit_services)
        script_services_button.pack(pady=10)

        ##script_services_button = tk.Button(root, text="Disable Services", command=root.disable_services)
        ##script_services_button.pack(pady=10)

        script_account_button = tk.Button(root, text="Harden Account Password Settings", command=root.harden_account)
        script_account_button.pack(pady=10)

        script_registry_button = tk.Button(root, text="Tweak Registry Config", command=root.tweak_registry)
        script_registry_button.pack(pady=10)

        script_firewall_button = tk.Button(root, text="Harden Windows Defender", command=root.harden_firewall)
        script_firewall_button.pack(pady=10)

        script_autorun_button = tk.Button(root, text="Disable Autorun", command=root.harden_autorun)
        script_autorun_button.pack(pady=10)

    ## Scripts run by the buttons
    def audit_services(root):
        command = ["powershell", "-File", os.path.join(scriptdir, "Audit-Services.ps1")]
        try:
            result = subprocess.run(command, capture_output=True, text=True)
            output = result.stdout if result.returncode == 0 else result.stderr
        except Exception as e:
            output = f"Error: {e}"

        root.show_popup(output)

    def disable_services(root):
        command = ["powershell", "-File", os.path.join(scriptdir, "Disable-Services.ps1")]
        try:
            result = subprocess.run(command, capture_output=True, text=True)
            output = result.stdout if result.returncode == 0 else result.stderr
        except Exception as e:
            output = f"Error: {e}"

        root.show_popup(output)

    def harden_account(root):
        command = ["powershell", "-File", os.path.join(scriptdir, "Harden-AccountPolicies.ps1")]
        try:
            result = subprocess.run(command, capture_output=True, text=True)
            output = result.stdout if result.returncode == 0 else result.stderr
        except Exception as e:
            output = f"Error: {e}"

        root.show_popup(output)

    def tweak_registry(root):
        command = ["powershell", "-File", os.path.join(scriptdir, "Harden-RegistryTweaks.ps1")]
        try:
            result = subprocess.run(command, capture_output=True, text=True)
            output = result.stdout if result.returncode == 0 else result.stderr
        except Exception as e:
            output = f"Error: {e}"

        root.show_popup(output)

    def harden_firewall(root):
        command = ["powershell", "-File", os.path.join(scriptdir, "Harden-FirewallDefender.ps1")]
        try:
            result = subprocess.run(command, capture_output=True, text=True)
            output = result.stdout if result.returncode == 0 else result.stderr
        except Exception as e:
            output = f"Error: {e}"
        
        root.show_popup(output)

    def harden_autorun(root):
        command = ["powershell", "-File", os.path.join(scriptdir, "Harden-Autorun.ps1")]
        try:
            result = subprocess.run(command, capture_output=True, text=True)
            output = result.stdout if result.returncode == 0 else result.stderr
        except Exception as e:
            output = f"Error: {e}"
        
        root.show_popup(output)


    ##Popup for when the buttons are clicked
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
        super().__init__(parent, bg="#99afcc")
        label = tk.Label(root, text="Reports Center", font=("Arial", 16), fg= "white", bg="#436492", width=200, height=2)
        label.pack()

        ## Toolkit Logo
        logoImage = tk.PhotoImage(file=logopath)
        logoImage = logoImage.subsample(2, 2)
        
        actualLogo = tk.Label(root, image=logoImage)
        actualLogo.image = logoImage
        actualLogo.pack(padx=10, pady=5, anchor="n", side="left")

        ## Buttons on the Reports page
        button_home = tk.Button(root, text="Back to Home", command=lambda: controller.show_frame(HomePage))
        button_home.pack(pady=10)

        report_user_button = tk.Button(root, text="Audit User Accounts", command=root.audit_users)
        report_user_button.pack(pady=10)

        report_firewall_button = tk.Button(root, text="Check Firewall Status", command=root.check_firewall)
        report_firewall_button.pack(pady=10)

        report_update_button = tk.Button(root, text="Check Windows Updates", command=root.check_update)
        report_update_button.pack(pady=10)

        report_usb_button = tk.Button(root, text="Check USB Acess", command=root.control_usb)
        report_usb_button.pack(pady=10)

        report_password_button = tk.Button(root, text="Enforce Password Policy", command=root.enforce_password)
        report_password_button.pack(pady=10)

        report_harden_button = tk.Button(root, text="Harden System", command=root.harden_system)
        report_harden_button.pack(pady=10)

        report_event_button = tk.Button(root, text="Monitor Windows Event Logs", command=root.monitor_events)
        report_event_button.pack(pady=10)

        report_scanner_button = tk.Button(root, text="Run CVE Scanner", command=root.cve_scanner)
        report_scanner_button.pack(pady=10)

        ##Scripts run by the buttons
    def audit_users(root):
        command = ["powershell", "-File", os.path.join(reportdir, "Audit-UserAccounts.ps1")]
        try:
            result = subprocess.run(command, capture_output=True, text=True)
            output = result.stdout if result.returncode == 0 else result.stderr
        except Exception as e:
            output = f"Error: {e}"

        root.show_report_popup(output)

    def check_firewall(root):
        command = ["powershell", "-File", os.path.join(reportdir, "Check-FirewallStatus.ps1")]
        try:
            result = subprocess.run(command, capture_output=True, text=True)
            output = result.stdout if result.returncode == 0 else result.stderr
        except Exception as e:
            output = f"Error: {e}"

        root.show_report_popup(output)

    def check_update(root):
        command = ["powershell", "-File", os.path.join(reportdir, "Check-WindowsUpdates.ps1")]
        try:
            result = subprocess.run(command, capture_output=True, text=True)
            output = result.stdout if result.returncode == 0 else result.stderr
        except Exception as e:
            output = f"Error: {e}"

        root.show_report_popup(output)

    def control_usb(root):
        command = ["powershell", "-File", os.path.join(reportdir, "Control-USBAccess.ps1")]
        try:
            result = subprocess.run(command, capture_output=True, text=True)
            output = result.stdout if result.returncode == 0 else result.stderr
        except Exception as e:
            output = f"Error: {e}"

        root.show_report_popup(output)

    def enforce_password(root):
        command = ["powershell", "-File", os.path.join(reportdir, "Enforce-PasswordPolicy.ps1")]
        try:
            result = subprocess.run(command, capture_output=True, text=True)
            output = result.stdout if result.returncode == 0 else result.stderr
        except Exception as e:
            output = f"Error: {e}"

        root.show_report_popup(output)

    def harden_system(root):
        command = ["powershell", "-File", os.path.join(reportdir, "Harden-System.ps1")]
        try:
            result = subprocess.run(command, capture_output=True, text=True)
            output = result.stdout if result.returncode == 0 else result.stderr
        except Exception as e:
            output = f"Error: {e}"

        root.show_report_popup(output)

    def monitor_events(root):
        command = ["powershell", "-File", os.path.join(reportdir, "Monitor-EventLogs.ps1")]
        try:
            result = subprocess.run(command, capture_output=True, text=True)
            output = result.stdout if result.returncode == 0 else result.stderr
        except Exception as e:
            output = f"Error: {e}"

        root.show_report_popup(output)

    def cve_scanner(root):
        command = ["powershell", "-File", os.path.join(reportdir, "CVEScanner.ps1")]
        try:
            result = subprocess.run(command, capture_output=True, text=True)
            output = result.stdout if result.returncode == 0 else result.stderr
        except Exception as e:
            output = f"Error: {e}"

        root.show_report_popup(output)
        
    ##Popup for when the buttons are clicked
    def show_report_popup(root, message):
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

class SetupGuidePage(tk.Frame):
    def __init__(root, parent, controller):
        super().__init__(parent, bg="#99afcc")
        label = tk.Label(root, text="Setup Guide", font=("Arial", 16), fg= "white", bg="#436492", width=200, height=2)
        label.pack()

        ## Toolkit Logo
        logoImage = tk.PhotoImage(file=logopath)
        logoImage = logoImage.subsample(2, 2)
        
        actualLogo = tk.Label(root, image=logoImage)
        actualLogo.image = logoImage
        actualLogo.pack(padx=10, pady=5, anchor="n", side="left")

        ## Buttons & Content
        button_home = tk.Button(root, text="Back to Home", command=lambda: controller.show_frame(HomePage))
        button_home.pack(pady=10)

        ##Script & Report Info
        setup_text1 = tk.Label(root, text="All scripts run from the Script Center are required to be run by an administrator account as they can make changes to your system. The reports on the Report Center do not require administrator access and they will not make any changes to your system. Some scripts and reports, such as the CVE Scanner can take some time to run, please be patient.", height=10, width=40, wraplength = 280)
        setup_text1.pack(pady=10)

        ##Warning & Link
        setup_text2 = tk.Label(root, text="The Windows Security Toolkit is not a replacement or alternative for a firewall or other security tools, it is meant to compliment those tools and provide suggestions to improve your system's security as well as perform some basic actions to improve your system's security. For more information on the Windows Security Toolkit and its use, please go to https://github.com/owingsmk/Capston2025", height=10, width=40, wraplength = 280)
        setup_text2.pack(pady=10)

        ##Uninstall Message
        setup_text3 = tk.Label(root, text="If you wish to uninstall the Windows Security Toolkit, please use the file explorer to navigate to Program Files (x86) > Project > Windows Security Toolkit > Uninstall.exe to do so. The Toolkit uses InstallForge for packaging and it is a known issue that attempting to uninstall an app through the Windows Settings menu does nothing and has not yet been fixed by InstallForge.", height=10, width=40, wraplength = 280)
        setup_text3.pack(pady=10)


class SoftwarePage(tk.Frame):
    def __init__(root, parent, controller):
        super().__init__(parent, bg="#99afcc")
        label = tk.Label(root, text="Software Information", font=("Arial", 16), fg= "white", bg="#436492", width=200, height=2)
        label.pack()

        ## Toolkit Logo
        logoImage = tk.PhotoImage(file=logopath)
        logoImage = logoImage.subsample(2, 2)
        
        actualLogo = tk.Label(root, image=logoImage)
        actualLogo.image = logoImage
        actualLogo.pack(padx=10, pady=5, anchor="n", side="left")

        ## Buttons & Content
        button_home = tk.Button(root, text="Back to Home", command=lambda: controller.show_frame(HomePage))
        button_home.pack(pady=10)

        ##Version Info
        software_text = tk.Label(root, text="This version 1.0 of the Windows Security Toolkit.", height=2, width=40, wraplength = 280)
        software_text.pack(pady=10)

        ##Software Text
        software_text = tk.Label(root, text="The Windows Security Toolkit is a University of Cincinnati student Capstone project, it is not an official Windows tool or program. It is intended to improve your system's security with manually run scripts. For more information on the Windows Security Toolkit and its use, please go to https://github.com/owingsmk/Capston2025", height=10, width=40, wraplength = 280)
        software_text.pack(pady=10)


if __name__ == "__main__":
    app = WindowsToolkit()
    app.iconbitmap(imagedir+"\\icon.ico") ## Changes the Windows Icon for the toolkit
    app.mainloop()