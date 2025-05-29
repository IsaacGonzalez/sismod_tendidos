# proportion.rb
#
# ruby proportion.rb            # ejecuta las pruebas
#
require 'json'                  # solo si luego quieres .to_json
require 'neatjson'
require 'minitest/autorun'

def repetitions(*quantities, cantidad_max_lienzos: 100)
  quantities = quantities.flatten.map(&:to_i)
  raise ArgumentError, 'Debes ingresar al menos un número' if quantities.empty?

  # puts "Cantidades: #{quantities}"

  mcd = quantities.reject(&:zero?).reduce { |acc, q| acc.gcd(q) }
  min = quantities.min

  # puts "mcd: #{mcd}"
  # puts "min: #{min}"

  if mcd <= 9
    divisor = quantities.reject(&:zero?).min # evitamos division por cero
  else
    divisor = mcd
  end

  # puts "divisor: #{divisor}"

  proportions = quantities.map { |q| q / divisor }
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

#--- Pruebas ---------------------------------------------------------------
class ProportionTest < Minitest::Test

    def test_caso_1
        input     = [800, 1600, 2400, 3200, 3200, 2400, 2400]
        esperado  = [1, 2, 3, 4, 4, 3, 3]
        caso_1_resultado = repetitions(input)

        puts "Caso 1"
        puts JSON.neat_generate(caso_1_resultado)

        assert_equal esperado, caso_1_resultado[:proporcion]
        assert_equal caso_1_resultado[:incompleto], false

        puts "Tendidos:"

        for i in 1..caso_1_resultado[:num_tendidos]
            puts "#{caso_1_resultado[:tendido_base]}"
        end
    end

    def test_caso_2
        input     = [850, 1700, 2550, 3400, 3400, 2550, 2550]
        esperado  = [1, 2, 3, 4, 4, 3, 3]
        caso_2_resultado = repetitions(input)

        puts "Caso 2"
        puts JSON.neat_generate(caso_2_resultado)

        assert_equal esperado, caso_2_resultado[:proporcion]
        assert_equal caso_2_resultado[:incompleto], true

        restante_esperado = [50, 100, 150, 200, 200, 150, 150]
        assert_equal restante_esperado, caso_2_resultado[:restantes]

        puts "--------------------------------"
        puts "Caso 2 round 2"
        caso_2_resultado2 = repetitions(caso_2_resultado[:restantes], cantidad_max_lienzos: caso_2_resultado[:restantes].reject(&:zero?).min)
        puts JSON.neat_generate(caso_2_resultado2)        

        assert_equal caso_2_resultado2[:incompleto], false

        puts "Tendidos:"

        for i in 1..caso_2_resultado[:num_tendidos]
            puts "#{caso_2_resultado[:tendido_base]}"
        end

        for i in 1..caso_2_resultado2[:num_tendidos]
            puts "#{caso_2_resultado2[:tendido_base]}"
        end

    end

    def test_caso_3
      
        input     = [800, 1632, 2583, 3301, 3301, 2583, 2583]
        esperado  = [1, 2, 3, 4, 4, 3, 3]
        caso_3_resultado = repetitions(input)
        puts "Caso 3"
        puts JSON.neat_generate(caso_3_resultado)
        
        assert_equal esperado, caso_3_resultado[:proporcion]
        assert_equal caso_3_resultado[:incompleto], true

        restante_esperado = [0, 32, 183, 101, 101, 183, 183]
        assert_equal restante_esperado, caso_3_resultado[:restantes]

        puts "--------------------------------"
        puts "Caso 3 round 2"
        caso_3_round_2 = caso_3_resultado[:restantes]

        # La segunda iteracion se tiene que hacer con el maximo de lienzos igual al minimo de los restantes
        caso_3_resultado2 = repetitions(caso_3_round_2, cantidad_max_lienzos: caso_3_round_2.reject(&:zero?).min)
        puts JSON.neat_generate(caso_3_resultado2)
        
        # assert_equal caso_3_resultado[:incompleto], false
        # assert_equal caso_3_resultado[:proporcion], [0, 1, 4, 3, 3, 4, 4]
        
        puts "--------------------------------"
        puts "Caso 3 round 3"
        caso_3_round_3 = caso_3_resultado2[:restantes]

        # La segunda iteracion se tiene que hacer con el maximo de lienzos igual al minimo de los restantes
        caso_3_resultado3 = repetitions(caso_3_round_3, cantidad_max_lienzos: caso_3_round_3.reject(&:zero?).min)
        puts JSON.neat_generate(caso_3_resultado3)

        puts "--------------------------------"
        puts "Caso 3 round 4"
        caso_3_round_4 = caso_3_resultado3[:restantes]

        # La segunda iteracion se tiene que hacer con el maximo de lienzos igual al minimo de los restantes
        caso_3_resultado4 = repetitions(caso_3_round_4, cantidad_max_lienzos: caso_3_round_4.reject(&:zero?).min)
        puts JSON.neat_generate(caso_3_resultado4)

        for i in 1..caso_3_resultado[:num_tendidos]
            puts "#{caso_3_resultado[:tendido_base]}"
        end

        for i in 1..caso_3_resultado2[:num_tendidos]
            puts "#{caso_3_resultado2[:tendido_base]}"
        end

        for i in 1..caso_3_resultado3[:num_tendidos]
            puts "#{caso_3_resultado3[:tendido_base]}"
        end

        for i in 1..caso_3_resultado4[:num_tendidos]
            puts "#{caso_3_resultado4[:tendido_base]}"
        end
        
        
    end


    # Fragrant Lilac 
    # def test_caso_4
    #     input     = [1639, 2070, 1294, 260]
    #     esperado  = [9, 11, 7, 2]
    #     caso_4_resultado = repetitions(input)
    #     puts "Caso 4 -- Fragrant Lilac"
    #     puts JSON.neat_generate(caso_4_resultado)
        
    #     # assert_equal esperado, caso_3_resultado[:proporcion]
    # end

    # Strawberry Cream
    # def test_caso_5
    #     input     = [1064, 2764, 3264, 1440]
    #     esperado  = [9, 11, 7, 2]
    #     caso_5_resultado = repetitions(input)
    #     puts "Caso 5 -- Strawberry Cream"
    #     puts JSON.neat_generate(caso_5_resultado)
    # end

    # black 
    # def test_caso_6
    #     input     = [1166, 2668, 2912, 1464]
    #     esperado  = [9, 11, 7, 2]
    #     caso_6_resultado = repetitions(input)
    #     puts "Caso 6 -- Black"
    #     puts JSON.neat_generate(caso_6_resultado)
    # end

end