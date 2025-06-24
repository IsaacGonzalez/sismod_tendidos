require 'minitest/autorun'


class DacService 

    def dac(ruta)
        dac = 0 

        for credito in ruta do 
            # calcula el dac 

            dac += credito.deudas 
        end

        return dac 
    end 

end 


class DacTest < Minitest::Test 

    def test_caso_1
        ruta_morada = [
            { deudas: 1000, pagos: 1000, fecha_ultimo_pago: Date.new(2024, 1, 1) },
            { deudas: 2000, pagos: 2000, fecha_ultimo_pago: Date.new(2024, 1, 1) },
            { deudas: 3000, pagos: 3000, fecha_ultimo_pago: Date.new(2024, 1, 1) },
        ]

        dac = DacService.new.dac(ruta_morada)

        assert_equal 6000, dac
    end 


    # Que pas si el cliente quiere renovar pero no tieen dinero y se lo prestamos 
    def test_caso_2 
    end 
end 
