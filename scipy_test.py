import matlab.engine
import matlab


# eng = matlab.engine.start_matlab()
# eng.apartado1(nargout=0)


eng = matlab.engine.start_matlab()
eng.cd(r"simulifi1")
eng.apartado5(
    # lumens
    matlab.double([450]),
    # Area
    matlab.double([1000]),
    # leds
    matlab.double([4]),
    # users
    matlab.double([1]),
    # Angulo
    matlab.double([60]),
    nargout=0,
)
