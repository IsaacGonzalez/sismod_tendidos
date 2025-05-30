# Cálculo de Tendidos

Este programa calcula la distribución óptima de prendas en tendidos, manteniendo las proporciones correctas y manejando los sobrantes de manera eficiente.

## Método `tendidos`

El método `tendidos` calcula la distribución de prendas en tendidos basándose en las cantidades proporcionadas. Acepta las siguientes entradas:

```ruby
def tendidos(*quantities, cantidad_max_lienzos: 100)
```

### Parámetros:
- `quantities`: Lista de cantidades de prendas por talla
- `cantidad_max_lienzos`: Número máximo de prendas por tendido (por defecto: 100)

### Retorno:
El método retorna un hash con la siguiente información:
```ruby
{
  quantities: [cantidades originales],
  divisor: divisor_utilizado,
  incompleto: boolean,
  restantes: [cantidades restantes],
  proporcion: [proporciones calculadas],
  tendido_base: [cantidades por tendido],
  num_tendidos: numero_de_tendidos
}
```

## Ejemplos

### Caso 1: Sin sobrantes
```ruby
input = [800, 1600, 2400, 3200, 3200, 2400, 2400]
resultado = tendidos(input)
```

Este caso retorna:
- Proporciones: [1, 2, 3, 4, 4, 3, 3]
- Incompleto: false
- No hay restantes

### Caso 2: Con sobrantes
```ruby
input = [850, 1700, 2550, 3400, 3400, 2550, 2550]
resultado = tendidos(input)
```

Este caso retorna:
- Proporciones: [1, 2, 3, 4, 4, 3, 3]
- Incompleto: true
- Restantes: [50, 100, 150, 200, 200, 150, 150]

Para manejar los sobrantes, se puede hacer una segunda llamada:
```ruby
resultado2 = tendidos(resultado[:restantes], cantidad_max_lienzos: resultado[:restantes].reject(&:zero?).min)
```

### Caso 3: Múltiples iteraciones
```ruby
input = [800, 1632, 2583, 3301, 3301, 2583, 2583]
resultado = tendidos(input)
```

Este caso requiere múltiples iteraciones para procesar todos los sobrantes:
- Primera iteración: Restantes [0, 32, 183, 101, 101, 183, 183]
- Iteraciones subsecuentes procesan los restantes hasta completar todas las prendas

## Cómo funciona

1. Calcula el MCD (Máximo Común Divisor) de las cantidades
2. Si el MCD es menor o igual a 9, usa el mínimo de las cantidades como divisor
3. Calcula las proporciones dividiendo cada cantidad por el divisor
4. Calcula el número de tendidos necesarios
5. Determina si hay sobrantes
6. Retorna toda la información necesaria para el proceso

## Ejecución

Para ejecutar las pruebas:
```bash
ruby proportion.rb
```

## Notas importantes

- El método mantiene las proporciones correctas entre las tallas
- Los sobrantes se pueden procesar en iteraciones subsecuentes
- La cantidad máxima de lienzos por tendido se puede ajustar según necesidades
- El proceso es idempotente: múltiples iteraciones eventualmente procesarán todas las prendas 