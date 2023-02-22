import tkinter
import tkinter.messagebox
import customtkinter
import matlab.engine
import os
import matlab.engine
from PIL import ImageTk, Image

customtkinter.set_appearance_mode("Dark")  # Modes: "System" (standard), "Dark", "Light"
customtkinter.set_default_color_theme(
    "blue"
)  # Themes: "blue" (standard), "green", "dark-blue"

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
        self.logo_label = customtkinter.CTkLabel(
            self.sidebar_frame,
            text="MatLab App",
            font=customtkinter.CTkFont(size=20, weight="bold"),
        )

        self.sidebar_button_2 = customtkinter.CTkButton(
            self.sidebar_frame,
            text="Simulacion Practica",
            command=self.calcular_practica,
        )
        self.sidebar_button_2.grid(row=2, column=0, padx=20, pady=10)

        self.sidebar_button_3 = customtkinter.CTkButton(
            self.sidebar_frame,
            text="Simulacion Rate Usuarios",
            command=self.calcular_rate2_usuarios,
        )
        self.sidebar_button_3.grid(row=3, column=0, padx=20, pady=10)

        self.sidebar_button_4 = customtkinter.CTkButton(
            self.sidebar_frame,
            text="Simulacion SER Norma",
            command=self.calcular_ser_norma,
        )
        self.sidebar_button_4.grid(row=4, column=0, padx=20, pady=10)
        # create main content

        self.content_frame = customtkinter.CTkScrollableFrame(self, border_width=10)
        self.content_frame.grid(row=0, column=1, sticky="nsew")
        self.content_frame.grid_rowconfigure(1, weight=1)
        self.content_frame.grid_columnconfigure(0, weight=1)

        # create title and inputs frame
        self.switch_led1_var = customtkinter.StringVar(value="off")
        self.switch_led2_var = customtkinter.StringVar(value="off")
        self.switch_led3_var = customtkinter.StringVar(value="off")
        self.switch_led4_var = customtkinter.StringVar(value="off")
        self.metros_var = customtkinter.StringVar()
        self.lumens = customtkinter.StringVar()
        self.usuarios = customtkinter.StringVar()
        self.angulo = customtkinter.StringVar()
        self.num_leds = 0
        self.title_form_frame = customtkinter.CTkFrame(
            self.content_frame, border_width=10
        )
        self.title_form_frame.grid(row=0, column=0, sticky="nsew")

        # create title
        self.title_label = customtkinter.CTkLabel(
            self.title_form_frame, text="App", font=customtkinter.CTkFont(size=30)
        )
        self.title_label.grid(row=0, column=0, padx=10, pady=10)

        # create main entry and button
        self.label_metros = customtkinter.CTkLabel(
            self.title_form_frame, text="Área en pies"
        )
        self.label_metros.grid(
            row=1, column=5, padx=(20, 0), pady=(20, 20), sticky="nw"
        )
        self.entry = customtkinter.CTkEntry(
            self.title_form_frame,
            placeholder_text="Metros",
            textvariable=self.metros_var,
        )
        self.entry.grid(
            row=1, column=6, columnspan=2, padx=(20, 0), pady=(20, 20), sticky="nw"
        )

        self.label_fotodeodos = customtkinter.CTkLabel(
            self.title_form_frame, text="Lumens"
        )
        self.label_fotodeodos.grid(
            row=2, column=1, padx=(20, 0), pady=(20, 20), sticky="nw"
        )

        self.fotodeodos_entry = customtkinter.CTkEntry(
            self.title_form_frame,
            placeholder_text="Numero de lumens",
            textvariable=self.lumens,
        )

        self.fotodeodos_entry.grid(
            row=2, column=2, columnspan=2, padx=(20, 0), pady=(20, 20), sticky="nw"
        )

        self.angulo_radiacion_label = customtkinter.CTkLabel(
            self.title_form_frame, text="Ángulo de radiación"
        )
        self.angulo_radiacion_label.grid(
            row=2, column=5, padx=(20, 0), pady=(20, 20), sticky="nw"
        )

        self.angulo_radiacion_entry = customtkinter.CTkEntry(
            self.title_form_frame,
            placeholder_text="Ángulo en radianes",
            textvariable=self.angulo,
        )

        self.angulo_radiacion_entry.grid(
            row=2, column=6, columnspan=2, padx=(20, 0), pady=(20, 20), sticky="nw"
        )

        self.num_usuarios_label = customtkinter.CTkLabel(
            self.title_form_frame, text="Usuarios"
        )

        self.num_usuarios_label.grid(
            row=1, column=1, padx=(20, 0), pady=(20, 20), sticky="nw"
        )

        self.num_usuarios_entry = customtkinter.CTkEntry(
            self.title_form_frame,
            placeholder_text="Número de usuarios",
            textvariable=self.usuarios,
        )

        self.num_usuarios_entry.grid(
            row=1, column=2, columnspan=2, padx=(20, 0), pady=(20, 20), sticky="nw"
        )

        # Leds Inputs
        self.switch_led1 = customtkinter.CTkSwitch(
            master=self.title_form_frame,
            text="Led 1",
            variable=self.switch_led1_var,
            onvalue="on",
            offvalue="off",
            command=lambda: self.incrementLeds(self.switch_led1_var.get()),
            # command=print(self.switch_led1_var.get()),
        )
        self.switch_led1.grid(
            row=3, column=2, columnspan=2, padx=(20, 0), pady=(20, 20), sticky="nw"
        )

        self.switch_led2 = customtkinter.CTkSwitch(
            master=self.title_form_frame,
            text="Led 2",
            variable=self.switch_led2_var,
            onvalue="on",
            offvalue="off",
            command=lambda: self.incrementLeds(self.switch_led1_var.get()),
        )
        self.switch_led2.grid(
            row=3, column=7, columnspan=2, padx=(20, 0), pady=(20, 20), sticky="nw"
        )

        self.switch_led3 = customtkinter.CTkSwitch(
            master=self.title_form_frame,
            text="Led 3",
            variable=self.switch_led3_var,
            onvalue="on",
            offvalue="off",
            command=lambda: self.incrementLeds(self.switch_led1_var.get()),
        )
        self.switch_led3.grid(
            row=4, column=2, columnspan=2, padx=(20, 0), pady=(20, 20), sticky="nw"
        )

        self.switch_led4 = customtkinter.CTkSwitch(
            master=self.title_form_frame,
            text="Led 4",
            variable=self.switch_led4_var,
            onvalue="on",
            offvalue="off",
            command=lambda: self.incrementLeds(self.switch_led1_var.get()),
        )
        self.switch_led4.grid(
            row=4, column=7, columnspan=2, padx=(20, 0), pady=(20, 20), sticky="nw"
        )

        self.calcular_button = customtkinter.CTkButton(
            master=self.title_form_frame,
            text="Calcular",
            fg_color="transparent",
            border_width=2,
            command=self.calcular_grafica,
            # command=self.printValues,
            text_color=("gray10", "#DCE4EE"),
        )
        self.calcular_button.grid(
            row=5, column=2, columnspan=2, pady=(20, 20), padx=(20, 20)
        )

        # create the frame that contains the graphic result from matlab
        self.result_graphic = customtkinter.CTkFrame(
            self.content_frame, border_width=10
        )
        self.result_graphic.grid(row=1, column=0, sticky="nsew")
        self.result_graphic.grid_columnconfigure(1, weight=1)
        self.result_graphic.grid_columnconfigure(2, weight=1)
        self.result_graphic.grid_rowconfigure(1, weight=1)

    def updateForm(self, field, value):
        self.form[field] = value
        print(self.form[field])

    def incrementLeds(self, value):
        if str(value) == "on":
            self.num_leds += 1
            print("valor aumentado")
        else:
            self.num_leds -= 1
            print("valor disminuido")
        # print(type(str(self.switch_led1_var.get())))

    def runMatlabFile(self):
        os.chdir(r"./simulifi1/")
        eng = matlab.engine.start_matlab()
        eng.apartado1(nargout=0)

    def open_input_dialog_event(self):
        dialog = customtkinter.CTkInputDialog(
            text="Type in a number:", title="CTkInputDialog"
        )
        print("CTkInputDialog:", dialog.get_input())

    def change_appearance_mode_event(self, new_appearance_mode: str):
        customtkinter.set_appearance_mode(new_appearance_mode)

    def change_scaling_event(self, new_scaling: str):
        new_scaling_float = int(new_scaling.replace("%", "")) / 100
        customtkinter.set_widget_scaling(new_scaling_float)

    def printValues(self):
        print(int(self.metros_var.get()))
        print(int(self.usuarios.get()))
        print(int(self.angulo.get()))
        print(int(self.lumens.get()))
        print(self.num_leds)

    def calcular_grafica(self):
        children = self.result_graphic.winfo_children()
        if len(children) != 0:
            for child in children:
                child.destroy()

        eng = matlab.engine.start_matlab()
        eng.cd(r"simulifi1", nargout=0)
        eng.apartado1(
            # lumens
            matlab.double([int(self.lumens.get())]),
            # Area
            matlab.double([int(self.metros_var.get())]),
            # leds
            matlab.double([self.num_leds]),
            # users
            matlab.double([int(self.usuarios.get())]),
            # Angulo
            matlab.double([int(self.angulo.get())]),
            nargout=0,
        )
        # create the image
        graph1 = Image.open(r"./simulifi1/Rate_NoCoop.png")
        graph1.thumbnail((525, 525))

        graph2 = Image.open(r"./simulifi1/SINR_NoCoop.png")
        graph2.thumbnail((525, 525))
        self.graphic_image1 = ImageTk.PhotoImage(
            graph1
            # Image.open(r"./simulifi1/Rate_NoCoop.png")
        )
        self.graphic_image2 = ImageTk.PhotoImage(
            # Image.open(r"./simulifi1/SINR_NoCoop.png")
            graph2
        )
        # place the image in label
        self.graphic_label1 = tkinter.Label(
            self.result_graphic, image=self.graphic_image1
        )

        self.graphic_label2 = tkinter.Label(
            self.result_graphic, image=self.graphic_image2
        )

        self.graphic_label1.grid(row=0, column=1, sticky="ew")
        self.graphic_label2.grid(row=0, column=2, sticky="ew")

    def calcular_practica(self):
        eng = matlab.engine.start_matlab()
        eng.cd(r"simulifi2", nargout=0)
        eng.practica(
            nargout=0,
        )
        # create the image
        graph1 = Image.open(r"./simulifi2/figure_1.png")
        graph1.thumbnail((525, 525))

        graph2 = Image.open(r"./simulifi2/figure_2.png")
        graph2.thumbnail((525, 525))

        graph3 = Image.open(r"./simulifi2/figure_3.png")
        graph3.thumbnail((525, 525))

        graph4 = Image.open(r"./simulifi2/figure_4.png")
        graph4.thumbnail((525, 525))
        self.graphic_image1 = ImageTk.PhotoImage(
            graph1
            # Image.open(r"./simulifi1/Rate_NoCoop.png")
        )
        self.graphic_image2 = ImageTk.PhotoImage(
            # Image.open(r"./simulifi1/SINR_NoCoop.png")
            graph2
        )

        self.graphic_image3 = ImageTk.PhotoImage(graph3)

        self.graphic_image4 = ImageTk.PhotoImage(graph4)
        # place the image in label
        self.graphic_label1 = tkinter.Label(
            self.result_graphic, image=self.graphic_image1
        )

        self.graphic_label2 = tkinter.Label(
            self.result_graphic, image=self.graphic_image2
        )

        self.graphic_label3 = tkinter.Label(
            self.result_graphic, image=self.graphic_image3
        )

        self.graphic_label4 = tkinter.Label(
            self.result_graphic, image=self.graphic_image4
        )

        self.graphic_label1.grid(row=0, column=1, sticky="ew")
        self.graphic_label2.grid(row=0, column=2, sticky="ew")
        self.graphic_label3.grid(row=1, column=1, sticky="ew")
        self.graphic_label4.grid(row=1, column=2, sticky="ew")

    def calcular_rate2_usuarios(self):
        children = self.result_graphic.winfo_children()
        if len(children) != 0:
            for child in children:
                child.destroy()
        eng = matlab.engine.start_matlab()
        eng.cd(r"simulifi3")
        eng.Rate_2Usuarios(
            nargout=0,
        )
        graph1 = Image.open(r"./simulifi3/Barplot2u.png")
        graph1.thumbnail((550, 550))

        self.graphic_image1 = ImageTk.PhotoImage(graph1)
        self.graphic_label1 = tkinter.Label(
            self.result_graphic, image=self.graphic_image1
        )

        self.graphic_label1.grid(row=0, column=1, sticky="ew")

    def calcular_ser_norma(self):
        children = self.result_graphic.winfo_children()
        if len(children) != 0:
            for child in children:
                child.destroy()
        eng = matlab.engine.start_matlab()
        eng.cd(r"simulifi3")
        eng.Rate_2Usuarios(
            nargout=0,
        )
        graph1 = Image.open(r"./simulifi3/semilogyBER.png")
        graph1.thumbnail((550, 550))

        self.graphic_image1 = ImageTk.PhotoImage(graph1)
        self.graphic_label1 = tkinter.Label(
            self.result_graphic, image=self.graphic_image1
        )

        self.graphic_label1.grid(row=0, column=1, sticky="ew")


if __name__ == "__main__":
    app = App()
    app.mainloop()
