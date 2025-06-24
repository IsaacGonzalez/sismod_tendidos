# Cálculo de Tendidos

Este programa calcula la distribución óptima de prendas en tendidos, manteniendo las proporciones correctas y manejando los sobrantes de manera eficiente. Incluye validación de largo máximo de tendido y ajuste automático de proporciones.

## Método `tendidos`

El método `tendidos` calcula la distribución de prendas en tendidos basándose en las cantidades proporcionadas. Acepta las siguientes entradas:

```ruby
def tendidos(*quantities, cantidad_max_lienzos, consumo_por_prenda, largo_maximo_tendido)
```

### Parámetros:
- `quantities`: Lista de cantidades de prendas por talla
- `cantidad_max_lienzos`: Número máximo de prendas por tendido
- `consumo_por_prenda`: Consumo de tela por prenda (en metros)
- `largo_maximo_tendido`: Largo máximo permitido para el tendido (en metros)

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

## Funcionalidades

### Ajuste Automático de Proporciones
El sistema incluye validación automática del largo del tendido:
- Calcula el largo total del tendido basado en las proporciones y el consumo por prenda
- Si el largo excede el máximo permitido, ajusta automáticamente las proporciones
- Mantiene las proporciones relativas correctas mientras respeta el límite de largo
- Si no es posible ajustar, utiliza proporciones mínimas (1 para cantidades > 0)

### Cálculo de Largo de Tendido
```ruby
def calculo_largo_tendido(proporcion, consumo_por_prenda)
    suma_proporcion = proporcion.sum
    largo_tendido = suma_proporcion * consumo_por_prenda
    largo_tendido
end
```

## Ejemplos

### Caso 1: Sin sobrantes
```ruby
input = [800, 1600, 2400, 3200, 3200, 2400, 2400]
consumo_por_prenda = 0.5
largo_maximo = 10.0
cantidad_max_lienzos = 100

resultado = tendidos(input, cantidad_max_lienzos, consumo_por_prenda, largo_maximo)
```

Este caso retorna:
- Proporciones: [1, 2, 3, 4, 4, 3, 3]
- Incompleto: false
- Largo tendido: 10.0 metros (dentro del límite)
- No hay restantes

### Caso 2: Con sobrantes
```ruby
input = [850, 1700, 2550, 3400, 3400, 2550, 2550]
consumo_por_prenda = 0.475
largo_maximo = 11.0
cantidad_max_lienzos = 100

resultado = tendidos(input, cantidad_max_lienzos, consumo_por_prenda, largo_maximo)
```

Este caso retorna:
- Proporciones: [1, 2, 3, 4, 4, 3, 3]
- Incompleto: true
- Restantes: [50, 100, 150, 200, 200, 150, 150]

Para manejar los sobrantes, se puede hacer una segunda llamada:
```ruby
resultado2 = tendidos(resultado[:restantes], cantidad_max_lienzos, consumo_por_prenda, largo_maximo)
```

### Caso 3: Ajuste automático de proporciones
```ruby
input = [2000, 4000, 6000, 8000, 8000, 6000, 6000]
consumo_por_prenda = 0.8
largo_maximo = 8.0
cantidad_max_lienzos = 100

resultado = tendidos(input, cantidad_max_lienzos, consumo_por_prenda, largo_maximo)
```

En este caso, el sistema ajusta automáticamente las proporciones para que el largo del tendido no exceda los 8.0 metros.

## Cómo funciona

1. Calcula el MCD (Máximo Común Divisor) de las cantidades no-cero
2. Si el MCD es menor o igual a 9, usa el mínimo de las cantidades como divisor
3. Calcula las proporciones dividiendo cada cantidad por el divisor
4. **Valida el largo del tendido** contra el máximo permitido
5. **Ajusta las proporciones automáticamente** si es necesario
6. Calcula el número de tendidos necesarios
7. Determina si hay sobrantes
8. Retorna toda la información necesaria para el proceso

## Validaciones

- Verifica que haya al menos una cantidad no-cero
- Valida que el largo del tendido no exceda el máximo permitido
- Ajusta automáticamente las proporciones cuando es necesario
- Maneja casos extremos donde no es posible ajustar las proporciones

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
- **Nueva funcionalidad**: Validación automática del largo de tendido con ajuste de proporciones
- **Nueva funcionalidad**: Parámetros configurables para consumo por prenda y largo máximo 