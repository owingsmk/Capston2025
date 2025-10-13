
import tkinter as tk

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

        ## Store pages
        root.frames = {}

        ## Add pages to container
        for F in (HomePage, ScriptsPage, ReportsPage, SetupGuidePage, SoftwarePage):
            frame = F(container, root)
            root.frames[F] = frame
            frame.grid(row=0, column=0, sticky="nsew")

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

        ## Home Page Logo
        #logoImage = tk.PhotoImage(file="C:/Users/kenny/Downloads/images/logo.png")
        #logoImage = logoImage.subsample(2, 2)
        #tk.Label(root, image=logoImage).pack(padx=10, pady=5, anchor="nw")

        button_scripts = tk.Button(root, text="Go to Scripts", command=lambda: controller.show_frame(ScriptsPage))
        button_scripts.pack(pady=5)

        button_reports = tk.Button(root, text="Go to Reports", command=lambda: controller.show_frame(ReportsPage))
        button_reports.pack(pady=5)

        button_setup = tk.Button(root, text="Go to Setup Guide", command=lambda: controller.show_frame(SetupGuidePage))
        button_setup.pack(pady=5)

        button_software = tk.Button(root, text="Go to Software/Info", command=lambda: controller.show_frame(SoftwarePage))
        button_software.pack(pady=5)

class ScriptsPage(tk.Frame):
    def __init__(root, parent, controller):
        super().__init__(parent, bg="white")
        label = tk.Label(root, text="Scripts Page", font=("Arial", 16), bg="white")
        label.pack(pady=20)

        button_home = tk.Button(root, text="Back to Home", command=lambda: controller.show_frame(HomePage))
        button_home.pack(pady=5)

class ReportsPage(tk.Frame):
    def __init__(root, parent, controller):
        super().__init__(parent, bg="white")
        label = tk.Label(root, text="Reports Page", font=("Arial", 16), bg="white")
        label.pack(pady=20)

        button_home = tk.Button(root, text="Back to Home", command=lambda: controller.show_frame(HomePage))
        button_home.pack(pady=5)

class SetupGuidePage(tk.Frame):
    def __init__(root, parent, controller):
        super().__init__(parent, bg="white")
        label = tk.Label(root, text="Setup Guide Page", font=("Arial", 16), bg="white")
        label.pack(pady=20)

        button_home = tk.Button(root, text="Back to Home", command=lambda: controller.show_frame(HomePage))
        button_home.pack(pady=5)

class SoftwarePage(tk.Frame):
    def __init__(root, parent, controller):
        super().__init__(parent, bg="white")
        label = tk.Label(root, text="Software Page", font=("Arial", 16), bg="white")
        label.pack(pady=20)

        button_home = tk.Button(root, text="Back to Home", command=lambda: controller.show_frame(HomePage))
        button_home.pack(pady=5)

if __name__ == "__main__":
    app = WindowsToolkit()
    app.mainloop()