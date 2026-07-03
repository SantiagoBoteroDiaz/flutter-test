## Decisiones tecnicas

# Algoritmo de deuda 

El algoritmo calcula primero el gasto total sumando todos los aportes realizados por cada participante. Luego obtiene la cuota justa dividiendo ese total entre el número de personas:

	​
    Cuota justa= Numero de personas 
                 ___________________
                 Gasto total​ 


Después, para cada persona calcula su balance:

    Balance=Aporte realizado−Cuota justa

Un balance positivo indica que la persona debe recibir dinero, mientras que un balance negativo indica que debe pagar. Finalmente, el algoritmo empareja deudores y acreedores realizando transferencias por el menor valor entre lo que uno debe y lo que el otro debe recibir, hasta que todos los balances sean aproximadamente cero.

## ¿Por qué Riverpod?

Elegí Riverpod por tres razones puntuales para esta app:

- **Estado compartido entre pantallas:** la lista de gastos se crea en el
  formulario y se consume en la pantalla de balances. Como cruza rutas,
  `setState` no alcanza.
- **Estado derivado (la razón principal):** los balances y la liquidación no se
  guardan, se **calculan** a partir de los gastos. Con providers derivados
  (`balancesProvider` y `settlementsProvider` observan a `expensesProvider`)
  todo se recalcula solo al agregar o borrar un gasto, con una única fuente de
  verdad y sin sincronización manual.
- **Testeable y a la medida:** la lógica vive en funciones puras y Riverpod no
  depende del `BuildContext`, lo que facilita las pruebas. Bloc sería
  sobre-ingeniería y `provider` clásico es menos seguro; Riverpod es el punto
  justo entre potencia y simplicidad para este alcance.
