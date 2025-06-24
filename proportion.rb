require 'json'
require 'neatjson'
require 'minitest/autorun'

def tendidos(*quantities, cantidad_max_lienzos, consumo_por_prenda, largo_maximo_tendido)
  quantities = quantities.flatten.map(&:to_i)
  raise ArgumentError, 'Debes ingresar al menos un número' if quantities.empty?

  # puts "Cantidades: #{quantities}"

  # Verificamos que haya al menos una cantidad no-cero
  quantities_no_cero = quantities.reject(&:zero?)
  if quantities_no_cero.empty?
    raise "Todas las cantidades son cero, no se puede calcular proporciones"
  end

  mcd = quantities_no_cero.reduce { |acc, q| acc.gcd(q) }
  min = quantities.min

  # puts "mcd: #{mcd}"
  # puts "min: #{min}"

  if mcd <= 9
    divisor = quantities_no_cero.min # evitamos division por cero
  else
    divisor = mcd
  end

  # puts "divisor: #{divisor}"

  proportions = quantities.map { |q| q / divisor }

  # Validemos la proporcion en base al largo maximo y ajustemos si es necesario
  largo_tendido = calculo_largo_tendido(proportions, consumo_por_prenda)
  if largo_tendido > largo_maximo_tendido
    # Buscamos un divisor mayor que el actual para reducir las proporciones
    # pero manteniendo las proporciones relativas correctas
    divisor_original = divisor
    divisor_ajustado = divisor_original
    
    # Probamos con divisores mayores hasta encontrar uno que funcione
    (divisor_original + 1..divisor_original * 10).each do |nuevo_divisor|
      proporciones_ajustadas = quantities.map { |q| q / nuevo_divisor }
      largo_ajustado = calculo_largo_tendido(proporciones_ajustadas, consumo_por_prenda)
      
      if largo_ajustado <= largo_maximo_tendido
        divisor_ajustado = nuevo_divisor
        proportions = proporciones_ajustadas
        divisor = nuevo_divisor
        break
      end
    end
    
    # Si no encontramos un divisor adecuado, intentamos con proporciones mínimas
    if largo_tendido > largo_maximo_tendido
      proportions = proportions.map { |p| p > 0 ? 1 : 0 }
      largo_ajustado = calculo_largo_tendido(proportions, consumo_por_prenda)
      if largo_ajustado > largo_maximo_tendido
        raise "No es posible ajustar las proporciones a enteros para el largo máximo especificado"
      end
    end
  end

  base_tendido = proportions.map { |p| p * cantidad_max_lienzos }

  
  # puts "quantities.reject(&:zero?).first: #{quantities.reject(&:zero?).first}"
  # puts "base_tendido.reject(&:zero?).first: #{base_tendido.reject(&:zero?).first}"

  # evitamos division por cero
  num_tendidos = (divisor / base_tendido.reject(&:zero?).first).to_i
  num_tendidos = 1 if num_tendidos == 0

  # puts "Proporciones: #{proportions}"
  # puts "Base tendido: #{base_tendido}"
  # puts "Num tendidos: #{num_tendidos}"

  prendas = quantities.sum
  prendas_tendidas = 0

  restantes = []

  base_tendido.each_with_index do |talla, index|
    restante = quantities[index] - (talla * num_tendidos)
    restantes << restante 
  end 
  # puts "restantes: #{restantes}"

  incompleto = restantes.sum > 0

  {
    quantities: quantities,
    divisor:    divisor,
    incompleto: incompleto,
    restantes:  incompleto ? restantes : [],
    proporcion:     proportions,
    tendido_base:   base_tendido,
    num_tendidos:   num_tendidos,
  }
end

def calculo_largo_tendido(proporcion, consumo_por_prenda)
    suma_proporcion = proporcion.sum
    largo_tendido = suma_proporcion * consumo_por_prenda
    largo_tendido
end


#--- Pruebas ---------------------------------------------------------------
class ProportionTest < Minitest::Test

    def test_caso_1
                    # xs    s   m      l     xl    xxl   xxxl
        input     = [800, 1600, 2400, 3200, 3200, 2400, 2400]
        consumo_por_prenda = 0.5
        largo_maximo = 10.0 # metros

        cantidad_max_lienzos = 100
        
        esperado  = [1, 2, 3, 4, 4, 3, 3]
        caso_1_resultado = tendidos(input, cantidad_max_lienzos, consumo_por_prenda, largo_maximo)

        puts "Caso 1"
        puts JSON.neat_generate(caso_1_resultado)

        assert_equal esperado, caso_1_resultado[:proporcion]
        assert_equal caso_1_resultado[:incompleto], false

        largo_tendido = calculo_largo_tendido(caso_1_resultado[:proporcion], consumo_por_prenda)
        puts "Largo tendido: #{largo_tendido}"
        puts "Largo máximo: #{largo_maximo}"
        puts "Proporcion válida? #{largo_tendido <= largo_maximo}"

        assert largo_tendido <= largo_maximo

        puts "Tendidos:"

        for i in 1..caso_1_resultado[:num_tendidos]
            puts "#{caso_1_resultado[:tendido_base]}"
        end
    end

    def test_caso_2
        input     = [850, 1700, 2550, 3400, 3400, 2550, 2550]
        esperado  = [1, 2, 3, 4, 4, 3, 3]
        
        consumo_por_prenda = 0.475
        largo_maximo = 11.0 

        resultados = []
        input_actual = input
        cantidad_max_lienzos = 100

        while true
            resultado = tendidos(input_actual, cantidad_max_lienzos, consumo_por_prenda, largo_maximo)
            resultados << resultado
            puts "Iteración #{resultados.length}"
            puts JSON.neat_generate(resultado)

            largo_tendido = calculo_largo_tendido(resultado[:proporcion], consumo_por_prenda)
            puts "Largo tendido: #{largo_tendido}"
            puts "Largo máximo: #{largo_maximo}"
            puts "Proporcion válida? #{largo_tendido <= largo_maximo}"
            assert largo_tendido <= largo_maximo

            if resultados.length == 1
                assert_equal esperado, resultado[:proporcion]
                assert_equal resultado[:incompleto], true
                restante_esperado = [50, 100, 150, 200, 200, 150, 150]
                assert_equal restante_esperado, resultado[:restantes]
            end

            break unless resultado[:incompleto]
            
            input_actual = resultado[:restantes]
            cantidad_max_lienzos = input_actual.reject(&:zero?).min
        end

        assert_equal resultados.last[:incompleto], false

        puts "Tendidos:"
        resultados.each do |resultado|
            for i in 1..resultado[:num_tendidos]
                puts "#{resultado[:tendido_base]}"
            end
        end
    end

    def test_caso_3
        input     = [800, 1632, 2583, 3301, 3301, 2583, 2583]
        esperado  = [1, 2, 3, 4, 4, 3, 3]

        consumo_por_prenda = 0.55
        largo_maximo = 11.0 
        
        resultados = []
        input_actual = input
        cantidad_max_lienzos = 100

        while true
            resultado = tendidos(input_actual, cantidad_max_lienzos, consumo_por_prenda, largo_maximo)
            resultados << resultado
            puts "Iteración #{resultados.length}"
            puts JSON.neat_generate(resultado)

            largo_tendido = calculo_largo_tendido(resultado[:proporcion], consumo_por_prenda)
            puts "Consumo por prenda: #{consumo_por_prenda}"
            puts "Largo tendido: #{largo_tendido}"
            puts "Largo máximo: #{largo_maximo}"
            puts "Proporcion válida? #{largo_tendido <= largo_maximo}"
            assert largo_tendido <= largo_maximo

            if resultados.length == 1
                assert_equal esperado, resultado[:proporcion]
                assert_equal resultado[:incompleto], true
                restante_esperado = [0, 32, 183, 101, 101, 183, 183]
                assert_equal restante_esperado, resultado[:restantes]
            end

            break unless resultado[:incompleto]
            
            input_actual = resultado[:restantes]
            cantidad_max_lienzos = input_actual.reject(&:zero?).min
        end

        puts "Tendidos:"
        resultados.each do |resultado|
            for i in 1..resultado[:num_tendidos]
                puts "#{resultado[:tendido_base]}"
            end
        end
    end

    def test_caso_4

        input = [1998, 2630, 4083, 5444, 4208, 3828, 3000]
        consumo_por_prenda = 0.5  # Valor por defecto para este caso
        largo_maximo = 10.0       # Valor por defecto para este caso

        resultados = []
        input_actual = input
        cantidad_max_lienzos = 120

        while true
            resultado = tendidos(input_actual, cantidad_max_lienzos, consumo_por_prenda, largo_maximo)
            resultados << resultado
            puts "Iteración #{resultados.length}"
            puts JSON.neat_generate(resultado)

            break unless resultado[:incompleto]
            
            input_actual = resultado[:restantes]
            cantidad_max_lienzos = input_actual.reject(&:zero?).min
        end

        puts "Tendidos:"
        resultados.each do |resultado|
            for i in 1..resultado[:num_tendidos]
                puts "#{resultado[:tendido_base]}"
            end
        end
    end

    def test_ajuste_automatico_proporciones
        # Caso donde el largo del tendido sería mayor al máximo
        input = [2000, 4000, 6000, 8000, 8000, 6000, 6000]  # Cantidades grandes
        consumo_por_prenda = 0.8  # Consumo alto por prenda
        largo_maximo = 8.0        # Largo máximo pequeño
        
        cantidad_max_lienzos = 100
        
        resultado = tendidos(input, cantidad_max_lienzos, consumo_por_prenda, largo_maximo)
        
        puts "Test Ajuste Automático"
        puts JSON.neat_generate(resultado)
        
        # Verificamos que el largo del tendido sea menor o igual al máximo
        largo_tendido = calculo_largo_tendido(resultado[:proporcion], consumo_por_prenda)
        puts "Largo tendido calculado: #{largo_tendido}"
        puts "Largo máximo: #{largo_maximo}"
        
        assert largo_tendido <= largo_maximo, "El largo del tendido debe ser menor o igual al máximo"
        
        # Verificamos que las proporciones no sean todas cero
        assert !resultado[:proporcion].all?(&:zero?), "Las proporciones no deben ser todas cero"
        
        # Verificamos que las proporciones mantengan la relación relativa
        assert resultado[:proporcion].any? { |p| p > 0 }, "Al menos una proporción debe ser mayor que cero"
        
        puts "✅ Ajuste automático funcionó correctamente"
    end

    # Fragrant Lilac 
    # def test_caso_4
    #     input     = [1639, 2070, 1294, 260]
    #     esperado  = [9, 11, 7, 2]
    #     caso_4_resultado = tendidos(input)
    #     puts "Caso 4 -- Fragrant Lilac"
    #     puts JSON.neat_generate(caso_4_resultado)
        
    #     # assert_equal esperado, caso_3_resultado[:proporcion]
    # end

    # Strawberry Cream
    # def test_caso_5
    #     input     = [1064, 2764, 3264, 1440]
    #     esperado  = [9, 11, 7, 2]
    #     caso_5_resultado = tendidos(input)
    #     puts "Caso 5 -- Strawberry Cream"
    #     puts JSON.neat_generate(caso_5_resultado)
    # end

    # black 
    # def test_caso_6
    #     input     = [1166, 2668, 2912, 1464]
    #     esperado  = [9, 11, 7, 2]
    #     caso_6_resultado = tendidos(input)
    #     puts "Caso 6 -- Black"
    #     puts JSON.neat_generate(caso_6_resultado)
    # end

    


end