import tkinter
import tkinter.messagebox
import customtkinter

customtkinter.set_appearance_mode("System")  # Modes: "System" (standard), "Dark", "Light"
customtkinter.set_default_color_theme("blue")  # Themes: "blue" (standard), "green", "dark-blue"

# en que posicion estaria la led solo 3 (decimales (double))
# area de deteccion m2
# cambia el numero de usuario max 20 usuarios
# hasta 4 leds constantes

# 3 simulaciones
# 1 simulacion luces led
# 2 calculo de errores (caida)
# 3 modulaciones  

# TODO
# 4 inputs de focos encendido apagado 
# input angulo de radiacion de 0 a 100
class App(customtkinter.CTk):
    def __init__(self):
        super().__init__()

        self.switch_led1_var = customtkinter.StringVar(value = "off")
        self.switch_led2_var = customtkinter.StringVar(value = "off")
        self.switch_led3_var = customtkinter.StringVar(value = "off")
        self.switch_led4_var = customtkinter.StringVar(value = "off")
        self.metros_var = customtkinter.StringVar()
        
        self.form = {
                "metros": self.metros_var.get(),
                "led1": "",
                "led2": "",
                "led3": "",
                "led4": ""
                }

        # configure window
        self.title("Matlab App")
        self.geometry(f"{1200}x{580}")

        # configure grid layout (4x4)
        self.grid_columnconfigure(1, weight=1)
        # self.grid_columnconfigure((1, 2, 3), weight=1)
        # self.grid_rowconfigure((0, 1, 2), weight=0)
        self.grid_rowconfigure(0, weight=1)
        # self.grid_rowconfigure(3, weight=1)
        
        # create sidebar frame with widgets
        self.sidebar_frame = customtkinter.CTkFrame(self, width=140, corner_radius=0)
        # self.sidebar_frame.grid(row=0, column=0,  sticky="nsew")
        self.sidebar_frame.grid(row=0, column=0, rowspan=4, sticky="nsew")
        # self.sidebar_frame.grid_rowconfigure(4, weight=1)
        self.logo_label = customtkinter.CTkLabel(self.sidebar_frame, text="MatLab App", font=customtkinter.CTkFont(size=20, weight="bold"))
        self.logo_label.grid(row=0, column=0, padx=20, pady=(20, 10))
        self.sidebar_button_1 = customtkinter.CTkButton(self.sidebar_frame, text="Simulacion Led", command=self.sidebar_button_event)
        self.sidebar_button_1.grid(row=1, column=0, padx=20, pady=10)
        self.sidebar_button_2 = customtkinter.CTkButton(self.sidebar_frame, text="Calculo de Errores", command=self.sidebar_button_event)
        self.sidebar_button_2.grid(row=2, column=0, padx=20, pady=10)
        
        
        # self.sidebar_button_3 = customtkinter.CTkButton(self.sidebar_frame, text="Modu", command=self.sidebar_button_event)
        # self.sidebar_button_3.grid(row=3, column=0, padx=20, pady=10)
        # create main content

        self.content_frame = customtkinter.CTkFrame(self, border_width=10)
        self.content_frame.grid(row=0, column=1, sticky="nsew")
        self.content_frame.grid_rowconfigure(1, weight=1)
        self.content_frame.grid_columnconfigure(0, weight=1)
        
        # create title and inputs frame
        self.title_form_frame= customtkinter.CTkFrame(self.content_frame, border_width = 10)
        self.title_form_frame.grid(row =0, column = 0, sticky = 'nsew')
        
        # create title
        self.title_label = customtkinter.CTkLabel(self.title_form_frame, text="App", font=customtkinter.CTkFont(size=30))
        self.title_label.grid(row=0, column=0, padx=10, pady=10) 

        # create main entry and button
        self.label_metros = customtkinter.CTkLabel(self.title_form_frame, text="Metros")
        self.label_metros.grid(row=1, column=1, padx=(20, 0), pady=(20, 20), sticky="nw")
        self.entry = customtkinter.CTkEntry(self.title_form_frame, placeholder_text="Metros", textvariable=self.metros_var)
        self.entry.grid(row=1, column=2, columnspan=2, padx=(20, 0), pady=(20, 20), sticky="nw")
        
        # Leds Inputs
        self.switch_led1 = customtkinter.CTkSwitch(master=self.title_form_frame, text="Led 1", variable= self.switch_led1_var, onvalue="on", offvalue="off", command = self.updateForm("led1", self.switch_led1_var.get()) )
        self.switch_led1.grid(row=2, column=2, columnspan=2, padx=(20, 0), pady=(20, 20), sticky="nw")
        
        self.switch_led2 = customtkinter.CTkSwitch(master=self.title_form_frame,text="Led 2", variable= self.switch_led2_var, onvalue="on", offvalue="off" )
        self.switch_led2.grid(row=2, column=7, columnspan=2, padx=(20, 0), pady=(20, 20), sticky="nw")
        
        self.switch_led3 = customtkinter.CTkSwitch(master=self.title_form_frame, text="Led 3", variable= self.switch_led3_var, onvalue="on", offvalue="off" )
        self.switch_led3.grid(row=3, column=2, columnspan=2, padx=(20, 0), pady=(20, 20), sticky="nw")
        
        self.switch_led4 = customtkinter.CTkSwitch(master=self.title_form_frame, text="Led 4", variable= self.switch_led4_var, onvalue="on", offvalue="off" )
        self.switch_led4.grid(row=3, column=7, columnspan=2, padx=(20, 0), pady=(20, 20), sticky="nw")
        
        self.calcular_button = customtkinter.CTkButton(master=self.title_form_frame, text="Calcular", fg_color="transparent", border_width=2, command=lambda : print(self.switch_led1_var.get()), text_color=("gray10", "#DCE4EE"))
        self.calcular_button.grid(row=4, column=2, columnspan=2,  pady=(20, 20), padx=(20, 20))

        # create the frame that contains the graphic result from matlab
        self.result_graphic = customtkinter.CTkFrame(self.content_frame, border_width=10)
        self.result_graphic.grid(row=1, column=0, sticky = 'nsew')


    def updateForm(self, field, value):
        self.form[field] = value
        print(self.form[field])
    
        
    
    def open_input_dialog_event(self):
        dialog = customtkinter.CTkInputDialog(text="Type in a number:", title="CTkInputDialog")
        print("CTkInputDialog:", dialog.get_input())

    def change_appearance_mode_event(self, new_appearance_mode: str):
        customtkinter.set_appearance_mode(new_appearance_mode)

    def change_scaling_event(self, new_scaling: str):
        new_scaling_float = int(new_scaling.replace("%", "")) / 100
        customtkinter.set_widget_scaling(new_scaling_float)

    def sidebar_button_event(self):
        print("sidebar_button click")


if __name__ == "__main__":
    app = App()
    app.mainloop()
